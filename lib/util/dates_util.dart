bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

List<DateTime> calcPeriods(int nPeriods, DateTime start, [DateTime? end]) {
  // Ensure there's at least one period
  if (nPeriods < 1) nPeriods = 1;

  final List<DateTime> periods = [];
  Duration totalDuration;

  if (end != null) {
    // If an end date is provided, calculate the total duration between the start and end dates
    totalDuration = end.difference(start);
  } else {
    // If no end date is provided, assume a single day and calculate the duration for 24 hours
    totalDuration = Duration(hours: 24);
    end = start.add(totalDuration);
  }

  for (int i = 0; i <= nPeriods; i++) {
    // Calculate the fraction of the total duration for each period
    double fractionOfTotalDuration =
        totalDuration.inMilliseconds * i / nPeriods;
    // Add each period's start time to the list
    periods.add(
        start.add(Duration(milliseconds: fractionOfTotalDuration.round())));
  }

  // If dividing multiple days, ensure the last period starts at the exact end time
  if (end != null && periods.last != end) {
    periods.removeLast();
    periods.add(end);
  }
  return periods;
}