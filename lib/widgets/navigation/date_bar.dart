import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DateBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic Function(String)? navigateFn;
  const DateBar({Key? key, this.navigateFn});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _getTopBarString(String topBarSelect, DateTime currentDate) {
    String newString = "";

    if (topBarSelect == "month") {
      newString = DateFormat('MMMM y').format(currentDate);
    } else if (topBarSelect == "week") {
      // Calculate the start and end dates of the week for the selected date
      DateTime startOfWeek =
          currentDate.subtract(Duration(days: currentDate.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      // Format the dates as "Month day - Month day"
      String startString = DateFormat('MMMM d').format(startOfWeek);
      String endString = DateFormat('MMMM d').format(endOfWeek);

      newString = "$startString - $endString";
    } else {
      newString = DateFormat('y-MMMM-d').format(currentDate);
      ;
    }

    return newString;
  }

  void _updateDate(BuildContext context, HomeDataProvider hdp,
      {required bool isForward}) {
    DateTime newDate;
    DateTime startDate;
    DateTime endDate;
    final currentDate = hdp.currentDate;
    final topBarSelect = hdp.currentTopBarSelect;
    final today = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)
        .subtract(const Duration(seconds: 1));
    final startOfToday = DateTime(today.year, today.month, today.day);

    switch (topBarSelect) {
      case 'day':
        newDate = isForward
            ? currentDate.add(Duration(days: 1))
            : currentDate.subtract(Duration(days: 1));
        if (newDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
          if (newDate.isAfter(startOfToday)) {
            newDate = startOfToday;
          }
          startDate = DateTime(newDate.year, newDate.month, newDate.day);
          endDate = startDate
              .add(const Duration(hours: 24))
              .subtract(const Duration(seconds: 1));
          //Fetch data if not present for the days
          if (newDate.isBefore(hdp.currentMinDate) ||
              newDate.isAfter(hdp.currentMaxDate)) {
            hdp.fetchActivityDataPoints(
                startDate.subtract(const Duration(days: 15)),
                endDate.add(const Duration(days: 15)));
            hdp.fetchSleepDataPoints(
                startDate.subtract(const Duration(days: 15)),
                endDate.add(const Duration(days: 15)));
            hdp.fetchHRVDataPoints(startDate.subtract(const Duration(days: 15)),
                endDate: endDate.add(const Duration(days: 15)));
          }
          hdp.updateCurrentDate(newDate);
          hdp.fetchNutritionDataPoints(newDate);
        } else {
          return;
        }
        break;
      case 'week':
        int daysToAdjust = isForward ? 7 : -7;
        newDate = currentDate.add(Duration(days: daysToAdjust));
        // Adjust startOfWeek to ensure it doesn't start in the future
        if (newDate.isBefore(DateTime.now())) {
          DateTime startOfWeek =
              newDate.subtract(Duration(days: newDate.weekday - 1));
          startDate =
              DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          if (startOfWeek.isAfter(startOfToday)) {
            newDate = startOfToday;
            startOfWeek =
                startOfToday.subtract(Duration(days: startOfToday.weekday - 1));
            endDate = today;
          } else {
            endDate = startDate
                .add(const Duration(days: 7))
                .subtract(const Duration(seconds: 1));
          }
          hdp.fetchActivityDataPoints(startDate, endDate);
          hdp.fetchSleepDataPoints(startDate, endDate);
          hdp.fetchNutritionDataPoints(startDate, endDate: endDate);
          hdp.fetchHRVDataPoints(startDate, endDate: endDate);
          hdp.updateCurrentMinDate(startDate);
          hdp.updateCurrentMaxDate(endDate);
          hdp.updateCurrentDate(startDate);
        } else {
          return;
        }
        break;
      case 'month':
        int monthsToAdjust = isForward ? 1 : -1;
        newDate = DateTime(currentDate.year, currentDate.month + monthsToAdjust,
            currentDate.day);
        if (newDate.isBefore(DateTime.now())) {
          // Prevent navigating to a future month
          if (newDate.isAfter(DateTime(today.year, today.month + 1, 0))) {
            newDate = DateTime(today.year, today.month, today.day);
          }
          startDate = DateTime(newDate.year, newDate.month, 1);
          endDate = DateTime(newDate.year, newDate.month + 1, 1)
              .subtract(const Duration(seconds: 1));
          hdp.fetchActivityDataPoints(startDate, endDate);
          hdp.fetchSleepDataPoints(startDate, endDate);
          hdp.fetchNutritionDataPoints(startDate, endDate: endDate);
          hdp.fetchHRVDataPoints(startDate, endDate: endDate);
          hdp.updateCurrentMinDate(startDate);
          hdp.updateCurrentMaxDate(endDate);
          hdp.updateCurrentDate(startDate);
          break;
        } else {
          return;
        }
      default:
        return;
    }
  }

  Future<void> _selectDate(BuildContext context, HomeDataProvider hdp) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: hdp.currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    late DateTime startDate;
    late DateTime endDate;
    DateTime currentDate = hdp.currentDate;

    if (picked != null && picked != currentDate) {
      hdp.updateCurrentDate(picked);
      if (picked.isBefore(currentDate) || picked.isAfter(currentDate)) {
        switch (hdp.currentTopBarSelect) {
          case 'day':
            startDate = picked.subtract(const Duration(days: 15));
            endDate = picked.add(const Duration(days: 15));
            hdp.fetchNutritionDataPoints(picked);
            hdp.fetchHRVDataPoints(startDate, endDate: endDate);
            break;
          case 'week':
            startDate = DateTime(picked.year, picked.month, picked.day)
                .subtract(Duration(days: picked.weekday - 1));
            endDate = startDate
                .add(const Duration(days: 7))
                .subtract(const Duration(seconds: 1));
            hdp.fetchNutritionDataPoints(startDate, endDate: endDate);
            hdp.fetchHRVDataPoints(startDate, endDate: endDate);
            break;
          case 'month':
            startDate = DateTime(picked.year, picked.month, 1);
            endDate = DateTime(picked.year, picked.month + 1, 1)
                .subtract(const Duration(seconds: 1));
            await hdp.fetchNutritionDataPoints(startDate, endDate: endDate);
            hdp.fetchHRVDataPoints(startDate, endDate: endDate);
            break;
          default:
            startDate = picked.subtract(const Duration(days: 15));
            endDate = picked.add(const Duration(days: 15));
            await hdp.fetchNutritionDataPoints(startDate, endDate: endDate);
            hdp.fetchHRVDataPoints(startDate, endDate: endDate);
            break;
        }
        hdp.updateCurrentMinDate(startDate);
        hdp.updateCurrentMaxDate(endDate);
        hdp.fetchActivityDataPoints(startDate, endDate);
        hdp.fetchSleepDataPoints(startDate, endDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDP, child) {
      return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 1,
        centerTitle: true,
        title: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () =>
                        _updateDate(context, hDP, isForward: false),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, hDP),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getTopBarString(
                                  hDP.currentTopBarSelect, hDP.currentDate),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                    onPressed: () => _updateDate(context, hDP, isForward: true),
                  ),
                  const VerticalDivider(),
                  const MyDropdownPage(),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.black,
            ),
            onPressed: () => {navigateFn!("Profile")},
          ),
        ],
      );
    });
  }
}

class MyDropdownPage extends StatelessWidget {
  const MyDropdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(
      builder: (context, hdp, child) {
        return DropdownButton<String>(
          value: hdp.currentTopBarSelect,
          icon: Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            hdp.updateCurrentTopBarSelect(newValue ?? '');
          },
          items: <String>['day', 'week', 'month']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: Theme.of(context).textTheme.titleLarge),
            );
          }).toList(),
        );
      },
    );
  }
}
