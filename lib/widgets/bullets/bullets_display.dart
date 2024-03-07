import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/charts/chart_output_variables.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/app_states.dart';
import 'package:health_app_mobile_client/widgets/bullets/bullets_scafold.dart';
import 'package:health_app_mobile_client/widgets/bullets/lesson_scafold.dart';
import 'package:health_app_mobile_client/widgets/bullets/quiz_scaffold.dart';
import 'package:provider/provider.dart';

class BulletsDisplay extends StatefulWidget {
  const BulletsDisplay({super.key});

  @override
  State<BulletsDisplay> createState() => _BulletsDisplayState();
}

class _BulletsDisplayState extends State<BulletsDisplay> {
  String page = "bullets";

  void setPage(String newPage) {
    setState(() {
      page = newPage;
    });
  }

  Widget selectBulletPage() {
    switch (page) {
      case "bullets":
        return BulletsScafold(setPage: setPage);
      case "lesson":
        return LessonScafold(setPage: setPage);
      case "quiz":
        return QuizScaffold(setPage: setPage);
      case "outputs":
        return OutputsListChart(setPage: setPage);
      default:
        return BulletsScafold(setPage: setPage);
    }
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
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      if (hdp.currentAppState == AppState.FETCHING_DATA) {
        return _loading();
      } else if (hdp.currentAppState == AppState.DATA_NOT_FETCHED) {
        return _contentNotFetched();
      } else if (hdp.currentAppState == AppState.NO_DATA) {
        return _contentNoData();
      } else if (hdp.currentAppState == AppState.AUTH_NOT_GRANTED) {
        return _notAuthorized();
      } else {
        return selectBulletPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }
}
