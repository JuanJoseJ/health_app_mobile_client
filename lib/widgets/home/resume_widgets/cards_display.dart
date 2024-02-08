import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_calories_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_sleep_by_time.dart';
import 'package:health_app_mobile_client/charts/side_tittle_widgets/bottom_tittle_widgets.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/calories_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/sleep_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/resume_card.dart';
import 'package:health_app_mobile_client/widgets/navigation/date_bar.dart';
import 'package:provider/provider.dart';

class CardsScafold extends StatelessWidget {
  final VoidCallback? navigateFn;
  const CardsScafold({
    super.key,
    this.navigateFn,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDP, child) {
      int getNumberOfPeriods() {
        switch (hDP.currentTopBarSelect) {
          case "day":
            return 3;
          case "week":
            return 7;
          case "month":
            DateTime now = hDP.currentDate;
            DateTime firstDayNextMonth = (now.month < 12)
                ? new DateTime(now.year, now.month + 1, 1)
                : new DateTime(now.year + 1, 1, 1);
            DateTime firstDayCurrentMonth =
                new DateTime(now.year, now.month, 1);
            return firstDayNextMonth.difference(firstDayCurrentMonth).inDays;
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
                          title: "What?",
                          myIcon: const Icon(
                            Icons.self_improvement,
                            color: Colors.green,
                          ),
                          chart: const ActivityChart(
                            leftTitle: "Minutes of activity",
                            bottomTitle: "",
                            bottomTittleWidget: dailyThirdsBTW,
                            nPeriods: 3,
                          ),
                          bottomWidget: Text("xxx activiti"),
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
                          title: "Calories",
                          myIcon: const Icon(
                            Icons.local_fire_department,
                            color: Colors.redAccent,
                          ),
                          chart: CaloriesChart(),
                          bottomWidget: CaloriesBottomWidget(),
                          notifyParent: navigateFn,
                        )),
                      ],
                    )),
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
                          bottomWidget: SleepBottomWidget(),
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
