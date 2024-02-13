import 'package:health_app_mobile_client/util/default_data_util.dart';

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

bool isDataPointWithinRange({
  required DefaultDataPoint dataPoint,
  required DateTime rangeStart,
  DateTime? rangeEnd,
}) {
  // Adjust rangeEnd if it's null to cover the whole day of rangeStart
  rangeEnd ??=
      DateTime(rangeStart.year, rangeStart.month, rangeStart.day, 23, 59, 59);

  // If dateTo is not null, check if the range overlaps
  if (dataPoint.dateTo != null) {
    return dataPoint.dateFrom.isBefore(rangeEnd) &&
        dataPoint.dateTo!.isAfter(rangeStart);
  }

  // If dateTo is null, check if dateFrom is within the range
  return dataPoint.dateFrom.isAfter(rangeStart) &&
      dataPoint.dateFrom.isBefore(rangeEnd);
}

String formatDuration(double totalMinutes) {
  int hours = totalMinutes ~/ 60; // Use integer division to get the whole hours
  double minutes = totalMinutes % 60; // Use modulo to get the remaining minutes

  return "${hours}h ${minutes.toInt()}min";
}