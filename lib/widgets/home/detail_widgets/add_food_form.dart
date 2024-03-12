import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/util/dates_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // For input formatters

class FoodFormCard extends StatefulWidget {
  final String date;
  const FoodFormCard({
    super.key,
    required this.date,
  });

  @override
  State<FoodFormCard> createState() => _FoodFormCardState();
}

class _FoodFormCardState extends State<FoodFormCard> {
  String? selectedValue;

  Row topCardTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Register food",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final Map<String, dynamic> _formData = {};

    Widget FoodGroupDropdown4FormState(BuildContext context) {
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

      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Food Group',
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        value: selectedValue,
        hint: Text('Select group'),
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
        onSaved: (value) {
          _formData["group"] = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a food group';
          }
          return null; // means no error
        },
        items: foodGroups.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
    }

    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      topCardTitle(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("Date: ${widget.date}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: FoodGroupDropdown4FormState(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                          ),
                          onSaved: (value) {
                            _formData['name'] = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Amount',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onSaved: (value) {
                            _formData['amount'] = int.tryParse(value!);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Units',
                          ),
                          onSaved: (value) {
                            _formData['units'] = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              _formData['date'] = parseCustomDateString(widget.date);

                              hdp.addFoodRecord(_formData);
                              hdp.fetchNutritionDataPoints(hdp.currentDate);

                              print(_formData);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Submission successful.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please correct the errors in the form.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
