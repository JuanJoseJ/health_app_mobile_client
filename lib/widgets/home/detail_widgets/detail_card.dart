
import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/resume_card.dart';

class DetailCard extends StatelessWidget {
  const DetailCard({
    super.key,
    required this.navigateFn,
  });

  final VoidCallback? navigateFn;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
              child: Column(
            children: [
              Expanded(
                  child: ResumeCard(
                title: "Daily Activity",
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
    );
  }
}
