import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app_mobile_client/charts/chart_stress_by_day.dart';
import 'package:health_app_mobile_client/charts/side_tittle_widgets/bottom_tittle_widgets.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/fit_bit_data_service.dart';
import 'package:health_app_mobile_client/services/google_fit_data_service.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StressByPeriodChart extends StatefulWidget {
  final Widget Function(double, TitleMeta)? bottomTittleWidget;
  final int nPeriods;
  const StressByPeriodChart(
      {super.key, this.bottomTittleWidget, required this.nPeriods});

  @override
  State<StressByPeriodChart> createState() => _StressByPeriodChartState();
}

class _StressByPeriodChartState extends State<StressByPeriodChart> {
  final List<Color> dailyActivityRodColors = [
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.deepOrange,
  ];

  FlTitlesData? myTitlesData(BuildContext context, HomeDataProvider hdp) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: FittedBox(
          fit: BoxFit.scaleDown,
          child: IntrinsicWidth(
            child: Text(
              "Points",
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        sideTitles: const SideTitles(
          getTitlesWidget: leftTitleWidgets,
          showTitles: true,
          // interval: 5,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          getTitlesWidget: selectbottomTittleWidget(hdp),
          showTitles: true,
          interval: 1,
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  Widget Function(double value, TitleMeta meta) selectbottomTittleWidget(
      HomeDataProvider hdp) {
    late Widget Function(double value, TitleMeta meta) btw;
    switch (hdp.currentTopBarSelect) {
      case "day":
        btw = dailyThirdsBTW;
        break;
      case "week":
        btw = weeklyThirdsBTW();
        break;
      case "month":
        btw = monthlyThirdsBTW(hdp.currentDate);
        break;
      default:
    }
    return btw;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      // Determine the start and end dates based on the current selection
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

      List<BarChartGroupData> thisBarCharts = genBarChartDataGroups(
          hdp, widget.nPeriods, startDate, endDate, dailyActivityRodColors);
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
        child: BarChart(
          BarChartData(
            barGroups: thisBarCharts,
            titlesData: myTitlesData(context, hdp),
            // barTouchData: myBarTouchData(context, hDataProvider),
            borderData: FlBorderData(
              show: false,
            ),
          ),
        ),
      );
    });
  }
}

Widget leftTitleWidgets(double value, TitleMeta meta) {
  return Text(
    (value % meta.appliedInterval == 0)
        ? value.toStringAsFixed(0)
        : '', // Only show titles on the same period
    style: const TextStyle(
      color: Colors.black54,
      fontSize: 9,
    ),
    textAlign: TextAlign.center,
  );
}

BarTouchData? myBarTouchData(
    BuildContext context, HomeDataProvider hDataProvider) {
  return BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      fitInsideVertically: true,
      fitInsideHorizontally: true,
      maxContentWidth: 70,
      tooltipPadding: const EdgeInsets.all(4),
      tooltipBgColor: const Color.fromARGB(255, 236, 236, 236).withOpacity(0.9),
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        String timeText = '';
        DateTime startDate = DateTime(
            hDataProvider.currentMinDate.year,
            hDataProvider.currentMinDate.month,
            hDataProvider.currentMinDate.day);

        switch (hDataProvider.currentTopBarSelect) {
          case "day":
            switch (groupIndex) {
              case 0:
                timeText = "Morning";
                break;
              case 1:
                timeText = "Afternoon";
                break;
              case 2:
                timeText = "Night";
                break;
              default:
                timeText = "";
                break;
            }
            break;
          case "week":
            timeText = DateFormat('EEEE')
                .format(startDate.add(Duration(days: groupIndex)));
            break;
          case "month":
            timeText = DateFormat('EEEE d')
                .format(startDate.add(Duration(days: groupIndex)));
            break;
        }

        return BarTooltipItem(
          "${rod.toY} min. $timeText",
          const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
        );
      },
    ),
  );
}

List<BarChartGroupData> genBarChartDataGroups(
    HomeDataProvider hdp, int nPeriods, DateTime startDate, DateTime endDate,
    [List<Color>? barColors]) {
  List<BarChartGroupData> tempBarCharts = [];
  List<double> pointsList = List<double>.filled(nPeriods, 0);

  final activityList = GoogleFitDataService().getActivityByPeriods(
      nPeriods, hdp.currentActivityDataPoints, startDate, endDate);
  final sleepList =
      getSleepByPeriods(nPeriods, hdp.currentSleepDataPoints, startDate);
  final caloriesList = getCaloriesByPeriod(
      nPeriods, hdp.currentNutritionDataPoints, startDate, endDate);
  final hrvList = getHRVByPeriod(nPeriods, hdp.currentHRVDataPoints, startDate, endDate);

  for (var i = 0; i < pointsList.length; i++) {
    pointsList[i] = calcStressPoints(
        activityList[i].toDouble(),
        sleepList[i].toDouble(),
        caloriesList[i].toDouble(),
        hrvList[i].toDouble());
  }

  barColors ??= [Colors.deepPurpleAccent];

  for (int i = 0; i < pointsList.length; i++) {
    var value = pointsList[i];
    var color = barColors[i % barColors.length];

    tempBarCharts.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
          ),
        ],
      ),
    );
  }

  return tempBarCharts;
}

List<int> getSleepByPeriods(
    int nPeriods, List<DefaultDataPoint> dataPoints, DateTime startDate,
    [DateTime? endDate]) {
  List<int> sleepList = List<int>.filled(nPeriods, 0);
  DateTime currentEndDate = startDate.add(const Duration(hours: 24));
  for (var i = 0; i < nPeriods; i++) {
    currentEndDate = currentEndDate.add(const Duration(hours: 24));
    double sleep = FitBitDataService()
        .getTotalSleepByPeriod(dataPoints, startDate, currentEndDate);
    sleepList[i] = sleep.toInt();
  }

  return sleepList;
}

List<int> getCaloriesByPeriod(
  int nPeriods,
  List<DefaultDataPoint> caloriesDataPoints,
  DateTime startDate,
  DateTime endDate,
) {
  List<int> calList = List<int>.filled(nPeriods, 0);
  int i = 0;  
  for (DefaultDataPoint p in caloriesDataPoints) {

    if (p.dateFrom.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
        p.dateFrom.isBefore(endDate)) {
      calList[i] = double.parse(p.value.toString()).toInt();
      i++;
    }
  }

  return calList;
}

List<int> getHRVByPeriod(
  int nPeriods,
  List<DefaultDataPoint> hrvDataPoints,
  DateTime startDate,
  DateTime endDate,
) {
  List<int> hrvList = List<int>.filled(nPeriods, 0);
  int i = 0;
  for (DefaultDataPoint p in hrvDataPoints) {
    if (p.dateFrom.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
        p.dateFrom.isBefore(endDate)) {
      hrvList[i] = double.parse(p.value.toString()).toInt();
      i++;
    }
  }

  return hrvList;
}
