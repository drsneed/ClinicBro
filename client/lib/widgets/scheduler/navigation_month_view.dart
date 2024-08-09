import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

import '../../utils/calendar_grid.dart';
import '../../utils/logger.dart';

class NavigationMonthView extends StatefulWidget {
  final DateTime initialDate;
  final List<DateTime> appointmentDates;
  final List<DateTime> selectedDates;
  final Function(DateTime) onDaySelected;

  const NavigationMonthView({
    Key? key,
    required this.initialDate,
    required this.appointmentDates,
    required this.selectedDates,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  _NavigationMonthViewState createState() => _NavigationMonthViewState();
}

class _NavigationMonthViewState extends State<NavigationMonthView> {
  late DateTime _currentMonth;
  late CalendarGrid _calendarGrid;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _calendarGrid = CalendarGrid(_currentMonth);
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final cellColor = theme.cardColor;
    final todayColor = Colors.white;
    final borderColor = theme.cardColor;
    final textColor = theme.inactiveColor.withOpacity(0.1);
    final todayBackgroundColor = theme.accentColor;
    final currentMonthColor = theme.inactiveColor.withOpacity(0.5);
    final appointmentColor = theme.inactiveColor.withOpacity(0.8);
    final headerText = DateFormat('MMMM yyyy').format(_currentMonth);

    return Container(
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
                      color: theme.inactiveColor.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildWeekdayHeader(
                    cellWidth, theme.inactiveColor.withOpacity(0.7)),
                Container(
                  height: gridHeight, // Add some extra padding for safety
                  child: _buildCalendarGrid(
                      cellWidth,
                      cellHeight,
                      cellColor,
                      todayBackgroundColor,
                      todayColor,
                      borderColor,
                      textColor,
                      currentMonthColor,
                      appointmentColor),
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
    Color currentMonthColor,
    Color appointmentColor,
  ) {
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
        final hasAppointment = isCurrentMonth &&
            widget.appointmentDates.any((appointmentDate) =>
                appointmentDate.year == date.year &&
                appointmentDate.month == date.month &&
                appointmentDate.day == date.day);

        final isSelected = isCurrentMonth &&
            widget.selectedDates.any((selectedDate) =>
                selectedDate.year == date.year &&
                selectedDate.month == date.month &&
                selectedDate.day == date.day);

        return GestureDetector(
          onTap: () {
            widget.onDaySelected(date);
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
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isToday
                          ? todayColor
                          : (hasAppointment
                              ? appointmentColor
                              : (isCurrentMonth
                                  ? currentMonthColor
                                  : textColor)),
                      fontWeight: hasAppointment || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: cellWidth * 0.4,
                    ),
                  ),
                ),
                if (isSelected) // Apply overlay if selected
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2), // Tinted overlay
                      ),
                    ),
                  ),
              ],
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
