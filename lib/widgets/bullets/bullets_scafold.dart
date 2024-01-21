import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/widgets/bullets/bullet_card.dart';
import 'package:health_app_mobile_client/widgets/navigation/date_bar.dart';

class BulletsScafold extends StatelessWidget {
  final VoidCallback? navigateFn;
  const BulletsScafold({Key? key, this.navigateFn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DateBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: [
            BulletCard(
              cardMainColor: Colors.blueAccent,
              title: "SOME TITLE",
              description:
                  "This should be a description about the function of clicking this",
            ),
            BulletCard(
              cardMainColor: Colors.orangeAccent,
              title: "SOME TITLE",
              description:
                  "This should be a description about the function of clicking this",
            ),
            BulletCard(
              cardMainColor: Colors.red,
              title: "SOME TITLE",
              description:
                  "This should be a description about the function of clicking this",
            ),
            BulletCard(
              cardMainColor: Colors.green,
              title: "SOME TITLE",
              description:
                  "This should be a description about the function of clicking this",
            ),
          ],
        ),
      ),
    );
  }
}
