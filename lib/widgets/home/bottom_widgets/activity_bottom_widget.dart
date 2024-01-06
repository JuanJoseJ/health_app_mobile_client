import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/pages/my_home_page.dart';
import 'package:provider/provider.dart';

class ActivityBottomWidget extends StatelessWidget {
  const ActivityBottomWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDataProv, child) {
      int totMinutes = getTotalDailyActivity(
          hDataProv.currentDate, hDataProv.currentDataPoints);
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "$totMinutes minutes",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }
}

int getTotalDailyActivity(
    DateTime date, List<HealthDataPoint> moveMinutes) {
  int totalMoveMinutes = 0;
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endtOfDay =
      DateTime(date.year, date.month, date.day).add(const Duration(days: 1));

  // Iterate over the data and accumulate the values for each period
  for (HealthDataPoint dataPoint in moveMinutes) {
    if (dataPoint.dateFrom.isAfter(startOfDay) &&
        dataPoint.dateFrom.isBefore(endtOfDay)) {
      totalMoveMinutes++;
    }
  }
  return totalMoveMinutes;
}