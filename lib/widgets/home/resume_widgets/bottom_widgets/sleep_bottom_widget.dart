import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/fit_bit_data_service.dart';
import 'package:health_app_mobile_client/util/dates_util.dart';
import 'package:provider/provider.dart';

class SleepBottomWidget extends StatelessWidget {
  const SleepBottomWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(
        builder: (context, sleepDataProvider, child) {
      final FitBitDataService sleepDataService = FitBitDataService();

      DateTime startDate = sleepDataProvider.currentMinDate;
      DateTime endDate = sleepDataProvider.currentMaxDate;
      if (endDate.isAfter(DateTime.now())) {
        endDate = DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .add(const Duration(hours: 24, seconds: -1));
      }

      if (sleepDataProvider.currentTopBarSelect == 'day') {
        startDate = DateTime(
            sleepDataProvider.currentDate.year,
            sleepDataProvider.currentDate.month,
            sleepDataProvider.currentDate.day);
        endDate = startDate.add(const Duration(days: 1, seconds: -1));
      }

      DateTime lastNightStart = startDate.subtract(const Duration(hours: 6));
      DateTime lastNightEnd = endDate.subtract(const Duration(hours: 6));
      double totSleepMinutes = sleepDataService.getTotalSleepByPeriod(
          sleepDataProvider.currentSleepDataPoints,
          lastNightStart,
          lastNightEnd);

      String textSuffix = '';
      switch (sleepDataProvider.currentTopBarSelect) {
        case 'day':
          textSuffix = formatDuration(totSleepMinutes);
          break;
        case 'week':
          int difDays = 7;
          difDays = endDate.difference(startDate).inDays + 1;
          totSleepMinutes = totSleepMinutes / difDays;
          textSuffix = "${formatDuration(totSleepMinutes)} (avg)";
          break;
        case 'month':
          int difDays = 30;
          difDays = endDate.difference(startDate).inDays + 1;
          totSleepMinutes = totSleepMinutes / difDays;
          textSuffix = "${formatDuration(totSleepMinutes)} (avg)";
          break;
      }

      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                totSleepMinutes > 0 ? textSuffix : "No sleep registered",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }
}
