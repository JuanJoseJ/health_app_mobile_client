import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_stress_by_day.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:provider/provider.dart';

class StressBottomWidget extends StatelessWidget {
  const StressBottomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      DateTime currentStartDate = DateTime(
          hdp.currentDate.year, hdp.currentDate.month, hdp.currentDate.day);
      DateTime currentEndDate = currentStartDate.add(const Duration(hours: 24));

      double totalActivityMinutes = 0;
      for (DefaultDataPoint p in hdp.currentActivityDataPoints) {
        if (p.dateFrom.isAfter(
                currentStartDate.subtract(const Duration(seconds: 1))) &&
            p.dateTo!.isBefore(currentEndDate)) {
          totalActivityMinutes += double.parse(p.value.toString());
        }
      }
      double totalSleepMinutes = 0;
      for (DefaultDataPoint p in hdp.currentSleepDataPoints) {
        if (p.dateFrom.isAfter(currentStartDate
                .subtract(const Duration(seconds: 1, hours: 6))) &&
            p.dateTo!.isBefore(currentEndDate)) {
          totalSleepMinutes += double.parse(p.value.toString());
        }
      }
      double totalCalories = 0;
      for (DefaultDataPoint p in hdp.currentNutritionDataPoints) {
        if (p.dateFrom.isAfter(
                currentStartDate.subtract(const Duration(seconds: 1))) &&
            p.dateFrom.isBefore(currentEndDate)) {
          totalCalories += double.parse(p.value.toString());
        }
      }
      double totalHRV = 0;
      for (DefaultDataPoint p in hdp.currentHRVDataPoints) {
        if (p.dateFrom.isAfter(
                currentStartDate.subtract(const Duration(seconds: 1))) &&
            p.dateFrom.isBefore(currentEndDate)) {
          totalHRV += double.parse(p.value.toString());
        }
      }

      final double stressPoints = calcStressPoints(
          totalActivityMinutes, totalSleepMinutes, totalCalories, totalHRV);

      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${stressPoints.round()} stress pts",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }

  int getTotalCalories(List<DefaultDataPoint> foodDataPoints) {
    int totCalories = 0;
    for (DefaultDataPoint p in foodDataPoints) {
      totCalories += double.parse(p.value.toString()).toInt();
    }
    return totCalories;
  }
}
