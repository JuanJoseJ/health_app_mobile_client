import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/charts/side_tittle_widgets/bottom_tittle_widgets.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/home/detail_widgets/detail_card.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/navigation/detail_top_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailScaffold extends StatelessWidget {
  final VoidCallback? navigateFn;
  const DetailScaffold({
    super.key,
    this.navigateFn,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDP, child) {
      String dateText = '';
      int getNumberOfPeriods() {
        switch (hDP.currentTopBarSelect) {
          case "day":
            dateText = DateFormat('EEEE d, yyyy').format(hDP.currentDate);
            return 3;
          case "week":
            DateTime startOfWeek = hDP.currentDate
                .subtract(Duration(days: hDP.currentDate.weekday - 1));
            DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
            String startString = DateFormat('MMMM d').format(startOfWeek);
            String endString = DateFormat('MMMM d').format(endOfWeek);
            dateText = "$startString - $endString";
            return 7;
          case "month":
            DateTime now = hDP.currentDate;
            DateTime firstDayNextMonth = (now.month < 12)
                ? DateTime(now.year, now.month + 1, 1)
                : DateTime(now.year + 1, 1, 1);
            DateTime firstDayCurrentMonth = DateTime(now.year, now.month, 1);
            dateText = DateFormat('MMMM y').format(hDP.currentDate);
            return firstDayNextMonth.difference(firstDayCurrentMonth).inDays;
          default:
            return 3;
        }
      }

      return Scaffold(
        appBar: DetailTopBar(
          notifyParent: navigateFn,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 2, // This makes the DetailCard take 1/3 of the space
                child: DetailCard(
                  changeDate: () {},
                  title: "Daily Activity",
                  chart: ActivityChart(
                    leftTitle: "Minutes of activity",
                    bottomTittleWidget: dailyThirdsBTW,
                    nPeriods: getNumberOfPeriods(),
                  ),
                  bottomWidget: const ActivityBottomWidget(),
                  date: dateText,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      );
    });
  }
}