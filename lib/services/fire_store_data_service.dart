import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreDataService {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchLessons() async {
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

  Future<List<Map<String, dynamic>>> fetchUsersLessons(String userId) async {
    List<Map<String, dynamic>> userLesson = [];
    final userLessonCol = db.collection("user_lesson");
    await userLessonCol.where("userId", isEqualTo: userId).get().then((value) {
      for (var doc in value.docs) {
        userLesson.add({
          "date": doc["date"],
          "lessonId": doc["lessonId"],
          "completed": doc["completed"]
        });
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

  Future<Map<String, dynamic>> getTodayLesson(String userId,
      {DateTime? date}) async {
    DateTime targetDate = date ?? DateTime.now();
    Map<String, dynamic> lessonToReturn = {};

    try {
      List<Map<String, dynamic>> userLessons = await fetchUsersLessons(userId);
      List<Map<String, dynamic>> allLessons = await fetchLessons();

      // Check for a completed lesson for the target date
      var userLessonForDate = userLessons.firstWhere((ul) {
        if (ul['completed']) {
          DateTime lessonDate = (ul['date'] as Timestamp).toDate();
          return lessonDate.year == targetDate.year &&
              lessonDate.month == targetDate.month &&
              lessonDate.day == targetDate.day;
        }
        return false;
      }, orElse: () => {});

      // Check for any incomplete lessons
      var incompleteUserLesson = userLessons.firstWhere(
        (ul) => !ul['completed'],
        orElse: () => {},
      );

      // Retrieve the full lesson details from allLessons
      Map<String, dynamic>? fullLessonDetails;
      if (userLessonForDate.isNotEmpty || incompleteUserLesson.isNotEmpty) {
        String lessonIdToFind = userLessonForDate.isNotEmpty
            ? userLessonForDate['lessonId']
            : incompleteUserLesson['lessonId'];
        fullLessonDetails = allLessons.firstWhere(
          (lesson) => lesson['id'] == lessonIdToFind,
          orElse: () =>
              <String, dynamic>{}, // Return an empty map instead of null
        );
      }

      if (fullLessonDetails != null) {
        lessonToReturn = fullLessonDetails;
        lessonToReturn['completed'] = userLessonForDate
            .isNotEmpty; // Set based on whether it was a completed lesson for the date
        return lessonToReturn;
      }

      // If no incomplete or completed lesson for the date, find a new lesson to assign
      List<Map<String, dynamic>> candidateLessons = allLessons
          .where((lesson) =>
              !userLessons.any((ul) => ul['lessonId'] == lesson['id']))
          .toList();

      if (candidateLessons.isNotEmpty) {
        Map<String, dynamic> newUserLesson = {
          "date": targetDate,
          "userId": userId,
          "lessonId": candidateLessons.first["id"],
          "completed": false,
        };
        await addUserLesson(newUserLesson);
        lessonToReturn = candidateLessons.first;
        lessonToReturn['completed'] =
            false; // Explicitly set 'completed' to false
      }
    } catch (e) {
      print("Error getting incomplete or priority new lesson: $e");
      rethrow;
    }

    return lessonToReturn;
  }

  Future<List<Map<String, dynamic>>> fetchQuestionaryByLesson(
      String lessonId) async {
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
