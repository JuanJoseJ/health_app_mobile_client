bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

List<DateTime> calcPeriods(int nPeriods, DateTime startDate,
    [DateTime? endDate]) {
      
  // If endDate is not provided, set it to the end of startDate's day
  endDate ??=
      DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);

  // Calculate the total duration in seconds
  int totalDurationSeconds = endDate.difference(startDate).inSeconds;

  // Calculate the duration of each period in seconds
  int periodDurationSeconds = (totalDurationSeconds / nPeriods).round();

  // Generate the list of period start times
  List<DateTime> periods = List.generate(nPeriods + 1, (i) {
    return startDate.add(Duration(seconds: periodDurationSeconds * i));
  });
  return periods;
}