import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_period.dart';
import 'package:health_app_mobile_client/charts/chart_calories_by_period.dart';
import 'package:health_app_mobile_client/charts/chart_food_list_by_day.dart';
import 'package:health_app_mobile_client/charts/chart_sleep_by_period.dart';
import 'package:health_app_mobile_client/charts/chart_sleep_states_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_stress_by_day.dart';
import 'package:health_app_mobile_client/charts/chart_stress_by_period.dart';
import 'package:health_app_mobile_client/charts/side_tittle_widgets/bottom_tittle_widgets.dart';
import 'package:health_app_mobile_client/pages/authentication/profile.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/home/detail_widgets/detail_display.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/activity_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/food_list_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/sleep_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/stress_bottom_widget.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/bottom_widgets/stress_period_bottom_widget.dart';
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
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      int getNumberOfPeriods() {
        switch (hdp.currentTopBarSelect) {
          case "day":
            return 3;
          case "week":
            return 7;
          case "month":
            DateTime date = DateTime(hdp.currentDate.year,
                hdp.currentDate.month, hdp.currentDate.day);
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

      navigate(String chartId) async {
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
            chart = hdp.currentTopBarSelect == 'day'
                ? const SleepStatesChart()
                : SleepByPeriodChart(nPeriods: getNumberOfPeriods());
            bottomWidget = const SleepBottomWidget();
            title = "Sleep";
            break;
          case 'Food':
            chart = hdp.currentTopBarSelect == 'day'
                ? const FoodListChart()
                : CaloriesByPeriodChart(
                    nPeriods: getNumberOfPeriods(),
                  );
            bottomWidget = const FoodListBottomWidget();
            title = "Food";
            break;
          case 'Stress':
            chart = hdp.currentTopBarSelect == 'day'
                ? const StressChart()
                : StressByPeriodChart(nPeriods: getNumberOfPeriods());
            bottomWidget = hdp.currentTopBarSelect == 'day'
                ? const StressBottomWidget()
                : StressPeriodsBottomWidget(
                    nPeriods: getNumberOfPeriods(),
                  );
            title = "Stress";
          case 'Profile':
            chart = ProfileBlock();
            bottomWidget = null;
            title = "Profile";
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
              bottomWidget: bottomWidget,
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
