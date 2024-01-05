import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/pages/my_home_page.dart';
import 'package:provider/provider.dart';

class ResumeCard extends StatelessWidget {
  final String title;
  final Icon myIcon;
  final StatefulWidget chart;

  const ResumeCard({Key? key, required this.title, required this.myIcon, required this.chart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
                      child: Row(
                        children: [
                          myIcon,
                          const SizedBox(width: 8.0),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                        size: 17.0,
                      ))
                ],
              ),
            ),
          ],
        ),
        Expanded(
            child: AspectRatio(
          aspectRatio: 1.0 / 1.0,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
            child: chart,
          ),
        )),
        Consumer<HomeDataProvider>(builder: (context, hDataProv, child) {
          int totMinutes = getDailyActivityByPeriods(
            hDataProv.currentDate, 
            hDataProv.currentDataPoints
          );
          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "$totMinutes minutes",
                    textAlign: TextAlign.end,
                  ),
                ),
              )
            ],
          );
        })
      ]),
    );
  }
}

int getDailyActivityByPeriods(
    DateTime date, List<HealthDataPoint> moveMinutes) {
  int totalMoveMinutes = 0;
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endtOfDay =
      DateTime(date.year, date.month, date.day).add(const Duration(days: 1));

  // Iterate over the data and accumulate the values for each period
  for (HealthDataPoint dataPoint in moveMinutes) {
    if (dataPoint.dateFrom.isAfter(startOfDay) &&
        dataPoint.dateFrom.isBefore(endtOfDay)) {
      totalMoveMinutes++;
    }
  }
  return totalMoveMinutes;
}
