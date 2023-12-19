import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

class HealthDataService {
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  // Check a list of permissions, and ask for authorization if required.
  Future<bool> checkPermissions(
      List<HealthDataAccess> permissions, List<HealthDataType> types) async {
    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);
    if (!hasPermissions!) {
      try {
        hasPermissions =
            await health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorization: $error");
      }
    }
    return hasPermissions!;
  }

  Future<List<HealthDataPoint>> fetchHealthData(
      DateTime start, DateTime end, List<HealthDataType> types) async {
    List<HealthDataPoint> healthDataList = [];
    try {
      healthDataList = await health.getHealthDataFromTypes(start, end, types);
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }
    healthDataList = HealthFactory.removeDuplicates(healthDataList);
    return healthDataList;
  }

  // Ill work on the steps only if it is required in the future
  Future<int> fetchStepData(DateTime start, DateTime end) async {
    int steps = 0;
    return steps;
  }

  Future revokePermissions() async {
    try {
      await health.revokePermissions();
    } catch (error) {
      print("Caught exception in revokeAccess: $error");
    }
  }

  // Returns a list of minutes of activity for equal periods of time in a day
  //!!!!!!!!!! CHANGE THIS !!!!!!!!!!!!!!!!!!!!!!!!
  // Change this, so you fetch data once for around ten days ONCE at the init of the state of the mainPage
  // Then, make this function filter periods of single days from THAT list when you want to get the lists.
  // Finally, make the functions that generates the bars for: A DAY, A MONTH, and A YEAR.
  Future<List<int>> getDailyActivityByPeriods(
      int nPeriods, DateTime endTime) async {
    //First make sure to take the correct time period
    final startOfDay = DateTime(endTime.year, endTime.month, endTime.day);
    final endtOfDay = DateTime(endTime.year, endTime.month, endTime.day)
        .add(const Duration(days: 1));
    final List<HealthDataAccess> permission = [HealthDataAccess.READ];
    final List<HealthDataType> type = [HealthDataType.MOVE_MINUTES];
    // Check permission to read Move minutes
    if (!await checkPermissions(permission, type)) {
      throw Exception("Permissions not granted");
    }
    final List<DateTime> periods = List.generate(nPeriods + 1, (index) {
      final valueToAdd = ((index * 24) / nPeriods);
      double minutes = (valueToAdd - valueToAdd.floor()) * 60;
      return startOfDay
          .add(Duration(hours: valueToAdd.floor(), minutes: minutes.toInt()));
    });
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // DONT FETCH DATA HERE
    List<HealthDataPoint> moveMinutes =
        await fetchHealthData(startOfDay, endtOfDay, type);
    // Initialize the activityList with zeros for each period
    List<int> activityList = List.generate(nPeriods, (index) => 0);
    // Iterate over the fetched data and accumulate the values for each period
    for (HealthDataPoint dataPoint in moveMinutes) {
      for (int i = 0; i < periods.length - 1; i++) {
        if (dataPoint.dateFrom.isAfter(periods[i]) &&
            dataPoint.dateFrom.isBefore(periods[i + 1])) {
          // Add the value to the corresponding period
          activityList[i] += int.parse(dataPoint.value.toString());
          break; // Move to the next data point
        }
      }
    }
    return activityList;
  }

  //Change this function later when the pulling of the data is done
  Future myBarChartDataGroups(BuildContext context) async {
    List<BarChartGroupData> tempBarCharts = [];
    // thisBarCharts.clear();
    try {
      DateTime now = DateTime.now().subtract(Duration(days: 2));
      int nPeriods = 3;

      List<int> result =
          await HealthDataService().getDailyActivityByPeriods(nPeriods, now);
      for (var value in result) {
        tempBarCharts.add(
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: value.toDouble(),
                color: Colors.orangeAccent,
              ),
            ],
          ),
        );
      }

      print("Activity List: $result");
      // setState(() {
      //   thisBarCharts.addAll(tempBarCharts);
      // });
      // print("This barchart: $thisBarCharts");
    } catch (e) {
      print("$e");
    }
  }
}
