import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget dailyThirdsBTW(double value, TitleMeta meta) {
  final Widget text;
  switch (value.toInt()) {
    case 0:
      text = const Icon(
        Icons.wb_twighlight,
        size: 18.0,
        color: Colors.black54,
      );
      break;
    case 1:
      text = const Icon(
        Icons.wb_sunny,
        size: 18.0,
        color: Colors.black54,
      );
      break;
    case 2:
      text = const Icon(
        Icons.nightlight,
        size: 16.0,
        color: Colors.black54,
      );
      break;
    default:
      text = const Icon(
        Icons.wb_sunny,
        size: 20.0,
        color: Colors.black54,
      );
      break;
  }

  return text;
}

Widget dailySixthsBTW(double value, TitleMeta meta) {
  final Widget text;
  switch (value.toInt()) {
    case 0:
      text = Text("4 a. m.");
      break;
    case 1:
      text = Text("8 a. m.");
      break;
    case 2:
      text = Text("12 a. m.");
      break;
    case 3:
      text = Text("4 p. m.");
      break;
    case 4:
      text = Text("8 a. m.");
      break;
    case 5:
      text = Text("12 a. m.");
      break;
    default:
      text = Text("");
      break;
  }

  return text;
}
