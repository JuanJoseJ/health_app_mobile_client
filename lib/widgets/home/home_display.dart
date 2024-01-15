import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/app_states.dart';
import 'package:health_app_mobile_client/widgets/home/scafold_selection.dart';
import 'package:provider/provider.dart';

class HomeScafold extends StatelessWidget {
  const HomeScafold({super.key});

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
          return DataScafold();
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }
}
