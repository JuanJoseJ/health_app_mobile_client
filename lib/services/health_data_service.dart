import 'package:health/health.dart';
import 'package:health_app_mobile_client/util/dates_util.dart';

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

  List<HealthDataPoint> removeDuplicates(List<HealthDataPoint> points) {
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
  /// and a list of [HealthDataPoint] objects [dataPoints] representing movement data
  /// points for that day. It returns a list of integers representing the accumulated
  /// activity values for each specified period throughout the day.
  ///
  /// The function generates time periods based on the number of periods and
  /// calculates the activity for each period by accumulating movement values
  /// from the provided [dataPoints]. The resulting list [activityList] contains
  /// the total activity for each specified period.
  List<int> getActivityByPeriods(
      int nPeriods, DateTime date, List<HealthDataPoint> dataPoints) {
    // !!!! Change this function, so that a list of dates can be passed to accumulate the minutes of activity
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CHANGE THIS
    //First make sure to take the correct time period
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endtOfDay =
        DateTime(date.year, date.month, date.day).add(const Duration(days: 1));

    final List<HealthDataPoint> cleanMoveMinutes = [...dataPoints];
    cleanMoveMinutes
        .removeWhere((element) => element.type != HealthDataType.MOVE_MINUTES);

    final List<DateTime> periods = calcPeriods(nPeriods, startOfDay);

    // Initialize the activityList with zeros for each period
    List<int> activityList = List.generate(nPeriods, (index) => 0);

    // Iterate over the data and accumulate the values for each period
    for (HealthDataPoint dataPoint in cleanMoveMinutes) {
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

  /// The getSleepByDays function calculates the total sleep duration over
  /// a specified number of days leading up to a given date from a list of
  /// health data points (hdp). It filters the relevant sleep data points
  /// within the specified date range, sums their corresponding sleep durations,
  /// and returns the total sleep duration.
  double getSleepByDays(int nDays, DateTime date, List<HealthDataPoint> hdp) {
    // Debo mostrar esto como un porcentaje del día transcurrido

    List<HealthDataPoint> clearHdp = [...hdp];
    double totSleep = 0;
    clearHdp.removeWhere((element) =>
        element.type != HealthDataType.SLEEP_ASLEEP ||
        !isSameDate(element.dateTo, date));
    for (HealthDataPoint p in clearHdp) {
      totSleep += double.parse(p.value.toString());
    }
    return totSleep;
  }

  List<double> getBurnedCalByPeriod(
      int nPeriods, DateTime date, List<HealthDataPoint> dataPoints) {

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endtOfDay =
        DateTime(date.year, date.month, date.day).add(const Duration(days: 1));

    final List<HealthDataPoint> cleanCaloriesList = [...dataPoints];
    cleanCaloriesList
        .removeWhere((element) => element.type != HealthDataType.ACTIVE_ENERGY_BURNED);

    final List<DateTime> periods = calcPeriods(nPeriods, startOfDay);

    // Initialize the activityList with zeros for each period
    List<double> caloriesList = List.generate(nPeriods, (index) => 0);

    for (HealthDataPoint dataPoint in cleanCaloriesList) {
      for (int i = 0; i < periods.length - 1; i++) {
        if (dataPoint.dateFrom.isAfter(periods[i]) &&
            dataPoint.dateFrom.isBefore(periods[i + 1])) {
          // Add the value to the corresponding period
          caloriesList[i] += double.parse(dataPoint.value.toString());
          break; // Move to the next data point
        }
      }
    }

    return caloriesList;
  }
}

