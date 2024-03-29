import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:provider/provider.dart';

class FoodListChart extends StatefulWidget {
  const FoodListChart({super.key});

  @override
  State<FoodListChart> createState() => _FoodListChartState();
}

class _FoodListChartState extends State<FoodListChart> {
  List<Widget> getFoodCards(List<DefaultDataPoint> foodDataPoints) {
    List<Widget> foodCards = [];
    for (DefaultDataPoint point in foodDataPoints) {
      // ignore: unused_local_variable
      String name = point.name != null ? point.name! : " ";
      foodCards.add(FoodCard(
        point: point,
      ));
    }
    return foodCards;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      List<DefaultDataPoint> filteredFoods = hdp.currentNutritionDataPoints
          .where((element) => (element.foodGroup == hdp.foodFilter) || hdp.foodFilter == "")
          .toList();
      return ListView(
        children: hdp.currentNutritionDataPoints.isEmpty
            ? [NoFoodWidget()]
            : getFoodCards(filteredFoods),
      );
    });
  }
}

class NoFoodWidget extends StatelessWidget {
  const NoFoodWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("No Food Registered"),
      ],
    );
  }
}

class FoodCard extends StatelessWidget {
  final DefaultDataPoint point;
  const FoodCard({
    super.key,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            // direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.lunch_dining),
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Text(
                      "${point.name}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  Text(
                    "${point.value}${point.unitName}",
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
