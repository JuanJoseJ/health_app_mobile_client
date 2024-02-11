import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/google_fit_data_service.dart';
import 'package:provider/provider.dart';

class CaloriesBottomWidget extends StatelessWidget {
  const CaloriesBottomWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      List<double> totCalories = GoogleFitDataService().getBurnedCalByPeriod(1, hdp.currentDate, hdp.currentDataPoints);
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "${totCalories[0].round()} calories burned",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }
}
