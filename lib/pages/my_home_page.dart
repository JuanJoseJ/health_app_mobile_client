import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/services/health_data_service.dart';
import 'package:health_app_mobile_client/widgets/health/health_example.dart';
import 'package:health_app_mobile_client/widgets/navigation/top_bar.dart';
import 'package:health_app_mobile_client/widgets/resume/resume_display.dart';
import 'package:provider/provider.dart';

import '../widgets/navigation/bottom_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final dataPointsProvider = HealthDataProvider();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  // The data is fetched at the init state, but
  // it arrives later and triggers a rebuild
  Future<void> fetchInitialData() async {
    final HealthDataService healthDataService = HealthDataService();
    DateTime now = DateTime.now();
    int nOfDays = 10;
    DateTime endtOfDay =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final List<HealthDataAccess> permission = [HealthDataAccess.READ];
    final List<HealthDataType> type = [HealthDataType.MOVE_MINUTES];
    // Check permission to read Move minutes
    await healthDataService.checkPermissions(permission, type);
    List<HealthDataPoint> fetchedData = await healthDataService.fetchHealthData(
        endtOfDay.subtract(Duration(days: nOfDays)), endtOfDay, type);
    dataPointsProvider.updateDataPoints(fetchedData); //Trigger rebuild
    // print("New saved data points: [${dataPointsProvider.currentDataPoints}]");
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return dataPointsProvider;
      },
      child: Scaffold(
        appBar: MyTopBar(),
        // body: HealthApp(),
        body: changePage(_currentIndex),
        // body: ExampleWidget(),
        bottomNavigationBar: MyBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
    );
  }
}

Widget? changePage(int i) {
  Widget page;
  switch (i) {
    case 0:
      page = ResumeCardsScafold();
      break;
    case 1:
      page = HealthApp();
      break;
    case 2:
      page = ProfileScreen();
      break;
    default:
      page = ResumeCardsScafold();
  }
  return page;
}

// Provider allows down the tree widgets to access the fetched

class HealthDataProvider extends ChangeNotifier {
  List<HealthDataPoint> _currentDataPoints = [];
  List<HealthDataPoint> get currentDataPoints => _currentDataPoints;
  void updateDataPoints(List<HealthDataPoint> newDataPoints) {
    _currentDataPoints = newDataPoints;
    notifyListeners();
  }
}

// !!!!!!!!!!!!!!!!!!! DELETE THIS AFTERWARDS !!!!!!!!!!!!!!!!!!!!!!!!!!!
// Junst an example of how to use a provider for the initial fetched data
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthDataProvider, child) {
        // Access the data from the provider
        List<HealthDataPoint> activityData =
            healthDataProvider.currentDataPoints;

        // Use the data to build your UI
        return ListView.builder(
          itemCount: activityData.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Data: ${activityData[index]}'),
              // Add more UI elements based on the data
            );
          },
        );
      },
    );
  }
}
