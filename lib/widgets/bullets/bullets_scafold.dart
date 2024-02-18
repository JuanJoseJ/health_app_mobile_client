import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/bullets/bullet_card.dart';
import 'package:health_app_mobile_client/widgets/navigation/date_bar.dart';
import 'package:provider/provider.dart';

class BulletsScafold extends StatelessWidget {
  final Function(String) setPage;
  const BulletsScafold({Key? key, required this.setPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      Map<String, dynamic> currentLesson = hdp.currentLesson;
      return Scaffold(
        appBar: const DateBar(),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: [
              BulletCard(
                cardMainColor: Colors.blueAccent,
                title: "Lesson: ${currentLesson["name"]}",
                description: currentLesson["description"],
                completed: currentLesson["completed"],
                sections: currentLesson["sections"]["sections"],
                source: currentLesson["source"],
              ),
              BulletCard(
                cardMainColor: Colors.orangeAccent,
                title: "SOME TITLE",
                description:
                    "This should be a description about the function of clicking this",
                completed: true,
                sections: [],
              ),
              BulletCard(
                cardMainColor: Colors.red,
                title: "SOME TITLE",
                description:
                    "This should be a description about the function of clicking this",
                completed: true,
                sections: [],
              ),
              BulletCard(
                cardMainColor: Colors.green,
                title: "SOME TITLE",
                description:
                    "This should be a description about the function of clicking this",
                completed: true,
                sections: [],
              ),
            ],
          ),
        ),
      );
    });
  }
}
