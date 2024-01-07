import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/health_data_service.dart';
import 'package:health_app_mobile_client/widgets/health/health_example.dart';
import 'package:health_app_mobile_client/widgets/navigation/top_bar.dart';
import 'package:health_app_mobile_client/widgets/home/resume_display.dart';
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
  final hDataProvider = HomeDataProvider();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

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


