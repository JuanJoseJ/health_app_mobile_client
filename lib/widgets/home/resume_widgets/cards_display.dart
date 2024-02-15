import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_calories_by_period.dart';
import 'package:health_app_mobile_client/charts/chart_calories_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_food_list_by_day.dart';
import 'package:health_app_mobile_client/charts/chart_sleep_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_stress_by_day.dart';
import 'package:health_app_mobile_client/charts/side_tittle_widgets/bottom_tittle_widgets.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/calories_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/food_list_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/sleep_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/stress_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/resume_card.dart';
import 'package:health_app_mobile_client/widgets/navigation/date_bar.dart';
import 'package:provider/provider.dart';

class CardsScafold extends StatelessWidget {
  final dynamic Function(String)? navigateFn;
  const CardsScafold({
    super.key,
    this.navigateFn,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      int getNumberOfPeriods() {
        switch (hdp.currentTopBarSelect) {
          case "day":
            return 3;
          case "week":
            return 7;
          case "month":
            DateTime date = hdp.currentDate;
            DateTime firstDayNextMonth;
            if (date.month < 12) {
              firstDayNextMonth = DateTime(date.year, date.month + 1, 1);
            } else {
              firstDayNextMonth = DateTime(date.year + 1, 1, 1);
            }
            DateTime lastDayOfMonth =
                firstDayNextMonth.subtract(Duration(days: 1));
            return lastDayOfMonth.day;
          default:
            return 3;
        }
      }

      return Scaffold(
        appBar: const DateBar(),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: ResumeCard(
                          title: "Activity",
                          myIcon: const Icon(
                            Icons.fitness_center,
                            color: Colors.orangeAccent,
                          ),
                          chart: ActivityChart(
                            leftTitle: "Minutes of activity",
                            bottomTittleWidget: dailyThirdsBTW,
                            nPeriods: getNumberOfPeriods(),
                          ),
                          chartId: "Activity",
                          bottomWidget: ActivityBottomWidget(),
                          notifyParent: navigateFn,
                        )),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: ResumeCard(
                          title: "Food",
                          myIcon: const Icon(
                            Icons.restaurant,
                            color: Colors.green,
                          ),
                          chart: hdp.currentTopBarSelect == 'day'
                              ? const FoodListChart()
                              : CaloriesByPeriodChart(
                                  nPeriods: getNumberOfPeriods()),
                          chartId: "Food",
                          bottomWidget: FoodListBottomWidget(),
                          notifyParent: navigateFn,
                        )),
                      ],
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: ResumeCard(
                          title: "Sleep",
                          myIcon: const Icon(
                            Icons.hotel,
                            color: Colors.lightBlueAccent,
                          ),
                          chart: SleepChart(),
                          chartId: "Sleep",
                          bottomWidget: SleepBottomWidget(),
                          notifyParent: navigateFn,
                        )),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: ResumeCard(
                          title: "Stress",
                          myIcon: const Icon(
                            Icons.self_improvement,
                            color: Colors.deepPurpleAccent,
                          ),
                          chart: StressChart(),
                          chartId: "Stress",
                          bottomWidget: StressBottomWidget(),
                          notifyParent: navigateFn,
                        )),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
