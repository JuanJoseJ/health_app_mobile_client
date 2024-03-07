import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:health_app_mobile_client/widgets/navigation/detail_top_bar.dart';
import 'package:provider/provider.dart';

class OutputsListChart extends StatefulWidget {
  final Function(String) setPage;
  const OutputsListChart({super.key, required this.setPage});

  @override
  State<OutputsListChart> createState() => _OutputsListChartState();
}

class _OutputsListChartState extends State<OutputsListChart> {
  List<Widget> getOutputCards(Map<String, DefaultDataPoint> outputsMap) {
    List<Widget> outputCards = [];
    for (String key in outputsMap.keys) {
      DefaultDataPoint point = outputsMap[key]!;
      String name = key;
      DefaultDataPoint value = point;
      outputCards.add(OutputCard(name: name, value: value));
    }
    return outputCards;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      return Scaffold(
        appBar: DetailTopBar(
          notifyParent: widget.setPage,
          chartId: "bullets",
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: ListView(
          children: hdp.currentOutputVariables.isEmpty
              ? [NoOutputWidget()]
              : getOutputCards(hdp.currentOutputVariables),
        ),
      );
    });
  }
}

class NoOutputWidget extends StatelessWidget {
  const NoOutputWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("No Output to Show"),
      ],
    );
  }
}

class OutputCard extends StatelessWidget {
  final String name;
  final DefaultDataPoint value;

  const OutputCard({
    super.key,
    required this.name,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.toUpperCase(), // Displaying name in uppercase for emphasis
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.health_and_safety,
                        color: Theme.of(context).primaryColor),
                    SizedBox(width: 4),
                    Text(
                      '${value.value} ${chooseUnit(value.unit)}', // Assuming 'value' and 'unit' are available
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


String chooseUnit(HealthDataUnit unit) {
  String follow;
  switch (unit) {
    case HealthDataUnit.NO_UNIT:
      follow = '';
      break;
    case HealthDataUnit.DEGREE_CELSIUS:
      follow = '°C';
      break;
    case HealthDataUnit.PERCENT:
      follow = '%';
      break;
    default:
      follow = '';
  }

  return follow;
}
