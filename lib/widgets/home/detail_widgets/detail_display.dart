import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/home/detail_widgets/detail_card.dart';
import 'package:health_app_mobile_client/widgets/navigation/detail_top_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailScaffold extends StatelessWidget {
  final dynamic Function(String) navigateFn;
  final StatefulWidget chart;
  final Widget bottomWidget;
  final String title;
  const DetailScaffold({
    super.key,
    required this.navigateFn,
    required this.chart,
    required this.bottomWidget,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      String dateText = '';
      switch (hdp.currentTopBarSelect) {
        case "day":
          dateText = DateFormat('MMMM dd, yyyy').format(hdp.currentDate);
        case "week":
          DateTime startOfWeek = hdp.currentDate
              .subtract(Duration(days: hdp.currentDate.weekday - 1));
          DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
          String startString = DateFormat('MMMM d').format(startOfWeek);
          String endString = DateFormat('MMMM d').format(endOfWeek);
          dateText = "$startString - $endString";
        case "month":
          dateText = DateFormat('MMMM y').format(hdp.currentDate);
        default:
      }

      return Scaffold(
        appBar: DetailTopBar(
          notifyParent: navigateFn,
          chartId: "",
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                // flex: 3, // This makes the DetailCard take 1/3 of the space
                child: DetailCard(
                  changeDate: () {},
                  title: title,
                  chart: chart,
                  date: dateText,
                ),
              ),
              // const Spacer(),
            ],
          ),
        ),
      );
    });
  }
}
