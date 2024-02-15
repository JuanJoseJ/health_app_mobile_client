import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:provider/provider.dart';

class StressChart extends StatefulWidget {
  const StressChart({super.key});

  @override
  State<StatefulWidget> createState() => StressChartState();
}

class StressChartState extends State {
  bool sectionTchd = false;
  final double widthFraction = 1 / 2;

  List<PieChartSectionData> showingSections(
      double widthFraction, double stressPoints) {
    return [
      PieChartSectionData(
        color: Colors.deepPurpleAccent,
        value: stressPoints,
        title: '${stressPoints.round()}pts',
        showTitle: true,
        radius: (sectionTchd ? 100 : 80) * (1 - widthFraction),
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.redAccent.withOpacity(0.2),
        value: (100 - stressPoints),
        title: '',
        radius: 80 * (1 - widthFraction),
      )
    ];
  }

  PieTouchData pieTouchData() {
    return PieTouchData(
      touchCallback: (FlTouchEvent event, pieTouchResponse) {
        setState(() {
          if (event is FlPointerHoverEvent) {
            sectionTchd = true;
          } else if (event is FlTapUpEvent ||
              event is FlLongPressEnd ||
              event is FlLongPressMoveUpdate ||
              event is FlPanEndEvent) {
            sectionTchd = false;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the centerSpaceRadius based on a percentage of the screen width
    double centerSpaceRadiusPercentage = 0.2;
    double centerSpaceRadius =
        screenWidth * centerSpaceRadiusPercentage * widthFraction;

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

      return PieChart(
        PieChartData(
            pieTouchData: pieTouchData(),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 2,
            centerSpaceRadius: centerSpaceRadius,
            sections: showingSections(widthFraction, stressPoints),
            startDegreeOffset: 180),
      );
    });
  }
}

double calcStressPoints(double totalActivityMinutes, double totalSleepMinutes,
    double totalCalories, double totalHRV) {
  // Normalize each metric to a 0 to 1 scale
  // The normalization functions (normalizeActivity, normalizeSleep, normalizeCalories, normalizeHRV)
  // need to be defined based on your data and how you want them to impact the stress score

  double normalizedActivity = normalizeActivity(totalActivityMinutes);
  double normalizedSleep = normalizeSleep(totalSleepMinutes);
  double normalizedCalories = normalizeCalories(totalCalories);
  double normalizedHRV = normalizeHRV(totalHRV);

  double activityWeight = 1;
  double sleepWeight = 2;
  double caloriesWeight = -0.5;
  double hrvWeight = 1;

  // Calculate stress score as an average of the normalized metrics, subtracted from 1
  double stressScore = (normalizedActivity * activityWeight +
          normalizedSleep * sleepWeight +
          normalizedCalories * caloriesWeight +
          normalizedHRV * hrvWeight) /
      4;

  // Convert to a 0 to 100 scale
  stressScore *= 100;

  return stressScore;
}

// Example normalization function for activity
// This should be adjusted based on empirical data and desired impact on stress score
double normalizeActivity(double totalActivityMinutes) {
  // Assuming 30 minutes of activity is ideal (0.5 on the scale)
  // Adjust these values based on your requirements
  const double idealActivityMinutes = 30;
  return (totalActivityMinutes / (2 * idealActivityMinutes)).clamp(0, 1);
}

// Define similar normalization functions for sleep, calories, and HRV
double normalizeSleep(double totalSleepMinutes) {
  // Example normalization logic
  return (totalSleepMinutes / (2 * 480))
      .clamp(0, 1); // Assuming 8 hours (480 minutes) is ideal
}

double normalizeCalories(double totalCalories) {
  // Example normalization logic
  return (totalCalories / 2000).clamp(0, 1); // Assuming 2000 calories is ideal
}

double normalizeHRV(double totalHRV) {
  // Example normalization logic
  // HRV normalization might be more complex due to its nature and might require more sophisticated statistical methods
  return totalHRV /
      100; // Placeholder normalization, adjust based on your HRV data distribution and impact on stress
}
