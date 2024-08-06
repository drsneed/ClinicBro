import 'package:fluent_ui/fluent_ui.dart';
import 'day_view.dart'; // Existing day view
import 'five_day_view.dart'; // Import FiveDayView
import 'week_view.dart'; // Import WeekView
import 'month_view.dart'; // Import MonthView

class Scheduler extends StatefulWidget {
  final String viewMode;
  final bool isMultiple;
  final List<String>? providers; // Added providers for multiple schedules

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
  late PageController _pageController;
  late DateTime _centerDate;

  @override
  void initState() {
    super.initState();
    _centerDate = DateTime.now();
    _pageController = PageController(
      initialPage: 1000,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Scheduler oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle view mode change if necessary
  }

  void _onPageChanged(int page) {
    setState(() {
      _centerDate = DateTime.now().add(Duration(days: page - 1000));
    });
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
        return FiveDayView();
      case 'Week':
        return WeekView();
      case 'Month':
        return MonthView();
      default:
        return Container(); // Default empty container or handle unsupported views
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
            width: 300, // Adjust width as needed
            margin: EdgeInsets.only(right: 8),
            child: DayView(
              pageController: _pageController,
              onPageChanged: _onPageChanged,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(FluentIcons.chevron_left),
            onPressed: () => _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          Text(
            '${_centerDate.year}-${_centerDate.month.toString().padLeft(2, '0')}-${_centerDate.day.toString().padLeft(2, '0')}',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          IconButton(
            icon: Icon(FluentIcons.chevron_right),
            onPressed: () => _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}
