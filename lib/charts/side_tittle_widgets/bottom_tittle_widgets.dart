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

Widget Function(double value, TitleMeta meta) weeklyThirdsBTW() {
  return (double value, TitleMeta meta) {
    String text;
    // Assuming the week starts on Monday and ends on Sunday
    switch (value.toInt()) {
      case 0:
        text = 'M'; // Monday
        break;
      case 3:
        text = 'W'; // Wednesday
        break;
      case 6:
        text = 'S'; // Sunday
        break;
      default:
        return const SizedBox.shrink(); // Empty widget for other values
    }

    return Text(text, style: TextStyle(color: Colors.black54));
  };
}

Widget Function(double value, TitleMeta meta) monthlyThirdsBTW(DateTime date) {
  return (double value, TitleMeta meta) {
    Widget textWidget;
    // Calculate the start and end dates of the month
    DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    if (value.toInt()+1 == 1 || value.toInt()+1 == 15 || value.toInt()+1 == lastDayOfMonth.day) {
      textWidget =
          Text('${value.toInt()+1}', style: const TextStyle(color: Colors.black54));
    } else {
      textWidget = const SizedBox.shrink(); // Empty widget for other values
    }
    return textWidget;
  };
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
