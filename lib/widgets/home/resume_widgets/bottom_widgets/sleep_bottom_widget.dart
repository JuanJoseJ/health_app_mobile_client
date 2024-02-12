import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/fit_bit_data_service.dart';
import 'package:provider/provider.dart';

class SleepBottomWidget extends StatelessWidget {
  const SleepBottomWidget({super.key});
  @override
  Widget build(BuildContext context) {
    FitBitDataService fitBitDataService = FitBitDataService();
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      int totMinutes = fitBitDataService
          .getSleepByDays(1, hdp.currentDate, hdp.currentSleepDataPoints)
          .round();
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                totMinutes > 0
                    ? "$totMinutes minutes of sleep"
                    : "No sleep registered",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }
}
