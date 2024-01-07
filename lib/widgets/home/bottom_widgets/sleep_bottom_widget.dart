import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/health_data_service.dart';
import 'package:provider/provider.dart';

class SleepBottomWidget extends StatelessWidget {
  const SleepBottomWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      int totMinutes = 0;
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "${HealthDataService().getSleepByDays(1, hdp.currentDate, hdp.currentDataPoints).round()} minutes of sleep",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }
}