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
        // Prevent newDate from exceeding today's date
        if (newDate.isAfter(startOfToday)) {
          newDate = startOfToday;
        }
        startDate = newDate;
        endDate = newDate;
        //Fetch data if not present for the days
        if (startDate.isBefore(provider.currentMinDate)) {
          provider.fetchDataPoints(
              startDate.subtract(const Duration(days: 10)), startOfToday);
          provider.updateCurrentMinDate(
              startDate.subtract(const Duration(days: 10)));
        }
        provider.updateCurrentDate(newDate);
        break;
      case 'week':
        int daysToAdjust = isForward ? 7 : -7;
        newDate = currentDate.add(Duration(days: daysToAdjust));
        // Adjust startOfWeek to ensure it doesn't start in the future
        DateTime startOfWeek =
            newDate.subtract(Duration(days: newDate.weekday - 1));
        if (startOfWeek.isAfter(startOfToday)) {
          newDate = startOfToday;
          startOfWeek =
              startOfToday.subtract(Duration(days: startOfToday.weekday - 1));
          startDate = startOfWeek;
          endDate = today;
        } else {
          startDate = startOfWeek;
          endDate = startOfWeek.add(Duration(days: 6));
        }
        provider.fetchDataPoints(startDate, endDate);
        provider.updateCurrentMinDate(startDate);
        provider.updateCurrentDate(endDate);
        break;
      case 'month':
        int monthsToAdjust = isForward ? 1 : -1;
        newDate = DateTime(currentDate.year, currentDate.month + monthsToAdjust,
            currentDate.day);
        // Prevent navigating to a future month
        if (newDate.isAfter(DateTime(today.year, today.month + 1, 0))) {
          newDate = DateTime(today.year, today.month, today.day);
        }
        startDate = DateTime(newDate.year, newDate.month, 1);
        endDate = DateTime(newDate.year, newDate.month + 1, 0);
        provider.fetchDataPoints(startDate, endDate);
        provider.updateCurrentMinDate(startDate);
        provider.updateCurrentDate(endDate);
        break;
      default:
        return;
    }
  }

  Future<void> _selectDate(
      BuildContext context, HomeDataProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(provider.currentDate.year, provider.currentDate.month,
          provider.currentDate.day),
    );

    if (picked != null && picked != provider.currentDate) {
      provider.updateCurrentDate(picked);
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
                    onPressed: (hDP.currentDate.isAfter(DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day)
                            .subtract(const Duration(seconds: 1))))
                        ? null
                        : () => _updateDate(context, hDP, isForward: true),
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
