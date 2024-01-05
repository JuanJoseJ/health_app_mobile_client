import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_activity_by_time.dart';
import 'package:health_app_mobile_client/charts/chart_sleep_by_time.dart';
import 'package:health_app_mobile_client/pages/my_home_page.dart';
import 'package:health_app_mobile_client/widgets/navigation/date_bar.dart';
import 'package:health_app_mobile_client/widgets/resume/resume_cards.dart';
import 'package:provider/provider.dart';

class ResumeCardsScafold extends StatelessWidget {
  const ResumeCardsScafold({super.key});

  Widget _myCards(BuildContext context) {
    return Scaffold(
      appBar: DateBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                          child: ResumeCard(
                        title: "Activity",
                        myIcon: Icon(
                          Icons.fitness_center,
                          color: Colors.orangeAccent,
                        ),
                        chart: ActivityChart(
                          leftTitle: "Minutes of activity",
                          bottomTitle: "",
                        ),
                      )),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                          child: ResumeCard(
                        title: "Days",
                        myIcon: Icon(
                          Icons.self_improvement,
                          color: Colors.redAccent,
                        ),
                        chart: ActivityChart(
                          leftTitle: "Minutes of activity",
                          bottomTitle: "",
                        ),
                      )),
                    ],
                  )),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                          child: ResumeCard(
                        title: "Food",
                        myIcon: Icon(
                          Icons.restaurant,
                          color: Colors.green,
                        ),
                        chart: ActivityChart(
                          leftTitle: "Minutes of activity",
                          bottomTitle: "",
                        ),
                      )),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                          child: ResumeCard(
                        title: "Sleep",
                        myIcon: Icon(
                          Icons.hotel,
                          color: Colors.lightBlueAccent,
                        ),
                        chart: SleepChart(),
                      )),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(20),
              child: const CircularProgressIndicator(
                strokeWidth: 10,
              )),
          const Text('Fetching data...')
        ],
      ),
    );
  }

  Widget _contentNoData() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text('No Data to show')],
      ),
    );
  }

  Widget _contentNotFetched() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Data could not be fetched'),
      ],
    );
  }

  Widget _notAuthorized() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text('Authorization not granted')],
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Consumer<HomeDataProvider>(
      builder: (context, hDataProvider, child){
        if (hDataProvider.currentAppState == AppState.FETCHING_DATA) {
          return _loading();
        } else if (hDataProvider.currentAppState == AppState.DATA_NOT_FETCHED) {
          return _contentNotFetched();
        } else if (hDataProvider.currentAppState == AppState.NO_DATA) {
          return _contentNoData();
        } else if (hDataProvider.currentAppState == AppState.AUTH_NOT_GRANTED) {
          return _notAuthorized();
        } else {
          return _myCards(context);
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }
}
