import 'package:fluent_ui/fluent_ui.dart';
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

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = <DateTime>[];

    final firstDayOfGrid =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));

    for (var i = 0; i < 42; i++) {
      final date = firstDayOfGrid.add(Duration(days: i));
      daysInMonth.add(date);
    }

    return daysInMonth;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final cellWidth = constraints.maxWidth / 7;
        final cellHeight = availableHeight / 6;

        return Column(
          children: [
            _buildWeekdayHeader(cellWidth, textColor),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, page) {
                  final monthToShow = DateTime(
                    DateTime.now().year,
                    DateTime.now().month + (page - 1000),
                  );
                  final daysToShow = _getDaysInMonth(monthToShow);
                  return _buildCalendarGrid(
                      daysToShow,
                      cellWidth,
                      cellHeight,
                      cellColor,
                      todayBackgroundColor,
                      todayColor,
                      borderColor,
                      textColor,
                      currentMonthColor);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekdayHeader(double cellWidth, Color textColor) {
    return Container(
      height: 20,
      child: Row(
        children: List.generate(7, (index) {
          final weekday = ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index];
          return Container(
            width: cellWidth,
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

  Widget _buildCalendarGrid(
      List<DateTime> days,
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
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
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
}
