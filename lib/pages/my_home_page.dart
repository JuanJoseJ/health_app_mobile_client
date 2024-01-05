import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/services/health_data_service.dart';
import 'package:health_app_mobile_client/widgets/health/health_example.dart';
import 'package:health_app_mobile_client/widgets/navigation/top_bar.dart';
import 'package:health_app_mobile_client/widgets/resume/resume_display.dart';
import 'package:provider/provider.dart';

import '../widgets/navigation/bottom_bar.dart';

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final hDataProvider = HomeDataProvider();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  // The data is fetched at the init state, but
  // it arrives later and triggers a rebuild
  Future<void> fetchInitialData() async {
    await hDataProvider.fetchDataPoints();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return hDataProvider;
      },
      child: Scaffold(
        appBar: const MyTopBar(),
        // body: HealthApp(),
        body: pageSelector(_currentIndex),
        // body: ExampleWidget(),
        bottomNavigationBar: MyBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

Widget? pageSelector(int i) {
  Widget page;
  switch (i) {
    case 0:
      page = ResumeCardsScafold();
      break;
    case 1:
      page = HealthApp();
      break;
    case 2:
      page = const ProfileScreen();
      break;
    default:
      page = const ResumeCardsScafold();
  }
  return page;
}

// Provider allows down the tree widgets to access the fetched

class HomeDataProvider extends ChangeNotifier {
  final HealthDataService healthDataService = HealthDataService();

  List<HealthDataPoint> _currentDataPoints = [];
  List<HealthDataPoint> get currentDataPoints => _currentDataPoints;
  void updateDataPoints(List<HealthDataPoint> newDataPoints) {
    _currentDataPoints.addAll(newDataPoints);
    _currentDataPoints = healthDataService.removeDuplicates(_currentDataPoints);
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
