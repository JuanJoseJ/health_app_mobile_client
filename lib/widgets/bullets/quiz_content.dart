import 'package:flutter/material.dart';

class QuizPageContent extends StatefulWidget {
  const QuizPageContent({
    super.key,
    required this.currentLesson,
    required this.sectionNumber,
    required this.questions,
    required this.setPage,
    required this.selectedAnswerFunction,
  });

  final Map<String, dynamic> currentLesson;
  final int sectionNumber;
  final List<Map<String, dynamic>> questions;
  final Function(String) setPage;
  final Function(String) selectedAnswerFunction;

  @override
  State<QuizPageContent> createState() => _QuizPageContentState();
}

class _QuizPageContentState extends State<QuizPageContent> {
  int? selectedIndex;
  @override
  Widget build(BuildContext context) {
    List answersList = [
      ...widget.questions[widget.sectionNumber]["correct_answers"]
    ];
    answersList.addAll(widget.questions[widget.sectionNumber]["wrong_answers"]);
    return Column(
      children: [
        Text("${widget.currentLesson["name"]}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.displaySmall?.fontSize,
                color: Colors.blueAccent)),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Text("Question ${widget.sectionNumber + 1}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Text(
                widget.currentLesson["questions"][widget.sectionNumber]
                    ["question"],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.bodyMedium?.fontSize)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: answersList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: ListTile(
                    title: Text(answersList[index]),
                    leading: selectedIndex != index
                        ? Icon(Icons.circle_outlined)
                        : Icon(Icons.circle),
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      widget.selectedAnswerFunction(answersList[index]);
                      print("SELECTED INDEX: $selectedIndex");
                      // Optionally, you can proceed to the next question or show feedback here
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


// List answersList = [...questions[sectionNumber]["correct_answers"]];
//     answersList.addAll(questions[sectionNumber]["wrong_answers"]);