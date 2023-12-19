import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityChart extends StatefulWidget {
  final String leftTitle;
  final String bottomTitle;
  const ActivityChart(
      {super.key, required this.leftTitle, required this.bottomTitle});

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  List<BarChartGroupData> thisBarCharts = [
    BarChartGroupData(
      barsSpace: 4,
      x: 0,
      barRods: [
        BarChartRodData(
          toY: 4,
          // color: widget.leftBarColor,
          width: 4,
        ),
      ],
    ),
        BarChartGroupData(
      barsSpace: 4,
      x: 1,
      barRods: [
        BarChartRodData(
          toY: 4,
          // color: widget.leftBarColor,
          width: 4,
        ),
      ],
    ),
        BarChartGroupData(
      barsSpace: 4,
      x: 2,
      barRods: [
        BarChartRodData(
          toY: 4,
          // color: widget.leftBarColor,
          width: 4,
        ),
      ],
    )
  ];

  
  @override
  Widget build(BuildContext context) {
    // myDataGroups(context);

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
        interval: 2,
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
  // final Widget text;

  return Text(
    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
    style: const TextStyle(
      color: Colors.black54,
    ),
    textAlign: TextAlign.center,
  );
}

BarTouchData? myBarTouchData(BuildContext context) {
  String timeText;
  return BarTouchData(
    touchTooltipData: BarTouchTooltipData(
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

