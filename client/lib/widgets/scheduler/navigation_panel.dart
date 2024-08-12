import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../../repositories/appointment_repository.dart';
import '../../utils/logger.dart';
import 'navigation_month_view.dart';

class SchedulerNavigationPanel extends StatefulWidget {
  final bool isVisible;
  final DateTime centerDate;
  final void Function(DateTime) onDateChanged;
  final List<DateTime> selectedDates;
  const SchedulerNavigationPanel({
    super.key,
    required this.isVisible,
    required this.centerDate,
    required this.onDateChanged,
    required this.selectedDates,
  });

  @override
  SchedulerNavigationPanelState createState() =>
      SchedulerNavigationPanelState();
}

class SchedulerNavigationPanelState extends State<SchedulerNavigationPanel> {
  late ScrollController _scrollController;
  late List<DateTime> _monthList;
  final int _initialMonthCount = 36; // Start with 3 years worth of months
  final double _estimatedMonthViewHeight =
      240.0; // Estimate of NavigationMonthView height
  Map<DateTime, List<DateTime>> _appointmentDatesMap =
      {}; // Map to cache appointment dates

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeMonthList();
    _scrollController.addListener(_onScroll);
    _fetchAndCacheAppointmentDates(); // Fetch initial appointment dates
  }

  void _initializeMonthList() {
    DateTime startDate =
        DateTime(widget.centerDate.year - 1, widget.centerDate.month, 1);
    _monthList = List.generate(_initialMonthCount, (index) {
      return DateTime(startDate.year, startDate.month + index, 1);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _addMonthsToEnd();
    } else if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      _addMonthsToStart();
    }
  }

  void _addMonthsToEnd() {
    setState(() {
      DateTime lastDate = _monthList.last;
      _monthList.add(DateTime(lastDate.year, lastDate.month + 1, 1));
    });
    _fetchAndCacheAppointmentDates(); // Fetch new appointment dates if needed
  }

  void _addMonthsToStart() {
    setState(() {
      DateTime firstDate = _monthList.first;
      _monthList.insert(0, DateTime(firstDate.year, firstDate.month - 1, 1));
      // Adjust scroll position to keep the view stable
      _scrollController
          .jumpTo(_scrollController.offset + (_estimatedMonthViewHeight));
    });
    _fetchAndCacheAppointmentDates(); // Fetch new appointment dates if needed
  }

  Future<void> refresh() async {
    print('scheduler panel refresh called');
    _fetchAndCacheAppointmentDates();
  }

  Future<void> _fetchAndCacheAppointmentDates() async {
    DateTime firstDate = _monthList.first;
    DateTime lastDate = _monthList.last;

    final appointmentDates = await fetchAppointmentDates(firstDate, lastDate);
    final Map<DateTime, List<DateTime>> newAppointmentDatesMap = {};

    for (var date in _monthList) {
      newAppointmentDatesMap[date] = appointmentDates.where((appointmentDate) {
        return appointmentDate.year == date.year &&
            appointmentDate.month == date.month;
      }).toList();
    }

    setState(() {
      _appointmentDatesMap = newAppointmentDatesMap;
    });
    Logger().log(Level.INFO,
        "Fetched and cached ${appointmentDates.length} appointment dates");
  }

  Future<List<DateTime>> fetchAppointmentDates(
      DateTime from, DateTime to) async {
    print('navigation panel is fetching dates from server...');
    final appointmentRepository = AppointmentRepository();
    final appointmentDates =
        await appointmentRepository.getAppointmentDatesInRange(from, to);
    return appointmentDates;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the correct month is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToMonthContainingDate(widget.centerDate);
    });

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: widget.isVisible ? 250 : 0,
      color: FluentTheme.of(context).micaBackgroundColor,
      child: widget.isVisible
          ? Stack(
              children: [
                _buildScrollableContent(),
                _buildFloatingButtons(),
              ],
            )
          : null,
    );
  }

  void _scrollToMonthContainingDate(DateTime date) {
    final index = _monthList
        .indexWhere((d) => d.year == date.year && d.month == date.month);

    if (index == -1) return; // Date not found

    final targetOffset = index * _estimatedMonthViewHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildScrollableContent() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _monthList.length,
      itemBuilder: (context, index) {
        final month = _monthList[index];
        final appointmentDates = _appointmentDatesMap[month] ?? [];

        return NavigationMonthView(
          key: ValueKey('month-$index'),
          initialDate: month,
          onDaySelected: widget.onDateChanged,
          appointmentDates: appointmentDates,
          selectedDates: widget.selectedDates,
        );
      },
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        color: FluentTheme.of(context).micaBackgroundColor.withOpacity(0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.chevron_left),
              onPressed: () {
                double newOffset =
                    _scrollController.offset - _estimatedMonthViewHeight;
                _scrollController.animateTo(newOffset,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
            ),
            IconButton(
              icon: const Icon(FluentIcons.chevron_right),
              onPressed: () {
                double newOffset =
                    _scrollController.offset + _estimatedMonthViewHeight;
                _scrollController.animateTo(newOffset,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
            ),
          ],
        ),
      ),
    );
  }
}
