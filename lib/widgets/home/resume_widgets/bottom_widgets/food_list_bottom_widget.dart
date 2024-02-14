import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:provider/provider.dart';

class FoodListBottomWidget extends StatelessWidget {
  const FoodListBottomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDataProv, child) {

      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${getTotalCalories(hDataProv.currentNutritionDataPoints)}cal",
                textAlign: TextAlign.end,
              ),
            ),
          )
        ],
      );
    });
  }

  int getTotalCalories(List<DefaultDataPoint> foodDataPoints){
    int totCalories = 0;
    for(DefaultDataPoint p in foodDataPoints){
      totCalories += double.parse(p.value.toString()).toInt();
    }
    return totCalories;
  }
  
}
