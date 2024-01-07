import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/health_data_service.dart';
import 'package:provider/provider.dart';

class SleepChart extends StatefulWidget {
  const SleepChart({super.key});

  @override
  State<StatefulWidget> createState() => SleepChartState();
}

class SleepChartState extends State {
  bool sectionTchd = false;
  final double widthFraction = 1 / 2;

  List<PieChartSectionData> showingSections(
      double widthFraction, double totSleepMinutes) {
    double minutesOfDay = 24 * 60;

    return [
      PieChartSectionData(
          color: Colors.blueAccent,
          value: totSleepMinutes,
          title: '${((totSleepMinutes / minutesOfDay) * 100).round()}%',
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
                )),
      PieChartSectionData(
          color: Colors.orangeAccent,
          value: (minutesOfDay - totSleepMinutes),
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

  PieTouchData nightPieTouchData() {
    return PieTouchData(
      touchCallback: (FlTouchEvent event, pieTouchResponse) {
        print(event);
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

    return Consumer<HomeDataProvider>(builder: (context, hDataProvider, child) {
      final HealthDataService hds = new HealthDataService();
      final double totSleepMinutes = hds.getSleepByDays(
          1, hDataProvider.currentDate, hDataProvider.currentDataPoints);
      return PieChart(
        PieChartData(
            pieTouchData: nightPieTouchData(),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 2,
            centerSpaceRadius: centerSpaceRadius,
            sections: showingSections(widthFraction, totSleepMinutes),
            startDegreeOffset: 180),
      );
    });
  }
}
