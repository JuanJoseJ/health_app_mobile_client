import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_calories_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_sleep_by_time.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/calories_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/sleep_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/resume_card.dart';
import 'package:health_app_mobile_client/widgets/navigation/date_bar.dart';

class CardsScafold extends StatelessWidget {
  final VoidCallback? navigateFn;
  const CardsScafold( {super.key, this.navigateFn,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DateBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body:  Padding(
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
                        chart: const ActivityChart(
                          leftTitle: "Minutes of activity",
                          bottomTitle: "",
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
  }
}
