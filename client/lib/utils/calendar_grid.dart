class CalendarGrid {
  List<DateTime> days = [];
  int numberOfRows = 0;

  CalendarGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstDayOfGrid =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday));
    var currentDay = firstDayOfGrid;
    numberOfRows = 0;

    for (int week = 0; week < 6; week++) {
      List<DateTime> weekDays = [];
      // If the last row contains days from the next month, skip it
      if (week == 5 && currentDay.month != month.month) {
        break;
      }
      for (int day = 0; day < 7; day++) {
        weekDays.add(currentDay);
        currentDay = currentDay.add(const Duration(days: 1));
      }

      days.addAll(weekDays);
      numberOfRows++;
    }
  }
}
