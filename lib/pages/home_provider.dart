import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/services/health_data_service.dart';
import 'package:health_app_mobile_client/util/app_states.dart';

class HomeDataProvider extends ChangeNotifier {
  final HealthDataService healthDataService = HealthDataService();
  

  List<HealthDataPoint> _currentDataPoints = [];
  List<HealthDataPoint> get currentDataPoints => _currentDataPoints;
  void updateDataPoints(List<HealthDataPoint> newDataPoints) {
    _currentDataPoints.addAll(newDataPoints);
    _currentDataPoints = healthDataService.removeDuplicates(_currentDataPoints);
    healthDataService.getSleepByDays(1, DateTime.now(), _currentDataPoints);
    notifyListeners();
  }
  Future<void> fetchDataPoints() async {
    List<HealthDataPoint> fetchedData = [];
    DateTime now = currentDate;
    int nOfDays = currentDateRange;
    DateTime endtOfDay =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final List<HealthDataAccess> permission = [
      HealthDataAccess.READ, 
      HealthDataAccess.READ, 
      HealthDataAccess.READ
    ];
    final List<HealthDataType> type = [
      HealthDataType.MOVE_MINUTES, 
      HealthDataType.SLEEP_ASLEEP, 
      HealthDataType.SLEEP_AWAKE
    ] ;
    // Check permission to read Move minutes
    updateCurrentAppState(AppState.FETCHING_DATA);
    bool permitedAcces =
        await healthDataService.checkPermissions(permission, type);
    if (!permitedAcces) {
      updateCurrentAppState(AppState.AUTH_NOT_GRANTED);
    } else {
      fetchedData = await healthDataService.fetchHealthData(
          endtOfDay.subtract(Duration(days: nOfDays)), endtOfDay, type);
      if (fetchedData.isEmpty & currentDataPoints.isEmpty) {
        updateCurrentAppState(AppState.NO_DATA);
      } else {
        updateCurrentAppState(AppState.DATA_READY);
        updateCurrentMinDate(now.subtract(Duration(days: nOfDays)));
        updateDataPoints(fetchedData); //Trigger rebuild
      }
    }
    notifyListeners();
  }

  DateTime _currentDate = DateTime.now(); //Start at current date
  DateTime get currentDate => _currentDate;
  void updateCurrentDate(DateTime newDate) {
    _currentDate = newDate;
    notifyListeners();
  }

  late DateTime _currentMinDate;
  DateTime get currentMinDate => _currentMinDate;
  void updateCurrentMinDate(DateTime newMinDate) {
    _currentMinDate = newMinDate;
    notifyListeners();
  }

  int _currentDateRange = 10; // Range of data stored
  int get currentDateRange => _currentDateRange;
  void updateCurrentDateRange(int newDateRange) {
    _currentDateRange = newDateRange;
    notifyListeners();
  }

  AppState _currentAppState = AppState.DATA_NOT_FETCHED; // Range of data stored
  AppState get currentAppState => _currentAppState;
  void updateCurrentAppState(AppState newAppState) {
    _currentAppState = newAppState;
    notifyListeners();
  }
}