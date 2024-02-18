import 'package:flutter/material.dart';

class BulletCard extends StatefulWidget {
  final Color? cardMainColor;
  final String title;
  final String description;
  final bool completed;
  final List<dynamic> sections;
  final String? source;
  final Function(String) setPage;
  const BulletCard(
      {super.key,
      this.cardMainColor,
      required this.title,
      required this.description,
      required this.completed,
      required this.sections,
      required this.setPage,
      this.source});

  @override
  State<BulletCard> createState() => _BulletCardState();
}

class _BulletCardState extends State<BulletCard> {
  bool checked = true;
  late Color? cardMainColor;
  late String title;
  late String description;

  @override
  void initState() {
    super.initState();
    cardMainColor = widget.cardMainColor;
    title = widget.title;
    description = widget.description;
  }

  Widget leftBulletCard() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                color: cardMainColor,
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
          ),
          Text(
            description,
            style: TextStyle(
                // color: cardMainColor,
                fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget rightBulletCard() {
    late IconData? checkIcon;
    if (widget.completed) {
      checkIcon = Icons.check_circle;
    } else {
      checkIcon = Icons.radio_button_unchecked;
    }
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Icon(checkIcon, color: cardMainColor, size: 50.0),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.arrow_forward, color: cardMainColor),
              onPressed: () => widget.setPage("lesson"),
              iconSize: 50.0,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leftBulletCard(),
              rightBulletCard(),
            ],
          ),
        ),
      ),
    );
  }
}
