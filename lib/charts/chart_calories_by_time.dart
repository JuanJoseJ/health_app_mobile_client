import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/google_fit_data_service.dart';
import 'package:provider/provider.dart';

class CaloriesChart extends StatefulWidget {
  const CaloriesChart({super.key});

  @override
  State<StatefulWidget> createState() => CaloriesChartState();
}

class CaloriesChartState extends State {
  List<LineChartBarData> calBurnedBarData(List<double> nCalories) {
    List<FlSpot> spotsList = [];
    for (var i = 0; i < nCalories.length; i++) {
      spotsList.add(FlSpot(i.toDouble(), nCalories[i]));
    }

    return [
      LineChartBarData(
        color: Colors.orangeAccent,
        barWidth: 6,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: spotsList,
      )
    ];
  }

  FlTitlesData linearTilesData(BuildContext context) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
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
        axisNameWidget: FittedBox(
          fit: BoxFit.scaleDown,
          child: IntrinsicWidth(
            child: Text(
              "Calories",
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        sideTitles: SideTitles(
          getTitlesWidget: leftTitleWidgets,
          showTitles: true,
        ),
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
          size: 16.0,
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
        text = Container();
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

  LineTouchData myLineTouchData() {
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
            String time = '';
            if (element.barIndex == 0) {
              tempText = 'burned';
            } else if (element.barIndex == 1) {
              tempText = 'spent';
            }
            if (element.x == 0) {
              time = "morning";
            } else if (element.x == 1) {
              time = "afternoon";
            } else if (element.x == 2) {
              time = "night";
            }
            LineTooltipItem newItem = LineTooltipItem(
                "${element.y.round()} calories $tempText in the $time",
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
      List<double> calories = GoogleFitDataService().getBurnedCalByPeriod(
          3, hDataProvider.currentDate, hDataProvider.currentActivityDataPoints);
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: LineChart(
          LineChartData(
            lineBarsData: calBurnedBarData(calories),
            titlesData: linearTilesData(context),
            lineTouchData: myLineTouchData(),
            borderData: FlBorderData(show: false),
          ),
        ),
      );
    });
  }
}
