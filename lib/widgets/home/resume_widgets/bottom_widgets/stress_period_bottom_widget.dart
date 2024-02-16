import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_stress_by_day.dart';
import 'package:health_app_mobile_client/charts/chart_stress_by_period.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/google_fit_data_service.dart';
import 'package:provider/provider.dart';

class StressPeriodsBottomWidget extends StatelessWidget {
  final int nPeriods;
  const StressPeriodsBottomWidget({super.key, required this.nPeriods});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      DateTime startDate = DateTime(
          hdp.currentDate.year, hdp.currentDate.month, hdp.currentDate.day);
      DateTime endDate;
      switch (hdp.currentTopBarSelect) {
        case 'week':
          int weekday = startDate.weekday;
          startDate = startDate.subtract(Duration(days: weekday - 1));
          endDate = startDate
              .add(const Duration(days: 7))
              .subtract(const Duration(seconds: 1));
          break;
        case 'month':
          startDate = DateTime(startDate.year, startDate.month, 1);
          endDate = DateTime(startDate.year, startDate.month + 1, 1)
              .subtract(const Duration(seconds: 1));
          break;
        default:
          endDate = startDate.add(const Duration(days: 1));
      }

      double stressPoints = 0;

      final activityList = GoogleFitDataService().getActivityByPeriods(
          nPeriods, hdp.currentActivityDataPoints, startDate, endDate);
      final sleepList =
          getSleepByPeriods(nPeriods, hdp.currentSleepDataPoints, startDate);
      final caloriesList = getCaloriesByPeriod(
          nPeriods, hdp.currentNutritionDataPoints, startDate, endDate);
      final hrvList = getHRVByPeriod(
          nPeriods, hdp.currentHRVDataPoints, startDate, endDate);

      for (var i = 0; i < nPeriods; i++) {
        stressPoints += calcStressPoints(
            activityList[i].toDouble(),
            sleepList[i].toDouble(),
            caloriesList[i].toDouble(),
            hrvList[i].toDouble());
      }

      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${(stressPoints/nPeriods).ceil()} stress pts(avg)",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }
}
