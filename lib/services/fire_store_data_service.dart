import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreDataService {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchLesson() async {
    List<Map<String, dynamic>> lessons = [];
    final lessonCol = db.collection("lesson");
    await lessonCol.get().then((value) {
      for (var doc in value.docs) {
        lessons.add({
          "id": doc.id,
          "created_on": doc["created_on"],
          "description": doc["description"],
          "name": doc["name"],
          "sections": {
            "sections": [...doc["sections_with_picture"]["sections"]],
            "source": doc["sections_with_picture"]["source"]
          },
          "tags": [...doc["tags"]]
        });
      }
    }, onError: ((e) {
      throw e;
    }));
    return lessons;
  }

  Future<List<Map<String, dynamic>>> fetchUsersCompletedLessons(
      String userId) async {
    List<Map<String, dynamic>> userLesson = [];
    final userLessonCol = db.collection("user_lesson");
    await userLessonCol.where("userId", isEqualTo: userId).get().then((value) {
      for (var doc in value.docs) {
        userLesson.add({"date": doc["date"], "lessonId": doc["lessonId"]});
      }
    }, onError: ((e) {
      throw e;
    }));

    return userLesson;
  }

  Future<void> addUserLesson(Map<String, dynamic> userLesson) async {
    final userLessonCol = db.collection("user_lesson");
    await userLessonCol.add(userLesson).then((value) {}, onError: ((e) {
      throw e;
    }));
  }

  Future<Map<String, dynamic>> getTodaysLesson(String userId) async {
    Map<String, dynamic> newLesson = {};
    List<Map<String, dynamic>> possibleLessons = [];

    try {
      List<Map<String, dynamic>> lessons = await fetchLesson();
      List<Map<String, dynamic>> completedLessons =
          await fetchUsersCompletedLessons(userId);
      for (var lesson in lessons) {
        bool isLessonCompleted = completedLessons.any(
            (completedLesson) => completedLesson['lessonId'] == lesson['id']);
        if (!isLessonCompleted) {
          possibleLessons.add(lesson);
        }
      }

      if (possibleLessons.isNotEmpty) {
        // !!!!!!! LESSON IS NOT ADDED UNTIL IT IS COMPLETED!
        // Map<String, dynamic> newUserLesson = {
        //   "date": DateTime.now(),
        //   "userId": userId,
        //   "lessonId": possibleLessons.first["id"]
        // };
        // await addUserLesson(newUserLesson);
        newLesson = possibleLessons.first;
      }
    } catch (e) {
      print("error getting today's lesson: $e");
    }
    return newLesson;
  }

  Future<List<Map<String, dynamic>>> fetchQuestionaryByLesson(String lessonId) async {
    List<Map<String, dynamic>> questions = [];
    final questionCol = db.collection("questionary");
    await questionCol.where("lesson_id", isEqualTo: lessonId).get().then(
        (value) {
      for (var doc in value.docs) {
        questions.add({
          "id": doc.id,
          "correct_answers": [...doc["correct_answers"]],
          "explanation": doc["explanation"],
          "question": doc["question"],
          "wrong_answers": [...doc["wrong_answers"]]
        });
      }
    }, onError: ((e) {
      throw e;
    }));
    return questions;
  }
}
