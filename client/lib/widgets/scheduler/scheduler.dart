import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_item.dart';
import '../../repositories/appointment_repository.dart';
import '../../services/data_service.dart';
import '../../utils/logger.dart';
import 'day_view.dart';
import 'five_day_view.dart';
import 'week_view.dart';
import 'month_view.dart';

class Scheduler extends StatefulWidget {
  final String viewMode;
  final bool isMultiple;
  final List<String>? providers;
  const Scheduler({
    Key? key,
    required this.viewMode,
    required this.isMultiple,
    this.providers,
  }) : super(key: key);

  @override
  _SchedulerState createState() => _SchedulerState();
}

class _SchedulerState extends State<Scheduler> {
  late DateTime _centerDate;
  late PageController _pageController;
  List<AppointmentItem> _appointments = [];
  @override
  void initState() {
    super.initState();
    _centerDate = DateTime.now();
    _pageController = PageController(initialPage: 1000);
    _loadAppointments();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadAppointments() async {
    final logger = Logger();
    int startYear = _centerDate.year;
    int startMonth = _centerDate.month - 1;
    if (startMonth == 0) {
      startYear -= 1;
      startMonth = 12;
    }
    final startDate = DateTime(startYear, startMonth, 1);

    int endYear = _centerDate.year;
    int endMonth = _centerDate.month + 2;
    if (endMonth > 12) {
      endYear += 1;
      endMonth -= 12;
    }
    final endDate = DateTime(endYear, endMonth, 0);

    final apptRepository = AppointmentRepository();
    logger.log(Level.INFO,
        "attempting to fetch appointments from $startDate to $endDate");
    final appointments =
        await apptRepository.getAppointmentsInRange(startDate, endDate);
    setState(() {
      _appointments = appointments;
      logger.log(Level.INFO, "loaded ${_appointments.length} appointments");
    });
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _centerDate = newDate;
    });
    if (widget.viewMode == 'Month') {
      _updateMonthView(newDate);
    }
    _loadAppointments();
  }

  void _updateMonthView(DateTime newDate) {
    final monthDiff = (newDate.year - DateTime.now().year) * 12 +
        newDate.month -
        DateTime.now().month;
    //_pageController.jumpToPage(1000 + monthDiff);
  }

  void _onPageChanged(int page) {
    final newDate = DateTime.now().add(Duration(days: page - 1000));
    _onDateChanged(newDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateHeader(),
        Expanded(
          child: _buildViewContent(),
        ),
      ],
    );
  }

  Widget _buildViewContent() {
    if (widget.isMultiple) {
      return _buildMultipleSchedules();
    }

    switch (widget.viewMode) {
      case 'Day':
        return DayView(
          pageController: _pageController,
          onPageChanged: _onPageChanged,
        );
      case '5-Day':
        return FiveDayView(
          pageController: _pageController,
          onPageChanged: _onPageChanged,
        );
      case 'Week':
        return WeekView(
          pageController: _pageController,
          onPageChanged: _onPageChanged,
        );
      case 'Month':
        return MonthView(
          initialDate: _centerDate,
          onDateSelected: _onDateChanged,
          onMonthChanged: _onDateChanged,
        );
      default:
        return Container();
    }
  }

  Widget _buildMultipleSchedules() {
    if (widget.providers == null || widget.providers!.isEmpty) {
      return Center(child: Text('No providers selected.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.providers!.map((provider) {
          return Container(
            width: 300,
            margin: EdgeInsets.only(right: 8),
            child: DayView(
              pageController: PageController(initialPage: 1000),
              onPageChanged: _onPageChanged,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateHeader() {
    String headerText;

    switch (widget.viewMode) {
      case 'Day':
        headerText = DateFormat('EEEE, MMMM d, y').format(_centerDate);
        break;
      case '5-Day':
        final endDate = _centerDate.add(Duration(days: 4));
        headerText =
            '${DateFormat('MMM d').format(_centerDate)} - ${DateFormat('MMM d, y').format(endDate)}';
        break;
      case 'Week':
        final startOfWeek =
            _centerDate.subtract(Duration(days: _centerDate.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        headerText =
            '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, y').format(endOfWeek)}';
        break;
      case 'Month':
        headerText = DateFormat('MMMM yyyy').format(_centerDate);
        break;
      default:
        headerText = '';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(FluentIcons.chevron_left),
            onPressed: () => _navigateToPrevious(),
          ),
          Text(
            headerText,
            style: FluentTheme.of(context).typography.subtitle,
          ),
          IconButton(
            icon: Icon(FluentIcons.chevron_right),
            onPressed: () => _navigateToNext(),
          ),
        ],
      ),
    );
  }

  void _navigateToPrevious() {
    switch (widget.viewMode) {
      case 'Day':
      case '5-Day':
      case 'Week':
        _pageController.previousPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      case 'Month':
        _onDateChanged(DateTime(_centerDate.year, _centerDate.month - 1, 1));
        break;
    }
  }

  void _navigateToNext() {
    switch (widget.viewMode) {
      case 'Day':
      case '5-Day':
      case 'Week':
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      case 'Month':
        _onDateChanged(DateTime(_centerDate.year, _centerDate.month + 1, 1));
        break;
    }
  }
}
