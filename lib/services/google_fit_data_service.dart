import 'package:health/health.dart';
import 'package:health_app_mobile_client/util/dates_util.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';

class GoogleFitDataService {
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

  Future<List<DefaultDataPoint>> fetchGoogleFitHealthData(
      DateTime start, DateTime end, List<HealthDataType> types) async {
    List<HealthDataPoint> healthDataList = [];
    try {
      // Fetch HealthDataPoint objects
      healthDataList = await health.getHealthDataFromTypes(start, end, types);

      // Remove duplicates from the fetched HealthDataPoint list
      healthDataList = HealthFactory.removeDuplicates(healthDataList);
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    // Convert the HealthDataPoint list (with duplicates removed) to a list of DefaultDataPoint objects
    List<DefaultDataPoint> defaultDataPoints =
        _convertHealthDataPointsToDefault(healthDataList);

    return defaultDataPoints;
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

  List<int> getActivityByPeriods(
      int nPeriods, List<DefaultDataPoint> dataPoints, DateTime startDate,
      [DateTime? endDate]) {
    // Filter only MOVE_MINUTES data points
    final List<DefaultDataPoint> cleanMoveMinutes = dataPoints
        .where((element) => element.type == HealthDataType.MOVE_MINUTES)
        .toList();


    // Generate periods based on startDate and optional endDate
    final List<DateTime> periods = calcPeriods(nPeriods, startDate, endDate);

    // Initialize the activityList with zeros for each period
    List<int> activityList = List.generate(nPeriods, (index) => 0);

    // Iterate over the data and accumulate the values for each period
    for (DefaultDataPoint dataPoint in cleanMoveMinutes) {
      for (int i = 0; i < periods.length - 1; i++) {
        if (dataPoint.dateFrom.isAfter(periods[i]) &&
            dataPoint.dateTo!.isBefore(periods[i + 1])) {
          activityList[i] += int.parse(dataPoint.value.toString());
          break;
        }
      }
    }
    return activityList;
  }

  List<double> getBurnedCalByPeriod(
      int nPeriods, DateTime date, List<DefaultDataPoint> dataPoints) {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final List<DefaultDataPoint> cleanCaloriesList = [...dataPoints];
    cleanCaloriesList.removeWhere(
        (element) => element.type != HealthDataType.ACTIVE_ENERGY_BURNED);

    final List<DateTime> periods = calcPeriods(nPeriods, startOfDay);

    // Initialize the activityList with zeros for each period
    List<double> caloriesList = List.generate(nPeriods, (index) => 0);

    for (DefaultDataPoint dataPoint in cleanCaloriesList) {
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

  List<DefaultDataPoint> _convertHealthDataPointsToDefault(
      List<HealthDataPoint> healthDataPoints) {
    // Convert each HealthDataPoint in the list to a DefaultDataPoint
    List<DefaultDataPoint> defaultDataPoints = healthDataPoints
        .map((healthDataPoint) =>
            DefaultDataPoint.fromHealthDataPoint(healthDataPoint))
        .toList();
    return defaultDataPoints;
  }
}
