import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_sleep_by_time.dart';
import 'package:health_app_mobile_client/widgets/home/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/bottom_widgets/sleep_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/navigation/date_bar.dart';
import 'package:health_app_mobile_client/widgets/home/resume_cards.dart';

class CardsScafold extends StatelessWidget {
  const CardsScafold({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DateBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: const Padding(
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
                        myIcon: Icon(
                          Icons.fitness_center,
                          color: Colors.orangeAccent,
                        ),
                        chart: ActivityChart(
                          leftTitle: "Minutes of activity",
                          bottomTitle: "",
                        ),
                        bottomWidget: ActivityBottomWidget(),
                      )),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                          child: ResumeCard(
                        title: "Days",
                        myIcon: Icon(
                          Icons.self_improvement,
                          color: Colors.redAccent,
                        ),
                        chart: ActivityChart(
                          leftTitle: "Minutes of activity",
                          bottomTitle: "",
                        ),
                        bottomWidget: Text("xxx activiti"),
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
                        title: "Food",
                        myIcon: Icon(
                          Icons.restaurant,
                          color: Colors.green,
                        ),
                        chart: ActivityChart(
                          leftTitle: "Minutes of activity",
                          bottomTitle: "",
                        ),
                        bottomWidget: Text("xxx activiti"),
                      )),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                          child: ResumeCard(
                        title: "Sleep",
                        myIcon: Icon(
                          Icons.hotel,
                          color: Colors.lightBlueAccent,
                        ),
                        chart: SleepChart(),
                        bottomWidget: SleepBottomWidget(),
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
