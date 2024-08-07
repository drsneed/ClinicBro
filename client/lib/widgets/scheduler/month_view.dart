import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _pageController = PageController(initialPage: 1000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMonthChanged(_currentMonth);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = <DateTime>[];

    for (var i = 0; i < 42; i++) {
      final date = firstDayOfMonth
          .subtract(Duration(days: firstDayOfMonth.weekday - 1))
          .add(Duration(days: i));
      daysInMonth.add(date);
    }

    return daysInMonth;
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + (page - 1000));
    });
    widget.onMonthChanged(_currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final cellWidth = constraints.maxWidth / 7;
        final cellHeight = (availableHeight - 20) / 7;

        return Column(
          children: [
            _buildWeekdayHeader(cellWidth),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, page) {
                  final monthToShow = DateTime(
                      _currentMonth.year, _currentMonth.month + (page - 1000));
                  final daysToShow = _getDaysInMonth(monthToShow);
                  return _buildCalendarGrid(daysToShow, cellWidth, cellHeight);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekdayHeader(double cellWidth) {
    return Container(
      height: 20,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: cellWidth / 20,
        ),
        itemCount: 7,
        itemBuilder: (context, index) {
          final weekday = ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index];
          return Center(
            child: Text(
              weekday,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(
      List<DateTime> days, double cellWidth, double cellHeight) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: cellWidth / cellHeight,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        final isCurrentMonth = date.month == _currentMonth.month;
        final isToday = date.isAtSameMomentAs(DateTime.now());

        return GestureDetector(
          onTap: () {
            if (widget.onDateSelected != null) {
              widget.onDateSelected!(date);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: isToday ? Colors.blue.shade100 : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isCurrentMonth ? Colors.black : Colors.grey,
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
}
