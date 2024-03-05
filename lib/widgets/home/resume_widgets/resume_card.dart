import 'package:flutter/material.dart';

class ResumeCard extends StatelessWidget {
  final String title;
  final Icon myIcon;
  final StatefulWidget chart;
  final Widget bottomWidget;
  final dynamic Function(String)? notifyParent;
  final String chartId;

  const ResumeCard(
      {Key? key,
      required this.title,
      required this.myIcon,
      required this.chart,
      required this.bottomWidget,
      required this.notifyParent,
      required this.chartId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
                child: Row(
                  children: [
                    myIcon,
                    const SizedBox(width: 8.0),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(1.0),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        notifyParent!(chartId);
                      },
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
            if (title == "Food")
              IconButton(onPressed: () {}, icon: Icon(Icons.add)),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child: AspectRatio(
                aspectRatio: 1.0 / 1.0,
                child: chart,
              )),
            ],
          ),
        ),
        bottomWidget
      ]),
    );
  }
}
