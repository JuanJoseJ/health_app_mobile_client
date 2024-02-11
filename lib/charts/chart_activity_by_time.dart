import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/charts/side_tittle_widgets/bottom_tittle_widgets.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/google_fit_data_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityChart extends StatefulWidget {
  final String? leftTitle;
  final String? bottomTitle;
  final Widget Function(double, TitleMeta)? bottomTittleWidget;
  final int nPeriods;
  const ActivityChart(
      {super.key,
      this.leftTitle,
      this.bottomTitle,
      this.bottomTittleWidget,
      required this.nPeriods});

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

  FlTitlesData? myTitlesData(BuildContext context, HomeDataProvider hdp) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: widget.leftTitle != null
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: IntrinsicWidth(
                  child: Text(
                    widget.leftTitle!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.visible,
                  ),
                ),
              )
            : const Row(),
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
    return Consumer<HomeDataProvider>(builder: (context, hDataProvider, child) {
      // Determine the start and end dates based on the current selection
      DateTime startDate = hDataProvider.currentDate;
      DateTime? endDate;

      switch (hDataProvider.currentTopBarSelect) {
        case 'day':
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          endDate = null;
          break;
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
          endDate = startDate.add(const Duration(
              days: 1)); // Default to one day if the selection is unrecognized
      }
      // Generate bar chart data groups based on the calculated start and end dates
      
      List<BarChartGroupData> thisBarCharts = genBarChartDataGroups(
          hDataProvider.currentDataPoints,
          widget.nPeriods,
          startDate,
          dailyActivityRodColors,
          endDate);

      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: BarChart(
          BarChartData(
            barGroups: thisBarCharts,
            titlesData: myTitlesData(context, hDataProvider),
            barTouchData: myBarTouchData(context, hDataProvider),
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
        DateTime startDate = hDataProvider.currentDate;

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
            DateTime weekDate =
                DateTime(startDate.year, startDate.month, groupIndex - 2);
            timeText = DateFormat('EEEE').format(weekDate);
            break;
          case "month":
            DateTime monthDate =
                DateTime(startDate.year, startDate.month, groupIndex + 1);
            timeText = DateFormat('EEEE d')
                .format(monthDate); // Just the day of the month
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

/// Generates a list of `BarChartGroupData` for use in a bar chart, based on health data points.
///
/// This function takes a list of `HealthDataPoint` objects, a number of periods to divide the data into,
/// a start date, and optionally, a list of colors for the bars and an end date. It divides the time range
/// between the start and end dates (or the 24 hours starting from the start date if no end date is provided)
/// into the specified number of periods. It then calculates the activity level for each period based on the
/// health data points provided. Each period's activity level is represented as a bar in the bar chart.
///
/// The bars are colored using the provided list of colors, cycling through the list if there are more bars
/// than colors. If no colors are provided, a default color of `Colors.blueAccent` is used for all bars.
///
/// Parameters:
/// - `hDataPoints`: The list of `HealthDataPoint` objects containing the health data to be represented.
/// - `nPeriods`: The number of periods to divide the data into. Each period will correspond to one bar in the bar chart.
/// - `startDate`: The start date of the range of data to be represented.
/// - `barColors` (optional): A list of `Color` objects to use for coloring the bars in the bar chart. If not provided,
///   a default color is used.
/// - `endDate` (optional): The end date of the range of data to be represented. If not provided, the range is assumed
///   to be 24 hours starting from `startDate`.
///
/// Returns:
/// A list of `BarChartGroupData` objects, each representing a bar in the bar chart for a specific period,
/// with its height corresponding to the activity level calculated for that period.
List<BarChartGroupData> genBarChartDataGroups(
    List<HealthDataPoint> hDataPoints, int nPeriods, DateTime startDate,
    [List<Color>? barColors, DateTime? endDate]) {
  List<BarChartGroupData> tempBarCharts = [];
  List<int> periods = GoogleFitDataService()
      .getActivityByPeriods(nPeriods, hDataPoints, startDate, endDate);

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
