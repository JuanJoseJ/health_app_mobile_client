import 'dart:async';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/fit_bit_data_service.dart';
import 'package:health_app_mobile_client/widgets/bullets/bullets_display.dart';
import 'package:health_app_mobile_client/widgets/home/home_display.dart';
import 'package:health_app_mobile_client/widgets/navigation/top_bar.dart';
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
  final homeDataProvider = HomeDataProvider();
  final fitBitDataService = FitBitDataService();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  @override
  void dispose() {
    fitBitDataService.sub?.cancel();
    super.dispose();
  }

  Future<void> fetchInitialData() async {
    DateTime endDate = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)
        .subtract(const Duration(seconds: 1));
    DateTime startDate = endDate
        .subtract(const Duration(days: 10))
        .add(const Duration(seconds: 1));
    await homeDataProvider.fetchActivityDataPoints(startDate, endDate);

    //FETCH FOR FITBIT
    String verifier = fitBitDataService.generateCodeVerifier();
    fitBitDataService.openFitbitAuthorization(verifier);
    await fitBitDataService.initLinkListener(verifier);
    homeDataProvider.updatefitBitDataService(fitBitDataService);
    await homeDataProvider.fetchSleepDataPoints(startDate, endDate);

  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return homeDataProvider;
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
      page = HomeScafold();
      break;
    case 1:
      page = BulletsDisplay();
      break;
    case 2:
      page = const ProfileScreen();
      break;
    default:
      page = const HomeScafold();
  }
  return page;
}
