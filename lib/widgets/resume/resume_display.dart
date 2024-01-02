import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/my_home_page.dart';
import 'package:health_app_mobile_client/widgets/resume/resume_cards.dart';

class ResumeCardsScafold extends StatelessWidget {
  final AppState? appState;
  const ResumeCardsScafold(this.appState, {super.key});

  Widget _myCards() {
    return const Padding(
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
                    )),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
    ;
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

  Widget _content() {
    if (appState == AppState.FETCHING_DATA) {
      return _loading();
    } else if (appState == AppState.DATA_NOT_FETCHED) {
      return _contentNotFetched();
    } else if (appState == AppState.NO_DATA) {
      return _contentNoData();
    } else if (appState == AppState.AUTH_NOT_GRANTED) {
      return _notAuthorized();
    } else {
      return _myCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _content();
  }
}
