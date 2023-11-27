import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/widgets/resume/resume_cards.dart';

class ResumeCardsScafold extends StatelessWidget {
  const ResumeCardsScafold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Expanded(
                        child: ResumeCard(
                      title: "Activity",
                      myIcon: Icon(
                        Icons.fitness_center,
                        color: Colors.orangeAccent,
                      ),
                    )),
                  ],
                )),
                Expanded(
                    child: Column(
                  children: [
                    Expanded(
                        child: ResumeCard(
                      title: "Days",
                      myIcon: Icon(
                        Icons.self_improvement,
                        color: Colors.redAccent,
                      ),
                    )),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Expanded(
                        child: ResumeCard(
                      title: "Food",
                      myIcon: Icon(
                        Icons.restaurant,
                        color: Colors.green
                        ,
                      ),
                    )),
                  ],
                )),
                Expanded(
                    child: Column(
                  children: [
                    Expanded(
                        child: ResumeCard(
                      title: "Sleep",
                      myIcon: Icon(
                        Icons.hotel,
                        color: Colors.lightBlueAccent,
                      ),
                    )),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
