import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final String title;
  final VoidCallback changeDate;
  final Widget chart;
  final Widget bottomWidget;
  final String date;
  const DetailCard({
    super.key,
    required this.title,
    required this.changeDate,
    required this.chart,
    required this.bottomWidget,
    required this.date,
  });

  Row topCardTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget dateSubTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Card(
            child: Column(
              children: [
                // topCardTitle(context),
                // dateSubTitle(context),
                FoodGroupDropdown(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                    child: chart,
                  ),
                ),
                bottomWidget,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FoodGroupDropdown extends StatefulWidget {
  @override
  _FoodGroupDropdownState createState() => _FoodGroupDropdownState();
}

class _FoodGroupDropdownState extends State<FoodGroupDropdown> {
  String? selectedValue;

  final List<String> foodGroups = [
    'whole grains',
    'refined grains or starches',
    'legumes',
    'nuts',
    'vegetables',
    'fruits',
    'red meat',
    'white meat',
    'fish',
    'eggs',
    'dairy',
    'sweets',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
          child: Row(
            children: [
              Text('Group: '),
              DropdownButton<String>(
                value: selectedValue,
                hint: Text('Select group'),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                items: foodGroups.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ))
      ],
    );
  }
}
