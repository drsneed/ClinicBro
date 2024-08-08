import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

import '../../utils/calendar_grid.dart';

class NavigationMonthView extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(DateTime) onMonthChanged;

  const NavigationMonthView({
    Key? key,
    required this.initialDate,
    required this.onMonthChanged,
    this.onDateSelected,
  }) : super(key: key);

  @override
  _NavigationMonthViewState createState() => _NavigationMonthViewState();
}

class _NavigationMonthViewState extends State<NavigationMonthView> {
  late PageController _pageController;
  late DateTime _currentMonth;
  late CalendarGrid _calendarGrid;
  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _calendarGrid = CalendarGrid(_currentMonth);
    _pageController = PageController(initialPage: 1000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMonthChanged(_currentMonth);
    });
  }

  @override
  void didUpdateWidget(NavigationMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate.year != _currentMonth.year ||
        widget.initialDate.month != _currentMonth.month) {
      _updateToMonth(widget.initialDate);
    }
  }

  void _updateToMonth(DateTime newMonth) {
    setState(() {
      _currentMonth = DateTime(newMonth.year, newMonth.month);
      _calendarGrid = CalendarGrid(_currentMonth);
    });
    final newPage = 1000 +
        (newMonth.year - DateTime.now().year) * 12 +
        (newMonth.month - DateTime.now().month);
    _pageController.jumpToPage(newPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final newMonth =
        DateTime(DateTime.now().year, DateTime.now().month + (page - 1000));
    if (newMonth.year != _currentMonth.year ||
        newMonth.month != _currentMonth.month) {
      setState(() {
        _currentMonth = newMonth;
      });
      widget.onMonthChanged(newMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final cellColor = theme.cardColor;
    final todayBackgroundColor = theme.accentColor;
    const todayColor = Colors.white;
    final borderColor = theme.cardColor;
    final textColor = theme.inactiveColor.withOpacity(0.3);
    final currentMonthColor = theme.inactiveColor.withOpacity(0.7);

    final headerText = DateFormat('MMMM yyyy').format(_currentMonth);

    return Container(
      // color: Colors.blue
      //     .withOpacity(0.2), // Temporarily change the background color
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / 7;
            final availableHeight = constraints.maxHeight -
                70.0; // Estimation of scheduler controls height
            final cellHeight = (availableHeight / _calendarGrid.numberOfRows)
                .clamp(0.0, cellWidth); // height can't exceed cell width
            final gridHeight = cellHeight * _calendarGrid.numberOfRows;

            return Column(
              children: [
                // Display month and year above the calendar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    headerText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildWeekdayHeader(cellWidth, textColor),
                Container(
                  height: gridHeight, // Add some extra padding for safety
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, page) {
                      return _buildCalendarGrid(
                        cellWidth,
                        cellHeight,
                        cellColor,
                        todayBackgroundColor,
                        todayColor,
                        borderColor,
                        textColor,
                        currentMonthColor,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(
      double cellWidth,
      double cellHeight,
      Color cellColor,
      Color todayBackgroundColor,
      Color todayColor,
      Color borderColor,
      Color textColor,
      Color currentMonthColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: cellWidth / cellHeight,
      ),
      itemCount: _calendarGrid.days.length,
      itemBuilder: (context, index) {
        final date = _calendarGrid.days[index];
        final isCurrentMonth = date.month == _currentMonth.month;
        final isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;

        return GestureDetector(
          onTap: () {
            if (widget.onDateSelected != null) {
              widget.onDateSelected!(date);
            }
          },
          child: Container(
            width: cellWidth,
            height: cellHeight,
            decoration: BoxDecoration(
              color: isToday ? todayBackgroundColor : cellColor,
              border: Border(
                right: BorderSide(
                  color: borderColor,
                  width: 1.0,
                ),
                bottom: BorderSide(
                  color: borderColor,
                  width: 1.0,
                ),
              ),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isToday
                      ? todayColor
                      : (isCurrentMonth ? currentMonthColor : textColor),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: cellWidth * 0.25,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekdayHeader(double cellSize, Color textColor) {
    return Container(
      height: 20,
      child: Row(
        children: List.generate(7, (index) {
          final weekday = ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index];
          return Container(
            width: cellSize,
            child: Center(
              child: Text(
                weekday,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
