import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/dates_util.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:provider/provider.dart';

class SleepStatesChart extends StatefulWidget {
  const SleepStatesChart({super.key});

  @override
  State<StatefulWidget> createState() => SleepStatesChartState();
}

class SleepStatesChartState extends State {
  List<LineChartBarData> calBurnedBarData(HomeDataProvider hdp) {
    List<DefaultDataPoint> sleepDataPoints = hdp.currentSleepDataPoints;
    DateTime sleepStart = DateTime(
            hdp.currentDate.year, hdp.currentDate.month, hdp.currentDate.day)
        .subtract(const Duration(hours: 6));
    DateTime sleepEnd = DateTime(
            hdp.currentDate.year, hdp.currentDate.month, hdp.currentDate.day)
        .add(const Duration(hours: 18));
    List<FlSpot> spotsList = [];
    double countSecondsX = 0;
    for (var i = 0; i < sleepDataPoints.length; i++) {
      if (sleepDataPoints[i].dateFrom.isAfter(sleepStart) &&
          sleepDataPoints[i].dateTo!.isBefore(sleepEnd)) {
        if (double.parse(sleepDataPoints[i].value.toString()) < 10) {
          countSecondsX += double.parse(sleepDataPoints[i].value.toString());
          continue;
        }
        switch (sleepDataPoints[i].type) {
          case HealthDataType.SLEEP_ASLEEP:
            spotsList.add(FlSpot(countSecondsX, 2.toDouble()));
            countSecondsX += double.parse(sleepDataPoints[i].value.toString());
            spotsList.add(FlSpot(countSecondsX, 2.toDouble()));
            break;
          case HealthDataType.SLEEP_LIGHT:
            spotsList.add(FlSpot(countSecondsX, 1.toDouble()));
            countSecondsX += double.parse(sleepDataPoints[i].value.toString());
            spotsList.add(FlSpot(countSecondsX, 1.toDouble()));
            break;
          case HealthDataType.SLEEP_AWAKE:
            spotsList.add(FlSpot(countSecondsX, 0.toDouble()));
            countSecondsX += double.parse(sleepDataPoints[i].value.toString());
            spotsList.add(FlSpot(countSecondsX, 0.toDouble()));
            break;
          default:
        }
      }
    }

    return [
      LineChartBarData(
        color: Colors.blueAccent,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: spotsList,
      ),
    ];
  }

  FlTitlesData linearTilesData(BuildContext context) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 90,
          getTitlesWidget: bottomTitleWidgets,
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          getTitlesWidget: leftTitleWidgets,
          showTitles: true,
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String myText = " ";
    if (value % meta.appliedInterval == 0) {
      myText = "${value ~/ 60}h";
    }
    // Rotate the text widget
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        myText,
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (double.parse(value.toStringAsFixed(1))) {
      case 2.0:
        text = "Asleep";
        break;
      case 1.0:
        text = "Restless";
        break;
      default:
        text = "awake";
    }
    return Text(
      ([0, 1, 2].contains(double.parse(value.toStringAsFixed(1))))
          ? text
          : '', // Only show titles on the same period
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 9,
      ),
      textAlign: TextAlign.center,
    );
  }

  LineTouchData myLineTouchData(HomeDataProvider hDataProvider) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        fitInsideVertically: true,
        fitInsideHorizontally: true,
        maxContentWidth: 70,
        tooltipPadding: const EdgeInsets.all(4),
        tooltipBgColor:
            const Color.fromARGB(255, 236, 236, 236).withOpacity(0.9),
        getTooltipItems: (touchedSpots) {
          List<LineTooltipItem?> items = [];
          for (var element in touchedSpots) {
            String tempText = '';
            if (element.y == 2) {
              tempText = 'Asleep';
            } else if (element.y == 1) {
              tempText = 'Restless';
            } else if (element.y == 0) {
              tempText = 'Awake';
            }
            // String time = DateFormat('hh:mm aaa').format(hDataProvider
            //     .currentSleepDataPoints[element.x.toInt()].dateFrom);
            LineTooltipItem newItem = LineTooltipItem(
                "$tempText",
                TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: element.bar.color,
                ));
            items.add(newItem);
          }
          return items;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDataProvider, child) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: LineChart(
          LineChartData(
            lineBarsData: calBurnedBarData(hDataProvider),
            titlesData: linearTilesData(context),
            lineTouchData: myLineTouchData(hDataProvider),
            borderData: FlBorderData(show: false),
            minY: 0,
            maxY: 3,
          ),
        ),
      );
    });
  }
}
