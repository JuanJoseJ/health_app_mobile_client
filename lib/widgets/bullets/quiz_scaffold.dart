import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/bullets/quiz_content.dart';
import 'package:health_app_mobile_client/widgets/navigation/detail_top_bar.dart';
import 'package:provider/provider.dart';

class QuizScaffold extends StatefulWidget {
  final Color? cardMainColor;
  final Function(String) setPage;
  const QuizScaffold({Key? key, required this.setPage, this.cardMainColor})
      : super(key: key);

  @override
  State<QuizScaffold> createState() => _QuizScaffoldState();
}

class _QuizScaffoldState extends State<QuizScaffold> {
  int sectionNumber = 0;
  int points = 0;
  String? selectedAnswer;
  List<String> listOfSelectedAnswers = [];

  void changeSelectedAnswer(String? newSelectedAnswer) {
    setState(() {
      selectedAnswer = newSelectedAnswer;
    });
    print("!!!!! SELECTED ANSWER: $selectedAnswer");
  }

  void changeSection(int newSectionNumber) {
    setState(() {
      sectionNumber = newSectionNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("LIST OF ANSWERS: $listOfSelectedAnswers");
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      Map<String, dynamic> currentLesson = hdp.currentLesson;
      List<dynamic> sections = currentLesson["sections"]["sections"];
      int calculatePoints() {
        int points = 0;
        for (var answer in listOfSelectedAnswers) {
          for (var question in currentLesson["questions"]) {
            if ([...question["correct_answers"]].contains(answer)) {
              points++;
            }
          }
        }
        return points;
      }

      return Scaffold(
        appBar: DetailTopBar(
          notifyParent: widget.setPage,
          chartId: "bullets",
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: QuizPageContent(
            currentLesson: currentLesson,
            sectionNumber: sectionNumber,
            questions: currentLesson["questions"],
            setPage: widget.setPage,
            selectedAnswerFunction: changeSelectedAnswer,
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Ensures buttons don't touch
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: Text(
                      'Next',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              Theme.of(context).textTheme.titleLarge?.fontSize,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    label: Icon(
                      Icons.arrow_right,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      listOfSelectedAnswers.add(selectedAnswer!);
                      if (sectionNumber < sections.length - 1) {
                        changeSection(sectionNumber + 1);
                      } else if (sectionNumber == sections.length - 1) {
                        int points = calculatePoints();
                        if (points >=
                            (currentLesson["questions"].length * 0.6)) {
                              DateTime currentDate = DateTime(hdp.currentBulletDate.year, hdp.currentBulletDate.month, hdp.currentBulletDate.day);
                          Map<String, dynamic> newUserLesson = {
                            "date": currentDate,
                            "userId": hdp.uid,
                            "lessonId": currentLesson["id"],
                            "completed": true,
                          };
                          hdp.fireStoreDataService.addUserLesson(newUserLesson);
                          hdp.completeQuiz(currentLesson["id"]);
                          hdp.currentLesson["completed"] = true;
                          setState(() {
                            selectedAnswer = null;
                          });
                        }
                        widget.setPage("bullets");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // White background color
                      onPrimary:
                          Theme.of(context).colorScheme.onSurface, // Text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
