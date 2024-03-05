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
    print("TARGET DATE: $targetDate");
    // print("INCOMPLETED LESSONS: $incompleteLessonForDate");

    try {
      List<Map<String, dynamic>> userLessons = await fetchUsersLessons(userId);
      List<Map<String, dynamic>> allLessons = await fetchLessons();

      // Filter out lessons for the specific target date
      List<Map<String, dynamic>> lessonsForTargetDate = userLessons.where((ul) {
        DateTime lessonDate = (ul['date'] as Timestamp).toDate();
        return lessonDate.year == targetDate.year &&
            lessonDate.month == targetDate.month &&
            lessonDate.day == targetDate.day;
      }).toList();
      print("COMPLETED LESSON IN SERVICE: $lessonsForTargetDate");

      // Find a completed lesson for the target date, if any
      var completedLessonForDate = lessonsForTargetDate.firstWhere(
        (ul) => ul['completed'],
        orElse: () => <String, dynamic>{},
      );
      // Find an incomplete lesson for the target date, if any
      var incompleteLessonForDate = lessonsForTargetDate.firstWhere(
        (ul) => !ul['completed'],
        orElse: () => <String, dynamic>{},
      );

      if (completedLessonForDate.isNotEmpty) {
        lessonToReturn = allLessons.firstWhere(
          (lesson) => lesson['id'] == completedLessonForDate['lessonId'],
          orElse: () => <String, dynamic>{},
        );
        lessonToReturn['completed'] = true;
        // print("COMPLETED LESSON: $lessonToReturn");
      } else if (incompleteLessonForDate.isNotEmpty &&
          completedLessonForDate.isEmpty) {
        lessonToReturn = allLessons.firstWhere(
          (lesson) => lesson['id'] == incompleteLessonForDate['lessonId'],
          orElse: () => <String, dynamic>{},
        );
        lessonToReturn['completed'] = false;
        // print("NON-COMPLETED LESSON: $lessonToReturn");
      } else {
        // If no lesson was assigned for the target date, assign a new one
        List<Map<String, dynamic>> candidateLessons = allLessons
            .where((lesson) => (!userLessons.any((ul) =>
                (ul['lessonId'] == lesson['id'] && ul["completed"] == true))))
            .toList();

        if (candidateLessons.isNotEmpty) {
          Map<String, dynamic> newUserLesson = {
            "date": targetDate,
            "userId": userId,
            "lessonId": candidateLessons.first["id"],
            "completed": false,
          };
          await addUserLesson(
              newUserLesson); // Function to assign the new lesson to the user
          lessonToReturn = candidateLessons.first;
          lessonToReturn['completed'] = false;
          // print("NEW ASSIGNED LESSON: $lessonToReturn");
        }
      }

      List<Map<String, dynamic>> questions =
          await fetchQuestionaryByLesson(lessonToReturn["id"]);

      lessonToReturn["questions"] = questions;
    } catch (e) {
      print("Error getting today's lesson: $e");
      // ignore: unused_local_variable
      Map<String, dynamic> lessonToReturn = {};
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

  Future<void> completeQuiz(String lessonId, String userId) async {
    // Query the 'user_lesson' collection for documents that match the criteria
    QuerySnapshot querySnapshot = await db
        .collection('user_lesson')
        .where('lessonId', isEqualTo: lessonId)
        .where('userId', isEqualTo: userId)
        .where('completed', isEqualTo: false)
        .get();

    // Iterate over the documents and delete each one
    for (var doc in querySnapshot.docs) {
      await db.collection('user_lesson').doc(doc.id).delete();
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsersFood(String userId,
      {DateTime? startDate, DateTime? endDate}) async {
    List<Map<String, dynamic>> userFood = [];
    final userFoodCol = db.collection("user_food");

    // If only startDate is provided, set endDate to the end of startDate day
    if (startDate != null && endDate == null) {
      endDate =
          DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);
    }

    // Prepare the query with optional date range filtering
    Query query = userFoodCol.where("userId", isEqualTo: userId);

    // Apply date range filtering if dates are provided
    if (startDate != null) {
      query = query.where("date", isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      // Adjust to include the end of the day for endDate, if not already adjusted
      query = query.where("date", isLessThanOrEqualTo: endDate);
    }

    // Execute the query
    await query.get().then((value) {
      for (var doc in value.docs) {
        var foodRegister = doc["food_register"] as List;
        userFood.add({
          "date": doc["date"],
          "food_register": foodRegister.map((fr) {
            return {
              "amount": fr["amount"],
              "group": fr["group"],
              "name": fr["name"],
              "unit": fr["unit"],
            };
          }).toList(),
        });
      }
    }, onError: (e) {
      throw e;
    });

    return userFood;
  }

  Future<void> addUserFood(Map<String, dynamic> userFood) async {
    final userFoodCol = db.collection("user_food");
    try {
      await userFoodCol.add(userFood);
      print("User food added successfully.");
    } catch (e) {
      print("Error adding user food: $e");
      rethrow;
    }
  }
}
