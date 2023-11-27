import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/services/health_data_service.dart';
import 'package:health_app_mobile_client/widgets/health/health_example.dart';
import 'package:health_app_mobile_client/widgets/navigation/top_bar.dart';
import 'package:health_app_mobile_client/widgets/resume/resume_display.dart';

import '../widgets/navigation/bottom_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  List<HealthDataPoint> activityDataTenDays = [];
  final HealthDataService hds = new HealthDataService();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  // Fetch once the initial data, if required more can be fetched later
  Future<void> fetchInitialData() async {
    DateTime now = DateTime.now();
    DateTime endtOfDay =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final List<HealthDataType> type = [HealthDataType.MOVE_MINUTES];
    activityDataTenDays = await hds.fetchHealthData(
        endtOfDay.subtract(Duration(days: 10)), endtOfDay, type);
    //Tell the UI that a change has been made
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyTopBar(),
      body: changePage(_currentIndex),
      bottomNavigationBar: MyBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute<ProfileScreen>(
          //     builder: (context) => const ProfileScreen(),
          //   ),
          // );
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}

Widget? changePage(i) {
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
