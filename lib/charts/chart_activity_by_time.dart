import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/pages/my_home_page.dart';
import 'package:health_app_mobile_client/services/health_data_service.dart';
import 'package:provider/provider.dart';

class ActivityChart extends StatefulWidget {
  final String leftTitle;
  final String bottomTitle;
  const ActivityChart(
      {super.key, required this.leftTitle, required this.bottomTitle});

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  // final hds = HealthDataService();
  final List<MaterialAccentColor> dailyActivityRodColors = [
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.blueAccent
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDateProvider>(builder: (context, hDataProvider, child) {
      List<BarChartGroupData> thisBarCharts = genBarChartDataGroups(
          hDataProvider.currentDataPoints,
          3,
          hDataProvider.currentDate,
          dailyActivityRodColors);
      return BarChart(
        BarChartData(
          barGroups: thisBarCharts,
          titlesData: myTilesData(context, widget.leftTitle),
          barTouchData: myBarTouchData(context),
          borderData: FlBorderData(
            show: false,
          ),
        ),
      );
    });
  }
}

FlTitlesData? myTilesData(BuildContext context, String leftTitle) {
  return FlTitlesData(
    leftTitles: AxisTitles(
      axisNameWidget: Text(
        leftTitle,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      sideTitles: const SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        // interval: 5,
      ),
    ),
    bottomTitles: const AxisTitles(
      sideTitles: SideTitles(
        getTitlesWidget: bottomTitleWidgets,
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

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  final Widget text;
  switch (value.toInt()) {
    case 0:
      text = const Icon(
        Icons.wb_twighlight,
        size: 18.0,
        color: Colors.black54,
      );
      break;
    case 1:
      text = const Icon(
        Icons.wb_sunny,
        size: 18.0,
        color: Colors.black54,
      );
      break;
    case 2:
      text = const Icon(
        Icons.nightlight,
        size: 16.0,
        color: Colors.black54,
      );
      break;
    default:
      text = const Icon(
        Icons.wb_sunny,
        size: 20.0,
        color: Colors.black54,
      );
      break;
  }

  return text;
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

BarTouchData? myBarTouchData(BuildContext context) {
  String timeText;
  return BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      fitInsideVertically: true,
      fitInsideHorizontally: true,
      maxContentWidth: 70,
      tooltipPadding: const EdgeInsets.all(4),
      tooltipBgColor: Color.fromARGB(255, 236, 236, 236).withOpacity(0.9),
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        switch (groupIndex) {
          case 0:
            timeText = "morning";
            break;
          case 1:
            timeText = "afternoon";
            break;
          case 2:
            timeText = "night";
            break;
          default:
            timeText = "";
            break;
        }
        return BarTooltipItem(
          "${group.barRods[0].toY} minutes in the $timeText",
          const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
        );
      },
    ),
  );
}

/// Generates a list of [BarChartGroupData] based on health data points.
///
/// This function takes a list of [HealthDataPoint] objects [hDataPoints],
/// an integer [nPeriods] representing the number of periods in which to accumulate
/// the activity, a [DateTime] [date]for the specific date, and an optional list
/// of [Color]s [barColors] for customizing the colors of the bars.
/// If [barColors] is not provided, a default color of [Colors.blueAccent] will be used.
///
/// The function calculates the activity periods using the [HealthDataService],
/// assigns colors to the bars based on the provided [barColors], and returns
/// a list of [BarChartGroupData].
List<BarChartGroupData> genBarChartDataGroups(List<HealthDataPoint> hDataPoints,
    int nPeriods, DateTime date, List<Color>? barColors) {
  // !!!!!!!!!!!!!! Modify this function to accept a list of dates
  // so that multiple dates can be  taken into account to accumulate the work
  List<BarChartGroupData> tempBarCharts = [];

  List<int> periods = HealthDataService()
      .getDailyActivityByPeriods(nPeriods, date, hDataPoints);

  // Default color if barColors is not provided
  barColors ??= [Colors.blueAccent];

  for (int i = 0; i < periods.length; i++) {
    var value = periods[i];
    var color =
        barColors[i % barColors.length]; // Handle color assignment logic

    tempBarCharts.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: color,
          ),
        ],
      ),
    );
  }

  return tempBarCharts;
}
