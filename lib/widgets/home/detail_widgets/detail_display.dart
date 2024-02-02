import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/charts/side_tittle_widgets/bottom_tittle_widgets.dart';
import 'package:health_app_mobile_client/widgets/home/detail_widgets/detail_card.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
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
      appBar: DetailTopBar(
        notifyParent: navigateFn,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            DetailCard(
              changeDate: () {},
              title: "Daily Activity",
              chart: ActivityChart(
                bottomTitle: "",
                leftTitle: "Minutes of Activity",
                bottomTittleWidget: dailySixthsBTW,
              ),
              bottomWidget: ActivityBottomWidget(),
              date: "22/01/2024",
            ),
            DetailCard(
              changeDate: () {},
              title: "Weekly Activity",
              chart: ActivityChart(
                bottomTitle: "",
                leftTitle: "Minutes of Activity",
                bottomTittleWidget: dailySixthsBTW,
              ),
              bottomWidget: ActivityBottomWidget(),
              date: "22/01/2024",
            ),
            DetailCard(
              changeDate: () {},
              title: "Monthly Activity",
              chart: ActivityChart(
                bottomTitle: "",
                leftTitle: "Minutes of Activity",
                bottomTittleWidget: dailySixthsBTW,
              ),
              bottomWidget: ActivityBottomWidget(),
              date: "22/01/2024",
            ),
          ],
        ),
      ),
    );
  }
}
