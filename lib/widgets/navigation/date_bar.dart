import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DateBar extends StatelessWidget implements PreferredSizeWidget {
  const DateBar({Key? key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

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

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDataProvider, child) {
      return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 1,
        centerTitle: true,
        title: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  hDataProvider.updateCurrentDate(hDataProvider.currentDate
                      .subtract(const Duration(days: 1)));
                  if (hDataProvider.currentDate
                          .isAtSameMomentAs(hDataProvider.currentMinDate) ||
                      hDataProvider.currentDate
                          .isBefore(hDataProvider.currentMinDate)) {
                    hDataProvider.fetchDataPoints();
                  }
                },
                icon: Icon(Icons.arrow_back, color: Colors.black),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getTopBarString(hDataProvider.currentTopBarSelect,
                            hDataProvider.currentDate),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final startOfDay = DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day);
                  if (hDataProvider.currentDate.isBefore(startOfDay)) {
                    hDataProvider.updateCurrentDate(
                        hDataProvider.currentDate.add(const Duration(days: 1)));
                  } else {
                    null;
                  }
                },
                icon: Icon(Icons.arrow_forward, color: Colors.black),
              ),
              const VerticalDivider(),
              MyDropdownPage(),
            ],
          ),
        ),
      );
    });
  }
}

class MyDropdownPage extends StatelessWidget {
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
