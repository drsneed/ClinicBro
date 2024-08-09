class CalendarGrid {
  List<DateTime> days = [];
  int numberOfRows = 0;

  CalendarGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    var weekday = firstDayOfMonth.weekday;
    if (firstDayOfMonth.weekday == 7) weekday = 0;
    final firstDayOfGrid = firstDayOfMonth.subtract(Duration(days: weekday));
    var currentDay = firstDayOfGrid;
    numberOfRows = 0;
    // if (month.year == 2026 && month.month == 2) {
    //   print('Found feb 2026. currentDay = $currentDay');
    //   print('First day of month = $firstDayOfMonth');
    //   print('First day of grid = $firstDayOfGrid');
    // }
    for (int week = 0; week < 6; week++) {
      List<DateTime> weekDays = [];
      // If the last row contains days from the next month, skip it
      if (week > 0 && currentDay.month != month.month) {
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
