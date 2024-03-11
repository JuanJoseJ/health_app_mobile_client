import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/services/fire_store_data_service.dart';
import 'package:health_app_mobile_client/services/fit_bit_data_service.dart';
import 'package:health_app_mobile_client/services/google_fit_data_service.dart';
import 'package:health_app_mobile_client/util/app_states.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';

class HomeDataProvider extends ChangeNotifier {
  final GoogleFitDataService googleFitHealthDataService =
      GoogleFitDataService();

  List<DefaultDataPoint> _currentActivityDataPoints = [];
  List<DefaultDataPoint> get currentActivityDataPoints =>
      _currentActivityDataPoints;
  void updateActivityDataPoints(List<DefaultDataPoint> newDataPoints) {
    _currentActivityDataPoints = newDataPoints;
    notifyListeners();
  }

  Future<void> fetchActivityDataPoints(
      DateTime startDate, DateTime endDate) async {
    final List<HealthDataAccess> permission = [
      HealthDataAccess.READ,
      // HealthDataAccess.READ,
      // HealthDataAccess.READ
    ];
    final List<HealthDataType> type = [
      HealthDataType.MOVE_MINUTES,
      // HealthDataType.SLEEP_ASLEEP,
      // HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    // Check permission to read Move minutes
    updateCurrentAppState(AppState.FETCHING_DATA);
    bool permitedAcces =
        await googleFitHealthDataService.checkPermissions(permission, type);
    if (!permitedAcces) {
      updateCurrentAppState(AppState.AUTH_NOT_GRANTED);
    } else {
      List<DefaultDataPoint> fetchedData = await googleFitHealthDataService
          .fetchGoogleFitHealthData(startDate, endDate, type);
      if (fetchedData.isEmpty & currentActivityDataPoints.isEmpty) {
        updateCurrentAppState(AppState.NO_DATA);
      } else {
        updateActivityDataPoints(fetchedData);
        updateCurrentAppState(AppState.DATA_READY);
        updateCurrentMinDate(startDate);
        updateCurrentMaxDate(endDate);
      }
    }
  }

  late FitBitDataService _fitBitDataService;
  FitBitDataService get fitBitDataService => _fitBitDataService;
  void updatefitBitDataService(FitBitDataService fitBitDataService) {
    _fitBitDataService = fitBitDataService;
    notifyListeners();
  }

  List<DefaultDataPoint> _currentSleepDataPoints = [];
  List<DefaultDataPoint> get currentSleepDataPoints => _currentSleepDataPoints;
  void updateSleepDataPoints(List<DefaultDataPoint> newDataPoints) {
    _currentSleepDataPoints = newDataPoints;
    notifyListeners();
  }

  Future<void> fetchSleepDataPoints(
      DateTime startDate, DateTime endDate) async {
    updateCurrentAppState(AppState.FETCHING_DATA);
    List<DefaultDataPoint> fetchedData = await fitBitDataService
        .fetchFitBitSleepData(startDate, endDate: endDate);
    if (fetchedData.isEmpty & currentSleepDataPoints.isEmpty) {
    } else {
      updateSleepDataPoints(fetchedData);
      updateCurrentAppState(AppState.DATA_READY);
    }
  }

  List<DefaultDataPoint> _currentNutritionDataPoints = [];
  List<DefaultDataPoint> get currentNutritionDataPoints =>
      _currentNutritionDataPoints;
  void updateNutritionDataPoints(List<DefaultDataPoint> newDataPoints) {
    _currentNutritionDataPoints = newDataPoints;
    notifyListeners();
  }

  Future<void> fetchNutritionDataPoints(DateTime startDate,
      {DateTime? endDate}) async {
    updateCurrentAppState(AppState.FETCHING_DATA);
    DateTime fetchDate = currentDate;
    List<DefaultDataPoint> fetchedData;
    if (endDate != null) {
      fetchDate = startDate;
      fetchedData = await fitBitDataService.fetchFitBitNutritionData(fetchDate,
          endDate: endDate);
    } else {
      fetchedData = await fireStoreDataService.fetchUsersFood(uid, startDate);
    }

    updateNutritionDataPoints(fetchedData);
    updateCurrentAppState(AppState.DATA_READY);
  }

  List<DefaultDataPoint> _currentHRVDataPoints = [];
  List<DefaultDataPoint> get currentHRVDataPoints => _currentHRVDataPoints;
  void updateHRVDataPoints(List<DefaultDataPoint> newDataPoints) {
    _currentHRVDataPoints = newDataPoints;
    notifyListeners();
  }

  Future<void> fetchHRVDataPoints(DateTime startDate,
      {DateTime? endDate}) async {
    updateCurrentAppState(AppState.FETCHING_DATA);
    DateTime fetchDate = currentDate;
    if (endDate != null) {
      fetchDate = startDate;
    }
    List<DefaultDataPoint> fetchedData =
        await fitBitDataService.fetchFitBitHRVData(fetchDate, endDate: endDate);
    if (fetchedData.isEmpty & currentSleepDataPoints.isEmpty) {
      // updateCurrentAppState(AppState.NO_DATA);
    } else {
      updateHRVDataPoints(fetchedData);
      updateCurrentAppState(AppState.DATA_READY);
    }
  }

  DateTime _currentEndDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)
      .subtract(const Duration(seconds: 1)); //Start at current date
  DateTime get currentDate => _currentEndDate;
  void updateCurrentDate(DateTime newDate) {
    _currentEndDate = newDate;
    notifyListeners();
  }

  DateTime _currentMinDate = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day); // Initialize with a default value
  DateTime get currentMinDate => _currentMinDate;
  void updateCurrentMinDate(DateTime newMinDate) {
    _currentMinDate = newMinDate;
    notifyListeners();
  }

  DateTime _currentMaxDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
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
      _currentEndDate = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)
          .subtract(const Duration(minutes: 1));
      switch (newTopBarSelect) {
        case 'day':
          _currentMinDate = DateTime(_currentEndDate.year,
              _currentEndDate.month, _currentEndDate.day - 10);
          fetchActivityDataPoints(_currentMinDate, _currentEndDate);
          fetchSleepDataPoints(_currentMinDate, _currentEndDate);
          fetchNutritionDataPoints(_currentMinDate);
          fetchHRVDataPoints(_currentMinDate, endDate: _currentEndDate);
          break;
        case 'week':
          int weekday = _currentEndDate.weekday;
          _currentMinDate = _currentEndDate
              .subtract(Duration(days: weekday))
              .add(const Duration(minutes: 1));
          fetchActivityDataPoints(_currentMinDate, _currentEndDate);
          fetchSleepDataPoints(_currentMinDate, _currentEndDate);
          fetchNutritionDataPoints(_currentMinDate, endDate: _currentEndDate);
          fetchHRVDataPoints(_currentMinDate, endDate: _currentEndDate);
          break;
        case 'month':
          _currentMinDate =
              DateTime(_currentEndDate.year, _currentEndDate.month, 1);
          fetchActivityDataPoints(_currentMinDate, _currentEndDate);
          fetchSleepDataPoints(_currentMinDate, _currentEndDate);
          fetchNutritionDataPoints(_currentMinDate, endDate: _currentEndDate);
          fetchHRVDataPoints(_currentMinDate, endDate: _currentEndDate);
          break;
      }
      notifyListeners();
    }
  }

  String _uid = "";
  String get uid => _uid;
  void updateUid(String newUid) {
    _uid = newUid;
    notifyListeners();
  }

  FireStoreDataService fireStoreDataService = FireStoreDataService();

  DateTime _currentBulletDate = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day); //Start at current date
  DateTime get currentBulletDate => _currentBulletDate;
  void updateCurrentBulletDate(DateTime newDate) {
    _currentBulletDate = newDate;
    notifyListeners();
  }

  Map<String, dynamic> _currentLesson = {};
  Map<String, dynamic> get currentLesson => _currentLesson;
  void updateCurrentLesson(Map<String, dynamic> newLesson) {
    _currentLesson = newLesson;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getTodayLesson() async {
    updateCurrentAppState(AppState.FETCHING_DATA);
    try {
      Map<String, dynamic> newLesson = await fireStoreDataService
          .getTodayLesson(_uid, date: _currentBulletDate);

      updateCurrentLesson(newLesson);
      updateCurrentAppState(AppState.DATA_READY);
      return newLesson;
    } catch (e) {
      print(e);
      return {};
    }
  }

  Map<String, DefaultDataPoint> _currentOutputVariables = {};
  Map<String, DefaultDataPoint> get currentOutputVariables =>
      _currentOutputVariables;
  void updateCurrentCurrentOutputVariables(
      Map<String, DefaultDataPoint> newOutputVariables) {
    _currentOutputVariables = newOutputVariables;
    notifyListeners();
  }

  Future<Map<String, DefaultDataPoint>> fetchOutputVariables() async {
    updateCurrentAppState(AppState.FETCHING_DATA);
    try {
      DefaultDataPoint newBreathingRate = await fitBitDataService
          .fetchFitBitBreathingRateData(_currentBulletDate);
      DefaultDataPoint newSkinTemperature = await fitBitDataService
          .fetchFitBitSkinTemperatureData(_currentBulletDate);
      DefaultDataPoint newAVGSpO2 =
          await fitBitDataService.fetchFitBitAVGSpO2Data(_currentBulletDate);
      DefaultDataPoint newHeartRateAtRest = await fitBitDataService
          .fetchFitBitHeartRateAtRestData(_currentBulletDate);
      DefaultDataPoint newHRV = [
        ...await fitBitDataService.fetchFitBitHRVData(_currentBulletDate)
      ].first;

      Map<String, DefaultDataPoint> newCurrentOutputVariables = {
        "Breathing Rate": newBreathingRate,
        "Average Skin Temperature": newSkinTemperature,
        "Average SpO2": newAVGSpO2,
        "Heart Rate at Reast": newHeartRateAtRest,
        "Heart Rate Variation": newHRV
      };

      updateCurrentCurrentOutputVariables(newCurrentOutputVariables);
      updateCurrentAppState(AppState.DATA_READY);
      return newCurrentOutputVariables;
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<void> completeQuiz(String lessonId) async {
    try {
      await fireStoreDataService.completeQuiz(lessonId, uid);
    } catch (e) {
      print("Error while ending the quiz: $e");
    }
  }

  String _foodFilter = "";
  String get foodFilter => _foodFilter;
  void updateFoodFilter(String? newFoodFilter) {
    newFoodFilter != null ? _foodFilter = newFoodFilter : _foodFilter = "";
    notifyListeners();
  }
}
