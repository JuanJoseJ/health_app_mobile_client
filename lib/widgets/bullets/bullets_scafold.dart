import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/bullets/bullet_card.dart';
import 'package:health_app_mobile_client/widgets/navigation/bullets_top_bar.dart';
import 'package:provider/provider.dart';

class BulletsScafold extends StatelessWidget {
  final Function(String) setPage;
  const BulletsScafold({Key? key, required this.setPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      return Scaffold(
        appBar: const BulletsTopBar(),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: [
              BulletCard(
                cardMainColor: Colors.blueAccent,
                title: "${hdp.currentLesson["name"]}",
                description: hdp.currentLesson["description"],
                completed: hdp.currentLesson["completed"],
                source: hdp.currentLesson["source"],
                setPage: setPage,
                pageName: "lesson",
              ),
              BulletCard(
                cardMainColor: Colors.orangeAccent,
                title: "Test: ${hdp.currentLesson["name"]}",
                description:
                    "Test for the topic of: ${hdp.currentLesson["name"]}",
                completed: hdp.currentLesson["completed"],
                setPage: setPage,
                pageName: "quiz",
              ),
              // BulletCard(
              //   cardMainColor: Colors.red,
              //   title: "SOME TITLE",
              //   description:
              //       "This should be a description about the function of clicking this",
              //   completed: true,
              //   setPage: setPage,
              // ),
              // BulletCard(
              //   cardMainColor: Colors.green,
              //   title: "SOME TITLE",
              //   description:
              //       "This should be a description about the function of clicking this",
              //   completed: true,
              //   setPage: setPage,
              // ),
            ],
          ),
        ),
      );
    });
  }
}
