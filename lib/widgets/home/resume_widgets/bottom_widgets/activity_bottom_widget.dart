import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
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

int getTotalDailyActivity(DateTime date, List<HealthDataPoint> moveMinutes) {
  int totalMoveMinutes = 0;
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endtOfDay = startOfDay.add(const Duration(days: 1));

  for (HealthDataPoint dataPoint in moveMinutes) {
    if (dataPoint.dateFrom.isAfter(startOfDay) &&
        dataPoint.dateFrom.isBefore(endtOfDay) && dataPoint.type==HealthDataType.MOVE_MINUTES) {
      totalMoveMinutes++;
    }
  }
  print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1");
  print("$totalMoveMinutes");
  return totalMoveMinutes;
}
