bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

  /// Generate the periods of time, as a list of hours [initial, end1, end2, ...]
  /// each period is represented by [i, i+1]
List<DateTime> calcPeriods(int nPeriods, DateTime startOfDay){
  final List<DateTime> periods = List.generate(nPeriods + 1, (index) {
      final valueToAdd = ((index * 24) / nPeriods);
      double minutes = (valueToAdd - valueToAdd.floor()) * 60;
      return startOfDay
          .add(Duration(hours: valueToAdd.floor(), minutes: minutes.toInt()));
    });
  return periods;
}