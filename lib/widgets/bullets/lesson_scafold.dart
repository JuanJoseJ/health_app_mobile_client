import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/widgets/bullets/lesson_content.dart';
import 'package:health_app_mobile_client/widgets/navigation/detail_top_bar.dart';
import 'package:provider/provider.dart';

class LessonScafold extends StatefulWidget {
  final Color? cardMainColor;
  final Function(String) setPage;
  const LessonScafold({Key? key, required this.setPage, this.cardMainColor})
      : super(key: key);

  @override
  State<LessonScafold> createState() => _LessonScafoldState();
}

class _LessonScafoldState extends State<LessonScafold> {
  int sectionNumber = 0;

  void changeSection(int newSectionNumber) {
    setState(() {
      sectionNumber = newSectionNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      Map<String, dynamic> currentLesson = hdp.currentLesson;
      List<dynamic> sections = currentLesson["sections"]["sections"];
      return Scaffold(
        appBar: DetailTopBar(
          notifyParent: widget.setPage,
          chartId: "bullets",
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: LessonPageContent(
            currentLesson: currentLesson,
            sectionNumber: sectionNumber,
            sections: sections,
            setPage: widget.setPage,
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
                    icon: Icon(
                      Icons.arrow_left,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'Previous',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              Theme.of(context).textTheme.titleLarge?.fontSize,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    onPressed: () {
                      if (sectionNumber > 0) {
                        changeSection(sectionNumber - 1);
                      }
                    }, // Empty function for now
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // White background color
                      onPrimary:
                          Theme.of(context).colorScheme.onSurface, // Text color
                    ),
                  ),
                ),
              ),
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
                      if (sectionNumber < sections.length - 1) {
                        changeSection(sectionNumber + 1);
                      } else if (sectionNumber == sections.length - 1) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Lesson Almost Completed"),
                              content: const Text(
                                  "This lesson will be marked as completed after you finish the related questionnaire."),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    widget.setPage("bullets");
                                    Map<String, dynamic> newCurrentLesson =
                                        currentLesson;
                                    hdp.updateCurrentLesson(newCurrentLesson);
                                  },
                                ),
                              ],
                            );
                          },
                        );
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
