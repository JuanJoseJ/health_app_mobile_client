import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/dates_util.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:provider/provider.dart';

class ActivityBottomWidget extends StatelessWidget {
  const ActivityBottomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDataProv, child) {
      DateTime startDate = hDataProv.currentDate;
      DateTime? endDate;

      int activity = 0;
      String textSuffix = '';

      switch (hDataProv.currentTopBarSelect) {
        case 'day':
          // Calculate total activity for the day
          activity = getTotalActivityForDay(startDate,
              hDataProv.currentActivityDataPoints, HealthDataType.MOVE_MINUTES);
          break;
        case 'week':
          startDate = startDate.subtract(Duration(days: startDate.weekday - 1));
          endDate = startDate.add(const Duration(days: 7));
          activity = getMeanActivity(startDate, endDate,
              hDataProv.currentActivityDataPoints, HealthDataType.MOVE_MINUTES);
          // textSuffix = ' (avg)';
          break;
        case 'month':
          startDate = DateTime(startDate.year, startDate.month, 1);
          endDate = DateTime(startDate.year, startDate.month + 1, 0);
          activity = getMeanActivity(startDate, endDate,
              hDataProv.currentActivityDataPoints, HealthDataType.MOVE_MINUTES);
          // textSuffix = ' (avg)';
          break;
      }

      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${formatDuration(activity.toDouble())} $textSuffix",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }

  int getTotalActivityForDay(DateTime date, List<DefaultDataPoint> dataPoints,
      HealthDataType activityType) {
    int totalActivity = 0;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    for (DefaultDataPoint dataPoint in dataPoints) {
      if (dataPoint.dateFrom.isAfter(startOfDay) &&
          dataPoint.dateFrom.isBefore(endOfDay) &&
          dataPoint.type == activityType) {
        totalActivity++; // Increment by 1 for each data point; adjust as necessary for your data
      }
    }

    return totalActivity;
  }

  int getMeanActivity(DateTime startDate, DateTime? endDate,
      List<DefaultDataPoint> dataPoints, HealthDataType activityType) {
    int totalActivity = 0;
    // ignore: unused_local_variable
    int daysCounted = 0;
    DateTime currentDate = startDate;

    // If no endDate is provided or it's in the future, set it to today's date
    DateTime today = DateTime.now();
    endDate = endDate == null || endDate.isAfter(today)
        ? DateTime(today.year, today.month, today.day)
        : endDate;

    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      // Add one day to include the endDate in the loop
      final startOfDay =
          DateTime(currentDate.year, currentDate.month, currentDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      for (DefaultDataPoint dataPoint in dataPoints) {
        if (dataPoint.dateFrom.isAfter(startOfDay) &&
            dataPoint.dateFrom.isBefore(endOfDay) &&
            dataPoint.type == activityType) {
          totalActivity++; // Increment by 1 for each data point; adjust as necessary for your data
        }
      }

      currentDate = endOfDay;
      daysCounted++;
    }

    // Calculate mean activity per day based on the actual number of days counted
    // return daysCounted > 0 ? totalActivity ~/ daysCounted : 0;
    return totalActivity;
  }
}
