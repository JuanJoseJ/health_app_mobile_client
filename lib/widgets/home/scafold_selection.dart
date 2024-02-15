import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_food_list_by_day.dart';
import 'package:health_app_mobile_client/charts/chart_sleep_states_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_stress_by_day.dart';
import 'package:health_app_mobile_client/charts/side_tittle_widgets/bottom_tittle_widgets.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/home/detail_widgets/detail_display.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/food_list_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/sleep_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/stress_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/cards_display.dart';
import 'package:provider/provider.dart';

class DataScafold extends StatefulWidget {
  const DataScafold({super.key});

  @override
  State<DataScafold> createState() => _DataScafoldState();
}

class _DataScafoldState extends State<DataScafold> {
  int _currentIndex = 0;
  StatefulWidget? chart;
  Widget? bottomWidget;
  String? title;

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
            DateTime date = hDP.currentDate;
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

      navigate(String chartId) {
        switch (chartId) {
          case 'Activity':
            chart = ActivityChart(
              leftTitle: "Minutes of activity",
              bottomTittleWidget: dailyThirdsBTW,
              nPeriods: getNumberOfPeriods(),
            );
            bottomWidget = ActivityBottomWidget();
            title = "Activity";
            break;
          case 'Sleep':
            chart = const SleepStatesChart();
            bottomWidget = const SleepBottomWidget();
            title = "Sleep";
            break;
          case 'Food':
            chart = const FoodListChart();
            bottomWidget = const FoodListBottomWidget();
            title = "Food";
            break;
          case 'Stress':
            chart = const StressChart();
            bottomWidget = const StressBottomWidget();
            title = "Stress";
            break;
          default:
            chart = ActivityChart(
              leftTitle: "Minutes of activity",
              bottomTittleWidget: dailyThirdsBTW,
              nPeriods: getNumberOfPeriods(),
            );
            bottomWidget = ActivityBottomWidget();
            title = "Activity";
            break;
        }
        setState(() {
          _currentIndex = 1 - 1 * _currentIndex;
        });
      }

      Widget pageSelector() {
        Widget page;
        switch (_currentIndex) {
          case 0:
            page = CardsScafold(navigateFn: navigate);
            break;
          case 1:
            page = DetailScaffold(
              title: title!,
              navigateFn: navigate,
              chart: chart!,
              bottomWidget: bottomWidget!,
            );
            break;
          default:
            page = CardsScafold();
        }
        return page;
      }

      return pageSelector();
    });
  }
}
