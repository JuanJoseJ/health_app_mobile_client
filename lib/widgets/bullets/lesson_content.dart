import 'package:flutter/material.dart';

class LessonPageContent extends StatelessWidget {
  const LessonPageContent({
    super.key,
    required this.currentLesson,
    required this.sectionNumber,
    required this.sections,
    required this.setPage,
  });

  final Map<String, dynamic> currentLesson;
  final int sectionNumber;
  final List sections;
  final Function(String) setPage;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Lesson: ${currentLesson["name"]}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.displaySmall?.fontSize, color: Colors.blueAccent)),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Text("Section ${sectionNumber + 1}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize)),
        ),
        Expanded(
          child: Column(children: [
            Expanded(
              child: Container(color: Colors.white, padding: const EdgeInsets.all(16.0),
                child: Text(sections[sectionNumber],
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize)),
              ),
            )
          ]),
        ),
      ],
    );
  }
}
