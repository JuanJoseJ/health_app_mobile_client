import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';

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

      // Filter out lessons for the specific target date
      List<Map<String, dynamic>> lessonsForTargetDate = userLessons.where((ul) {
        DateTime lessonDate = (ul['date'] as Timestamp).toDate();
        return lessonDate.year == targetDate.year &&
            lessonDate.month == targetDate.month &&
            lessonDate.day == targetDate.day;
      }).toList();

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
      } else if (incompleteLessonForDate.isNotEmpty &&
          completedLessonForDate.isEmpty) {
        lessonToReturn = allLessons.firstWhere(
          (lesson) => lesson['id'] == incompleteLessonForDate['lessonId'],
          orElse: () => <String, dynamic>{},
        );
        lessonToReturn['completed'] = false;
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

  Future<List<DefaultDataPoint>> fetchUsersFood(
      String userId, DateTime startDate,
      {DateTime? endDate}) async {
    if (endDate == null) {
      endDate = DateTime(startDate.year, startDate.month, startDate.day + 1)
          .subtract(const Duration(seconds: 1));
    }
    List<DefaultDataPoint> userFood = [];
    DateTime thisStartDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    final userFoodCol = db.collection("user_food");

    Query query = userFoodCol.where("userId", isEqualTo: userId);

    await query.get().then((value) {
      for (var doc in value.docs) {
        var date = doc["date"] as Timestamp;
        var foodRegister = doc["food_register"] as List;
        DateTime docDate = date.toDate();
        if ((docDate.isAfter(thisStartDate) ||
                docDate.isAtSameMomentAs(thisStartDate)) &&
            (docDate.isBefore(endDate!) || docDate.isAtSameMomentAs(endDate!))) {
          for (Map fr in foodRegister) {
            userFood.add(DefaultDataPoint.fromNutritionData({
              "logDate": docDate.toString(),
              "id": doc.id,
              "amount": fr["amount"],
              "group": fr["group"],
              "name": fr["name"],
              "unit": fr["unit"],
            }));
          }
        }
      }
    }, onError: (e) {
      throw e;
    });
    return userFood;
  }

  Future<void> addFoodRecord(
      Map<String, dynamic> formData, String userId) async {
    final CollectionReference foodRecords = db.collection('user_food');

    try {
      await foodRecords.add({
        'date': formData['date'],
        "food_register": [
          {
            'group': formData['group'],
            'name': formData['name'],
            'amount': formData['amount'],
            'unit': formData['units'],
          }
        ],
        'userId': userId,
      });
      print("Food record added successfully.");
    } catch (e) {
      print("Error adding food record: $e");
      rethrow;
    }
  }
}
