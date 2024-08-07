import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _centerDate = DateTime.now();
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _centerDate = newDate;
    });
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
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
