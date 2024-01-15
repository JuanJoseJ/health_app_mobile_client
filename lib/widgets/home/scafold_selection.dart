import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/widgets/home/detail_widgets/detail_display.dart';
import 'package:health_app_mobile_client/widgets/home/resume_widgets/cards_display.dart';

class DataScafold extends StatefulWidget {
  const DataScafold({super.key});

  @override
  State<DataScafold> createState() => _DataScafoldState();
}

class _DataScafoldState extends State<DataScafold> {
  int _currentIndex = 0;

  navigate() {
    setState(() {
      _currentIndex = 1 - 1 * _currentIndex;
    });
  }

  Widget pageSelector() {
    Widget page;
    switch (_currentIndex) {
      case 0:
        page = CardsScafold(navigateFn: navigate);
        break;
      case 1:
        page = const DetailScafold();
        break;
      default:
        page = CardsScafold();
    }
    return page;
  }

  @override
  Widget build(BuildContext context) {
    return pageSelector();
  }
}
