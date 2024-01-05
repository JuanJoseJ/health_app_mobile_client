import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SleepChart extends StatefulWidget {
  const SleepChart({super.key});

  @override
  State<StatefulWidget> createState() => SleepChartState();
}

class SleepChartState extends State {
  bool sectionTchd = false;
  double goalSleepTime = 8; // In minutes

  List<PieChartSectionData> showingSections(
      String text, double widthFraction, double sleepMinutes) {
    double minutesOfDay = 24;

    return [
      PieChartSectionData(
        color: Colors.blueAccent,
        value: sleepMinutes,
        title: text,
        showTitle: sectionTchd,
        radius: (sectionTchd ? 100 : 80) * (1 - widthFraction),
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: sectionTchd
              ? null
              : const Icon(
                  Icons.nightlight,
                  size: 16.0,
                  color: Colors.white,
                )
      ),
      PieChartSectionData(
          color: Colors.orangeAccent,
          value: (minutesOfDay - sleepMinutes),
          title: '',
          radius: 80 * (1 - widthFraction),
          titleStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: const Icon(
            Icons.wb_sunny,
            size: 18.0,
            color: Colors.white,
          ))
    ];
  }

  PieTouchData nightPieTouchData(){
    return PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              print(event);
              setState(() {
                if (event is FlPointerHoverEvent) {
                  sectionTchd = true;
                }else if (event is FlTapUpEvent || event is FlLongPressEnd){
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
    double widthFraction = 1 / 2;
    double centerSpaceRadiusPercentage = 0.2;
    double centerSpaceRadius =
        screenWidth * centerSpaceRadiusPercentage * widthFraction;

    return PieChart(
      PieChartData(
          pieTouchData: nightPieTouchData(),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 2,
          centerSpaceRadius: centerSpaceRadius,
          sections: showingSections("33.33%", widthFraction, goalSleepTime),
          startDegreeOffset: 180),
    );
  }
}
