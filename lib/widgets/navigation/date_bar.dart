import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DateBar extends StatelessWidget implements PreferredSizeWidget {
  const DateBar({Key? key});

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

  void _updateDate(BuildContext context, HomeDataProvider provider,
      {required bool isForward}) {
    DateTime newDate;
    DateTime startDate;
    DateTime endDate;
    final currentDate = provider.currentDate;
    final topBarSelect = provider.currentTopBarSelect;
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
          if (newDate.isBefore(provider.currentMinDate) ||
              newDate.isAfter(provider.currentMaxDate)) {
            provider.fetchActivityDataPoints(
                startDate.subtract(const Duration(days: 5)),
                endDate.add(const Duration(days: 5)));
            provider.fetchSleepDataPoints(
                startDate.subtract(const Duration(days: 5)),
                endDate.add(const Duration(days: 5)));
            provider.fetchHRVDataPoints(
                startDate.subtract(const Duration(days: 5)),
                endDate: endDate.add(const Duration(days: 5)));
          }
          provider.updateCurrentDate(newDate);
          provider.fetchNutritionDataPoints(startDate);
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
          provider.fetchActivityDataPoints(startDate, endDate);
          provider.fetchSleepDataPoints(startDate, endDate);
          provider.fetchNutritionDataPoints(startDate, endDate: endDate);
          provider.fetchHRVDataPoints(startDate,  endDate: endDate);
          provider.updateCurrentMinDate(startDate);
          provider.updateCurrentMaxDate(endDate);
          provider.updateCurrentDate(startDate);
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
          provider.fetchActivityDataPoints(startDate, endDate);
          provider.fetchSleepDataPoints(startDate, endDate);
          provider.fetchNutritionDataPoints(startDate, endDate: endDate);
          provider.fetchHRVDataPoints(startDate,  endDate: endDate);
          provider.updateCurrentMinDate(startDate);
          provider.updateCurrentMaxDate(endDate);
          provider.updateCurrentDate(startDate);
          break;
        } else {
          return;
        }
      default:
        return;
    }
  }

  Future<void> _selectDate(
      BuildContext context, HomeDataProvider provider) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    late DateTime startDate;
    late DateTime endDate;
    DateTime currentDate = provider.currentDate;

    if (picked != null && picked != currentDate) {
      provider.updateCurrentDate(picked);
      if (picked.isBefore(currentDate) || picked.isAfter(currentDate)) {
        switch (provider.currentTopBarSelect) {
          case 'day':
            startDate = picked.subtract(const Duration(days: 5));
            endDate = picked.add(const Duration(days: 5));
            provider.fetchNutritionDataPoints(startDate);
            provider.fetchHRVDataPoints(startDate, endDate: endDate);
            break;
          case 'week':
            startDate = DateTime(picked.year, picked.month, picked.day)
                .subtract(Duration(days: picked.weekday - 1));
            endDate = startDate
                .add(const Duration(days: 7))
                .subtract(const Duration(seconds: 1));
            provider.fetchNutritionDataPoints(startDate, endDate: endDate);
            provider.fetchHRVDataPoints(startDate,  endDate: endDate);
            break;
          case 'month':
            startDate = DateTime(picked.year, picked.month, 1);
            endDate = DateTime(picked.year, picked.month + 1, 1)
                .subtract(const Duration(seconds: 1));
            provider.fetchNutritionDataPoints(startDate, endDate: endDate);
            provider.fetchHRVDataPoints(startDate,  endDate: endDate);
            break;
          default:
            startDate = picked.subtract(const Duration(days: 5));
            endDate = picked.add(const Duration(days: 5));
            provider.fetchNutritionDataPoints(startDate, endDate: endDate);
            provider.fetchHRVDataPoints(startDate,  endDate: endDate);
            break;
        }
        provider.updateCurrentMinDate(startDate);
        provider.updateCurrentMaxDate(endDate);
        provider.fetchActivityDataPoints(startDate, endDate);
        provider.fetchSleepDataPoints(startDate, endDate);
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
      );
    });
  }
}

class MyDropdownPage extends StatelessWidget {
  const MyDropdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(
      builder: (context, homeDataProvider, child) {
        return DropdownButton<String>(
          value: homeDataProvider.currentTopBarSelect,
          icon: Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            homeDataProvider.updateCurrentTopBarSelect(newValue ?? '');
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
