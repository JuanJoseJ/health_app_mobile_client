import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:provider/provider.dart';

class CaloriesChart extends StatefulWidget {
  const CaloriesChart({super.key});

  @override
  State<StatefulWidget> createState() => CaloriesChartState();
}

class CaloriesChartState extends State {
  List<LineChartBarData> myLineChartBarData() {
    return [
      LineChartBarData(
        isCurved: true,
        color: Colors.orangeAccent,
        barWidth: 6,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(0, 3),
          FlSpot(1, 0),
          FlSpot(2, 7),
          FlSpot(3, 5),
          FlSpot(4, 5),
        ],
      ),
      LineChartBarData(
        isCurved: true,
        color: Colors.green,
        barWidth: 6,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(0, 6),
          FlSpot(1, 3),
          FlSpot(2, 4),
          FlSpot(3, 0),
          FlSpot(4, 5),
        ],
      ),
    ];
  }

  FlTitlesData linearTilesData(BuildContext context) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
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
        axisNameWidget: Text(
          "Calories",
          style: Theme.of(context).textTheme.bodyLarge,
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
        text = Container();
        break;
      case 1:
        text = const Icon(
          Icons.wb_twighlight,
          size: 18.0,
          color: Colors.black54,
        );
        break;
      case 2:
        text = const Icon(
          Icons.wb_sunny,
          size: 16.0,
          color: Colors.black54,
        );
        break;
      case 3:
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
            if(element.barIndex == 0){
              tempText = 'burned';
            }else if(element.barIndex == 1){
              tempText = 'spent';
            }
            LineTooltipItem newItem = LineTooltipItem(
                "${element.y} calories $tempText",
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
      return LineChart(
        LineChartData(
          lineBarsData: myLineChartBarData(),
          titlesData: linearTilesData(context),
          lineTouchData: myLineTouchData(),
          borderData: FlBorderData(show: false),
        ),
      );
    });
  }
}
