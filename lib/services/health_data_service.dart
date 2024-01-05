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
  
  List<HealthDataPoint> removeDuplicates(List<HealthDataPoint> points){
    return HealthFactory.removeDuplicates(points);
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

  /// Calculates daily activity by dividing a day into specified periods.
  ///
  /// This function takes the number of periods [nPeriods], a specific [DateTime] [date],
  /// and a list of [HealthDataPoint] objects [moveMinutes] representing movement data
  /// points for that day. It returns a list of integers representing the accumulated
  /// activity values for each specified period throughout the day.
  ///
  /// The function generates time periods based on the number of periods and
  /// calculates the activity for each period by accumulating movement values
  /// from the provided [moveMinutes]. The resulting list [activityList] contains
  /// the total activity for each specified period.
  List<int> getDailyActivityByPeriods(
      int nPeriods, DateTime date, List<HealthDataPoint> moveMinutes) {
          // !!!! Change this function, so that a list of dates can be passed to accumulate the minutes of activity
      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CHANGE THIS
    //First make sure to take the correct time period
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endtOfDay =
        DateTime(date.year, date.month, date.day).add(const Duration(days: 1));

    // Generate the periods of time, as a list of hours [initial, end1, end2, ...]
    // each period is represented by [i, i+1]
    final List<DateTime> periods = List.generate(nPeriods + 1, (index) {
      final valueToAdd = ((index * 24) / nPeriods);
      double minutes = (valueToAdd - valueToAdd.floor()) * 60;
      return startOfDay
          .add(Duration(hours: valueToAdd.floor(), minutes: minutes.toInt()));
    });

    // Initialize the activityList with zeros for each period
    List<int> activityList = List.generate(nPeriods, (index) => 0);

    // Iterate over the data and accumulate the values for each period
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
}
