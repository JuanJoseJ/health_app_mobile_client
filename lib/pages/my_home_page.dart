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
  final dataPointsProvider = HomeDateProvider();
  AppState _state = AppState.DATA_NOT_FETCHED;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  // The data is fetched at the init state, but
  // it arrives later and triggers a rebuild
  Future<void> fetchInitialData() async {
    final HealthDataService healthDataService = HealthDataService();
    List<HealthDataPoint> fetchedData = [];
    DateTime now = DateTime.now();
    int nOfDays = 10;
    DateTime endtOfDay =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final List<HealthDataAccess> permission = [HealthDataAccess.READ];
    final List<HealthDataType> type = [HealthDataType.MOVE_MINUTES];
    // Check permission to read Move minutes
    setState(() {
      _state = AppState.FETCHING_DATA;
    });
    bool permitedAcces =
        await healthDataService.checkPermissions(permission, type);
    if (!permitedAcces) {
      setState(() {
        _state = AppState.AUTH_NOT_GRANTED;
      });
    } else {
      fetchedData = await healthDataService.fetchHealthData(
          endtOfDay.subtract(Duration(days: nOfDays)), endtOfDay, type);
      setState(() {
        if (fetchedData.isEmpty) {
          _state = AppState.NO_DATA;
        } else {
          _state = AppState.DATA_READY;
          dataPointsProvider.updateDataPoints(fetchedData); //Trigger rebuild
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return dataPointsProvider;
      },
      child: Scaffold(
        appBar: const MyTopBar(),
        // body: HealthApp(),
        body: pageSelector(_currentIndex, _state),
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

Widget? pageSelector(int i, AppState? appState) {
  Widget page;
  switch (i) {
    case 0:
      page = ResumeCardsScafold(appState);
      break;
    case 1:
      page = HealthApp();
      break;
    case 2:
      page = const ProfileScreen();
      break;
    default:
      page = const ResumeCardsScafold(null);
  }
  return page;
}

// Provider allows down the tree widgets to access the fetched

class HomeDateProvider extends ChangeNotifier {
  List<HealthDataPoint> _currentDataPoints = [];
  List<HealthDataPoint> get currentDataPoints => _currentDataPoints;
  void updateDataPoints(List<HealthDataPoint> newDataPoints) {
    _currentDataPoints = newDataPoints;
    notifyListeners();
  }

  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;
  void updateCurrentDate(DateTime newDate) {
    _currentDate = newDate;
    notifyListeners();
  }
}
