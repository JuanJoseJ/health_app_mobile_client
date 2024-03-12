import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/home/detail_widgets/add_food_form.dart';
import 'package:provider/provider.dart';

class DetailCard extends StatelessWidget {
  final String title;
  final VoidCallback changeDate;
  final Widget chart;
  final String date;
  const DetailCard({
    super.key,
    required this.title,
    required this.changeDate,
    required this.chart,
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
                title != "Food"
                    ? Column(children: [
                        topCardTitle(context),
                        dateSubTitle(context)
                      ])
                    : FoodGroupDropdown(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                    child: chart,
                  ),
                ),
              ],
            ),
          ),
        ),
        title == "Food"
            ? Expanded(
              flex: 2,
                child: Card(
                  child: FoodFormCard(
                    date: date,
                  ),
                ),
              )
            : Spacer(),
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
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Spacer(),
                DropdownButton<String>(
                  value: selectedValue,
                  hint: Text('Select group'),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                    hdp.updateFoodFilter(selectedValue);
                  },
                  items:
                      foodGroups.map<DropdownMenuItem<String>>((String value) {
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
    });
  }
}
