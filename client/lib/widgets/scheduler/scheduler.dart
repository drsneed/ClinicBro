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
  final DateTime centerDate;
  final void Function(DateTime) onDateChanged;
  final List<AppointmentItem> appointments;
  const Scheduler({
    super.key,
    required this.viewMode,
    required this.isMultiple,
    required this.centerDate,
    required this.onDateChanged,
    required this.appointments,
  });

  @override
  _SchedulerState createState() => _SchedulerState();
}

class _SchedulerState extends State<Scheduler> {
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateMonthView(DateTime newDate) {
    final monthDiff = (newDate.year - DateTime.now().year) * 12 +
        newDate.month -
        DateTime.now().month;
    //_pageController.jumpToPage(1000 + monthDiff);
  }

  void _onPageChanged(int page) {
    final newDate = DateTime.now().add(Duration(days: page - 1000));
    widget.onDateChanged(newDate);
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
          initialDate: widget.centerDate,
          onDateSelected: widget.onDateChanged,
          onMonthChanged: widget.onDateChanged,
          appointments: widget.appointments,
        );
      default:
        return Container();
    }
  }

  Widget _buildMultipleSchedules() {
    return const Center(
        child: Text('Multiple Schedule mode not implemented yet'));
  }

  Widget _buildDateHeader() {
    String headerText;

    switch (widget.viewMode) {
      case 'Day':
        headerText = DateFormat('EEEE, MMMM d, y').format(widget.centerDate);
        break;
      case '5-Day':
        final endDate = widget.centerDate.add(Duration(days: 4));
        headerText =
            '${DateFormat('MMM d').format(widget.centerDate)} - ${DateFormat('MMM d, y').format(endDate)}';
        break;
      case 'Week':
        final startOfWeek = widget.centerDate
            .subtract(Duration(days: widget.centerDate.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        headerText =
            '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, y').format(endOfWeek)}';
        break;
      case 'Month':
        headerText = DateFormat('MMMM yyyy').format(widget.centerDate);
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
        widget.onDateChanged(
            DateTime(widget.centerDate.year, widget.centerDate.month - 1, 1));
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
        widget.onDateChanged(
            DateTime(widget.centerDate.year, widget.centerDate.month + 1, 1));
        break;
    }
  }
}
