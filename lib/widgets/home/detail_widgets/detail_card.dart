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
        IconButton(
          onPressed: () {
            changeDate();
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () {
            changeDate();
          },
          icon: Icon(Icons.arrow_forward, color: Colors.black),
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
    return Expanded(
      child: Row(
        children: [
          Expanded(
              child: Column(
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      topCardTitle(context), 
                      dateSubTitle(context),
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
          )),
        ],
      ),
    );
  }
}
