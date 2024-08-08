import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

import '../../utils/calendar_grid.dart';

class MonthView extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(DateTime) onMonthChanged;

  const MonthView({
    Key? key,
    required this.initialDate,
    required this.onMonthChanged,
    this.onDateSelected,
  }) : super(key: key);

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
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
  void didUpdateWidget(MonthView oldWidget) {
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
    final borderColor = theme.inactiveColor;
    final textColor = theme.inactiveColor.withOpacity(0.3);
    final currentMonthColor = theme.inactiveColor.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / 7;
          final availableHeight = constraints.maxHeight -
              50.0; // 50.0 is estimation of scheduler controls height
          final cellHeight = (availableHeight / _calendarGrid.numberOfRows)
              .clamp(0.0,
                  cellWidth); // Ensure the height does not exceed the cell width
          final gridHeight =
              cellHeight * _calendarGrid.numberOfRows; // Height to fit all rows

          return Column(
            children: [
              _buildWeekdayHeader(cellWidth, textColor),
              Container(
                height: gridHeight + 10, // Add some extra padding for safety
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, page) {
                    final monthToShow = DateTime(
                      DateTime.now().year,
                      DateTime.now().month + (page - 1000),
                    );
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
        childAspectRatio: cellWidth / cellHeight, // Use the cell aspect ratio
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
              border: Border.all(color: borderColor),
              color: isToday ? todayBackgroundColor : cellColor,
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

  // @override
  // Widget build(BuildContext context) {
  //   final theme = FluentTheme.of(context);
  //   final cellColor = theme.cardColor;
  //   final todayBackgroundColor = theme.accentColor;
  //   const todayColor = Colors.white;
  //   final borderColor = theme.inactiveColor;
  //   final textColor = theme.inactiveColor.withOpacity(0.3);
  //   final currentMonthColor = theme.inactiveColor.withOpacity(0.7);

  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: LayoutBuilder(
  //       builder: (context, constraints) {
  //         final cellSize = constraints.maxWidth / 7;
  //         final gridHeight = cellSize * 6; // Height to fit all rows

  //         return Column(
  //           children: [
  //             _buildWeekdayHeader(cellSize, textColor),
  //             Container(
  //               height: gridHeight + 40, // Add some extra padding for safety
  //               child: PageView.builder(
  //                 controller: _pageController,
  //                 onPageChanged: _onPageChanged,
  //                 itemBuilder: (context, page) {
  //                   final monthToShow = DateTime(
  //                     DateTime.now().year,
  //                     DateTime.now().month + (page - 1000),
  //                   );
  //                   final daysToShow = _getDaysInMonth(monthToShow);
  //                   return _buildCalendarGrid(
  //                       daysToShow,
  //                       cellSize,
  //                       cellColor,
  //                       todayBackgroundColor,
  //                       todayColor,
  //                       borderColor,
  //                       textColor,
  //                       currentMonthColor);
  //                 },
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

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

  // Widget _buildCalendarGrid(
  //     List<DateTime> days,
  //     double cellSize,
  //     Color cellColor,
  //     Color todayBackgroundColor,
  //     Color todayColor,
  //     Color borderColor,
  //     Color textColor,
  //     Color currentMonthColor) {
  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: ScrollPhysics(),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 7,
  //       childAspectRatio: 1.0, // Ensures square cells
  //     ),
  //     itemCount: days.length,
  //     itemBuilder: (context, index) {
  //       final date = days[index];
  //       final isCurrentMonth = date.month == _currentMonth.month;
  //       final isToday = date.year == DateTime.now().year &&
  //           date.month == DateTime.now().month &&
  //           date.day == DateTime.now().day;

  //       return GestureDetector(
  //         onTap: () {
  //           if (widget.onDateSelected != null) {
  //             widget.onDateSelected!(date);
  //           }
  //         },
  //         child: Container(
  //           width: cellSize, // Explicitly set width
  //           height: cellSize, // Explicitly set height to ensure square
  //           decoration: BoxDecoration(
  //             border: Border.all(color: borderColor),
  //             color: isToday ? todayBackgroundColor : cellColor,
  //           ),
  //           child: Center(
  //             child: Text(
  //               '${date.day}',
  //               style: TextStyle(
  //                 color: isToday
  //                     ? todayColor
  //                     : (isCurrentMonth ? currentMonthColor : textColor),
  //                 fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
  //                 fontSize: cellSize * 0.25,
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
