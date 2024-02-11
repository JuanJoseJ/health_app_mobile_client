import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/services/google_fit_data_service.dart';
import 'package:health_app_mobile_client/util/app_states.dart';

class HomeDataProvider extends ChangeNotifier {
  final GoogleFitDataService healthDataService = GoogleFitDataService();

  List<HealthDataPoint> _currentDataPoints = [];
  List<HealthDataPoint> get currentDataPoints => _currentDataPoints;
  void updateDataPoints(List<HealthDataPoint> newDataPoints) {
    _currentDataPoints.addAll(newDataPoints);
    _currentDataPoints = healthDataService.removeDuplicates(_currentDataPoints);
    healthDataService.getSleepByDays(1, DateTime.now(), _currentDataPoints);
    notifyListeners();
  }

  Future<void> fetchDataPoints(DateTime startDate, DateTime endDate) async {
    final List<HealthDataAccess> permission = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ
    ];
    final List<HealthDataType> type = [
      HealthDataType.MOVE_MINUTES,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    // Check permission to read Move minutes
    updateCurrentAppState(AppState.FETCHING_DATA);
    bool permitedAcces =
        await healthDataService.checkPermissions(permission, type);
    if (!permitedAcces) {
      updateCurrentAppState(AppState.AUTH_NOT_GRANTED);
    } else {
      List<HealthDataPoint> fetchedData =
          await healthDataService.fetchHealthData(startDate, endDate, type);
      if (fetchedData.isEmpty & currentDataPoints.isEmpty) {
        updateCurrentAppState(AppState.NO_DATA);
      } else {
        // Update your data points with the fetched data
        updateDataPoints(fetchedData);
        updateCurrentAppState(AppState.DATA_READY);

        DateTime tempMinDate = currentMinDate;
        if (startDate.isBefore(currentMinDate) || startDate.isAfter(currentMaxDate)) {
          updateCurrentMinDate(startDate);
        }
        if (endDate.isAfter(currentMaxDate) || endDate.isBefore(tempMinDate)) {
          updateCurrentMaxDate(endDate);
        }
      }
    }
    notifyListeners();
  }

  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1).subtract(const Duration(seconds: 1)); //Start at current date
  DateTime get currentDate => _currentDate;
  void updateCurrentDate(DateTime newDate) {
    _currentDate = newDate;
    notifyListeners();
  }

    DateTime _currentMinDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day); // Initialize with a default value
  DateTime get currentMinDate => _currentMinDate;
  void updateCurrentMinDate(DateTime newMinDate) {
    _currentMinDate = newMinDate;
    notifyListeners();
  }

  DateTime _currentMaxDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime get currentMaxDate => _currentMaxDate;
  void updateCurrentMaxDate(DateTime newMaxDate) {
    _currentMaxDate = newMaxDate;
    notifyListeners();
  }

  AppState _currentAppState = AppState.DATA_NOT_FETCHED; // Range of data stored
  AppState get currentAppState => _currentAppState;
  void updateCurrentAppState(AppState newAppState) {
    _currentAppState = newAppState;
    notifyListeners();
  }

  String _currentTopBarSelect = 'day';
  String get currentTopBarSelect => _currentTopBarSelect;
  void updateCurrentTopBarSelect(String newTopBarSelect) {
    if (newTopBarSelect != _currentTopBarSelect) {
      _currentTopBarSelect = newTopBarSelect;
      _currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1).subtract(const Duration(minutes: 1));
      switch (newTopBarSelect) {
        case 'day':
          _currentMinDate = DateTime(
              _currentDate.year, _currentDate.month, _currentDate.day - 10);
          fetchDataPoints(_currentMinDate, _currentDate);
          break;
        case 'week':
          int weekday = _currentDate.weekday;
          _currentMinDate = _currentDate.subtract(Duration(days: weekday - 1));
          fetchDataPoints(_currentMinDate, _currentDate);
          break;
        case 'month':
          _currentMinDate = DateTime(_currentDate.year, _currentDate.month, 1);
          fetchDataPoints(_currentMinDate, _currentDate);
          break;
      }
      notifyListeners();
    }
  }
}
