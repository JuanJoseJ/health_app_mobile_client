import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/widgets/home/detail_widgets/detail_card.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/resume_card.dart';
import 'package:health_app_mobile_client/widgets/navigation/detail_top_bar.dart';

class DetailScafold extends StatelessWidget {
  final VoidCallback? navigateFn;
  const DetailScafold({
    super.key,
    this.navigateFn,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailTopBar(notifyParent: navigateFn,),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            DetailCard(navigateFn: navigateFn),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                          child: ResumeCard(
                        title: "Weekly Activity",
                        myIcon: const Icon(
                          Icons.fitness_center,
                          color: Colors.orangeAccent,
                        ),
                        chart: const ActivityChart(
                          leftTitle: "Minutes of ctivity",
                          bottomTitle: "",
                        ),
                        bottomWidget: ActivityBottomWidget(),
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
                        title: "Monthly Activity",
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

