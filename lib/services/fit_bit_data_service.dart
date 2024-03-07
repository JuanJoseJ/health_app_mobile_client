import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:health/health.dart';
import 'package:health_app_mobile_client/util/dates_util.dart';
import 'package:health_app_mobile_client/util/default_data_util.dart';
import 'package:health_app_mobile_client/util/fitbit_strings.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class FitBitDataService {
  FitBitStrings fitBitStrings = FitBitStrings();
  String accessToken = '';
  String refreshToken = '';
  StreamSubscription? sub;

  String generateCodeVerifier() {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    final verifierChars =
        List.generate(128, (_) => charset[random.nextInt(charset.length)])
            .join();

    return verifierChars;
  }

  String generateCodeChallenge(String verifier) {
    var bytes = utf8.encode(verifier);
    var digest = sha256.convert(bytes);
    return base64Url
        .encode(digest.bytes)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  void openFitbitAuthorization(String verifier) async {
    final clientId = fitBitStrings.clientId;
    final List<String> scopes = fitBitStrings.scopes;
    final String scopeString = scopes.join(' ');
    final codeChallenge = generateCodeChallenge(verifier);
    final Uri authorizationUrl = Uri.parse(
      'https://www.fitbit.com/oauth2/authorize'
      '?response_type=code'
      '&client_id=$clientId'
      '&code_challenge=$codeChallenge'
      '&code_challenge_method=S256'
      '&scope=${Uri.encodeComponent(scopeString)}'
      // The following line states that a login must be done by the user
      // A better aproach would be to asossiate an account with a user token,
      // but as we are only using the client authN, that is not possible.
      // A back-end server would be required.
      '&prompt=login_consent', // Remove the '_consent' to require login
    );

    if (!await launchUrl(authorizationUrl,
        mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $authorizationUrl');
    }
  }

  Future<Map<String, dynamic>> exchangeAuthorizationCodeForTokens({
    required String authorizationCode,
    required String clientId,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    final Uri tokenEndpoint = Uri.parse('https://api.fitbit.com/oauth2/token');
    Map<String, dynamic> result = {};

    final response = await http.post(
      tokenEndpoint,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'code': authorizationCode,
        'code_verifier': codeVerifier,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      // Successfully exchanged authorization code for tokens
      result = json.decode(response.body);
    } else {
      // Include error handling, for example, by setting an 'error' key in the result
      result['error'] =
          'Failed to exchange authorization code for tokens. Status code: ${response.statusCode}';
      result['details'] = json.decode(response.body);
    }
    return result;
  }

  Future<void> initLinkListener(String verifier) async {
    Completer<void> completer = Completer();
    // Cancel the previous subscription if it exists
    sub?.cancel();

    sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.queryParameters.containsKey('code')) {
        final authorizationCode = uri.queryParameters['code'];
        final tokens = await exchangeAuthorizationCodeForTokens(
            authorizationCode: authorizationCode!,
            clientId: fitBitStrings.clientId,
            codeVerifier: verifier,
            redirectUri: fitBitStrings.redirectUri);
        if (tokens.containsKey('access_token')) {
          setTokens(
              accessToken: tokens['access_token'],
              refreshToken: tokens['refresh_token']);
          if (!completer.isCompleted) {
            completer.complete(); // Ensure completer is only completed once
          }
        } else {
          if (!completer.isCompleted) {
            completer.completeError(
                "Error exchanging code for tokens: ${tokens['error']}");
          }
        }
      }
    }, onError: (err) {
      if (!completer.isCompleted) {
        completer.completeError(err);
      }
    });

    return completer.future; // Return the future
  }

  void setTokens({required String accessToken, required String refreshToken}) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  Future<dynamic> _fetchData(String endPoint) async {
    final Uri endPointUri = Uri.parse(endPoint);

    final response = await http.get(
      endPointUri,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      print("An error occurred at fetch: ${response.body}");
      throw (response.body);
    }
  }

  Future<List<DefaultDataPoint>> fetchFitBitSleepData(DateTime startDate,
      {DateTime? endDate}) async {
    String start = DateFormat(
            "yyyy-MM-dd") //Romeve a day so it is possible to calc the values for the edge date
        .format(startDate.subtract(const Duration(days: 1)));
    String end = endDate != null
        ? DateFormat("yyyy-MM-dd").format(endDate)
        : DateFormat("yyyy-MM-dd")
            .format(startDate.add(const Duration(hours: 24)));
    String endPoint =
        "https://api.fitbit.com/1.2/user/-/sleep/date/$start/$end.json";

    List<DefaultDataPoint> defaultDataPoints = [];
    try {
      var response = await _fetchData(endPoint);
      var decodedResponse = response is String
          ? json.decode(response)
          : response; // Decode if response is String
      if (decodedResponse['sleep'] != null) {
        for (var sleepRecord in decodedResponse['sleep']) {
          // Iterate through each 'data' sleep level
          for (var sleepLevel in sleepRecord['levels']['data']) {
            // Parse the sleep level to create a DefaultDataPoint
            Map<String, dynamic> sleepData = {
              'startTime': sleepLevel['dateTime'],
              'endTime': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(
                  DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                      .parse(sleepLevel['dateTime'])
                      .add(Duration(seconds: sleepLevel['seconds']))),
              'seconds': sleepLevel['seconds'], // Duration in seconds
              'level': sleepLevel['level'] // Sleep level type
            };
            defaultDataPoints.add(DefaultDataPoint.fromSleepData(sleepData));
          }
        }
      }
      return defaultDataPoints;
    } catch (e) {
      print("An error occurred at fetch sleep: $e");
      rethrow;
    }
  }

  double getTotalSleepByPeriod(List<DefaultDataPoint> hdp, DateTime startDate,
      [DateTime? endDate]) {
    // Debo mostrar esto como un porcentaje del día transcurrido

    List<HealthDataType> acceptedSleepTypes = [
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_OUT_OF_BED,
      HealthDataType.SLEEP_SESSION,
    ];

    List<DefaultDataPoint> clearHdp = [...hdp];
    double totSleep = 0;
    clearHdp.removeWhere((element) =>
        !acceptedSleepTypes.contains(element.type) ||
        !isDataPointWithinRange(
            dataPoint: element, rangeStart: startDate, rangeEnd: endDate));
    for (DefaultDataPoint p in clearHdp) {
      totSleep += double.parse(p.value.toString());
    }
    return totSleep;
  }

  Future<List<DefaultDataPoint>> fetchFitBitNutritionData(DateTime startDate,
      {DateTime? endDate}) async {
    String start = DateFormat("yyyy-MM-dd").format(startDate);
    String end = endDate != null
        ? DateFormat("yyyy-MM-dd").format(endDate)
        : DateFormat("yyyy-MM-dd")
            .format(startDate.add(const Duration(hours: 24)));

    // Food endpoint for a single day or a range
    String foodEndPoint = endDate == null
        ? "https://api.fitbit.com/1/user/-/foods/log/date/$start.json"
        : "https://api.fitbit.com/1/user/-/foods/log/caloriesIn/date/$start/$end.json";

    List<DefaultDataPoint> defaultDataPoints = [];

    try {
      // Fetch and parse food data
      var foodResponse = await _fetchData(foodEndPoint);
      var decodedFoodResponse =
          foodResponse is String ? json.decode(foodResponse) : foodResponse;
      if (decodedFoodResponse['foods'] != null) {
        for (var foodLog in decodedFoodResponse['foods']) {
          defaultDataPoints.add(DefaultDataPoint.fromNutritionData(foodLog));
        }
      } else if (decodedFoodResponse['foods-log-caloriesIn'] != null) {
        for (var foodLog in decodedFoodResponse['foods-log-caloriesIn']) {
          defaultDataPoints.add(DefaultDataPoint.fromNutritionData(foodLog));
        }
      }
      return defaultDataPoints;
    } catch (e) {
      print("An error occurred at fetch nutrition: $e");
      rethrow;
    }
  }

  Future<List<DefaultDataPoint>> fetchFitBitHRVData(DateTime startDate,
      {DateTime? endDate}) async {
    String start = DateFormat("yyyy-MM-dd").format(startDate);
    String end =
        endDate != null ? DateFormat("yyyy-MM-dd").format(endDate) : start;

    // Determine the endpoint based on whether an endDate is provided
    String hrvEndPoint = endDate == null
        ? "https://api.fitbit.com/1/user/-/hrv/date/$start.json"
        : "https://api.fitbit.com/1/user/-/hrv/date/$start/$end.json";

    List<DefaultDataPoint> defaultDataPoints = [];

    try {
      var response = await _fetchData(hrvEndPoint);

      //!!!!!!!!!! MOCK DATA I USED AS I DONT OWN A SMARTWATCH TO RECORD THIS KIND OF DATA !!!!!!!!!!!!!!!!!!!!!!!!!!!
      response = endDate == null
          ? {
              'hrv': [
                {
                  'value': {'dailyRmssd': 34.938, 'deepRmssd': 31.567},
                  'dateTime': '2024-02-15'
                }
              ]
            }
          : {
              'hrv': [
                {
                  'value': {'dailyRmssd': 62.887, 'deepRmssd': 64.887},
                  'dateTime': '2024-02-16'
                },
                {
                  'value': {'dailyRmssd': 61.887, 'deepRmssd': 64.887},
                  'dateTime': '2024-02-14'
                },
                {
                  'value': {'dailyRmssd': 60.887, 'deepRmssd': 64.887},
                  'dateTime': '2024-02-13'
                },
                {
                  'value': {'dailyRmssd': 62.887, 'deepRmssd': 64.887},
                  'dateTime': '2024-02-12'
                },
                {
                  'value': {'dailyRmssd': 61.887, 'deepRmssd': 64.887},
                  'dateTime': '2024-02-11'
                },
                {
                  'value': {'dailyRmssd': 60.887, 'deepRmssd': 64.887},
                  'dateTime': '2024-02-10'
                },
                {
                  'value': {'dailyRmssd': 62.887, 'deepRmssd': 64.887},
                  'dateTime': '2024-02-09'
                },
                {
                  'value': {'dailyRmssd': 61.887, 'deepRmssd': 64.887},
                  'dateTime': '2024-02-08'
                },
              ]
            };

      var decodedResponse =
          response is String ? json.decode(response) : response;
      // Process HRV data
      if (decodedResponse['hrv'] != null) {
        for (var hrvRecord in decodedResponse['hrv']) {
          defaultDataPoints.add(DefaultDataPoint.fromHRVData(hrvRecord));
        }
      }
      return defaultDataPoints;
    } catch (e) {
      print("An error occurred at fetch HRV: $e");
      rethrow;
    }
  }

  Future<DefaultDataPoint> fetchFitBitBreathingRateData(DateTime date) async {
    String start = DateFormat("yyyy-MM-dd").format(date);

    // Determine the endpoint based on whether an endDate is provided
    String hrvEndPoint = "https://api.fitbit.com/1/user/-/br/date/$start.json";

    List<DefaultDataPoint> defaultDataPoints = [];

    try {
      var response = await _fetchData(hrvEndPoint);
      /////////////////////////////////////////////////////////////////////
      response = {
        "br": [
          {
            "value": {"breathingRate": 17.8},
            "dateTime": "2021-10-25"
          }
        ]
      };

      var decodedResponse =
          response is String ? json.decode(response) : response;
      // Process HRV data
      if (decodedResponse['br'] != null) {
        for (var brRecord in decodedResponse['br']) {
          defaultDataPoints
              .add(DefaultDataPoint.fromBreathingRateData(brRecord));
        }
      }
      return defaultDataPoints.first;
    } catch (e) {
      print("An error occurred at fetch breathing rate: $e");
      rethrow;
    }
  }

  Future<DefaultDataPoint> fetchFitBitSkinTemperatureData(DateTime date) async {
    String start = DateFormat("yyyy-MM-dd").format(date);

    String hrvEndPoint =
        "https://api.fitbit.com/1/user/-/temp/skin/date/$start.json";

    List<DefaultDataPoint> defaultDataPoints = [];

    try {
      var response = await _fetchData(hrvEndPoint);

      response = {
        "tempSkin": [
          {
            "dateTime": "2019-12-10",
            "value": {"nightlyRelative": 0.3},
            "logType": "dedicated_temp_sensor"
          }
        ]
      };

      var decodedResponse =
          response is String ? json.decode(response) : response;
      if (decodedResponse['tempSkin'] != null) {
        for (var tempSkin in decodedResponse['tempSkin']) {
          defaultDataPoints
              .add(DefaultDataPoint.fromSkinTemperatureData(tempSkin));
        }
      }
      return defaultDataPoints.first;
    } catch (e) {
      print("An error occurred at fetch skin temperature: $e");
      rethrow;
    }
  }

  Future<DefaultDataPoint> fetchFitBitAVGSpO2Data(DateTime date) async {
    String start = DateFormat("yyyy-MM-dd").format(date);

    String hrvEndPoint =
        "https://api.fitbit.com/1/user/-/spo2/date/$start.json";

    List<DefaultDataPoint> defaultDataPoints = [];

    try {
      var response = await _fetchData(hrvEndPoint);

      response = {
        "dateTime": "2021-10-04",
        "value": {"avg": 97.5, "min": 94.0, "max": 100.0}
      };

      var decodedResponse =
          response is String ? json.decode(response) : response;
      if (decodedResponse['value'] != null) {
        defaultDataPoints
            .add(DefaultDataPoint.fromAVGSpO2Data(decodedResponse));
      }
      return defaultDataPoints.first;
    } catch (e) {
      print("An error occurred at fetch SpO2 data: $e");
      rethrow;
    }
  }

  Future<DefaultDataPoint> fetchFitBitHeartRateAtRestData(DateTime date) async {
    String start = DateFormat("yyyy-MM-dd").format(date);

    String hrvEndPoint =
        "https://api.fitbit.com/1/user/-/activities/heart/date/$start/1d.json";

    List<DefaultDataPoint> defaultDataPoints = [];

    try {
      var response = await _fetchData(hrvEndPoint);

      response = {
        "activities-heart": [
          {
            "dateTime": "2019-05-08",
            "value": {
              "customHeartRateZones": [
                {
                  "caloriesOut": 1164.09312,
                  "max": 90,
                  "min": 30,
                  "minutes": 718,
                  "name": "Below"
                },
                {
                  "caloriesOut": 203.65344,
                  "max": 110,
                  "min": 90,
                  "minutes": 74,
                  "name": "Custom Zone"
                },
                {
                  "caloriesOut": 330.76224,
                  "max": 220,
                  "min": 110,
                  "minutes": 42,
                  "name": "Above"
                }
              ],
              "heartRateZones": [
                {
                  "caloriesOut": 979.43616,
                  "max": 86,
                  "min": 30,
                  "minutes": 626,
                  "name": "Out of Range"
                },
                {
                  "caloriesOut": 514.16208,
                  "max": 121,
                  "min": 86,
                  "minutes": 185,
                  "name": "Fat Burn"
                },
                {
                  "caloriesOut": 197.92656,
                  "max": 147,
                  "min": 121,
                  "minutes": 18,
                  "name": "Cardio"
                },
                {
                  "caloriesOut": 6.984,
                  "max": 220,
                  "min": 147,
                  "minutes": 5,
                  "name": "Peak"
                }
              ],
              "restingHeartRate": 76
            }
          }
        ]
      };

      var decodedResponse =
          response is String ? json.decode(response) : response;
      if (decodedResponse['activities-heart'] != null) {
        for (var hr in decodedResponse['activities-heart']) {
          defaultDataPoints.add(DefaultDataPoint.fromHeartRateData(hr));
        }
      }
      return defaultDataPoints.first;
    } catch (e) {
      print("An error occurred at fetch skin temperature: $e");
      rethrow;
    }
  }

  // !!! I WANT TO REGISTER FOOD FROM THE APP, BUT I WONT WORK IN THAT FOR NOW AS IT IS NOT VERY IMPORTANT.
  // Future<void> createFoodLog({
  //   required String foodId, // or foodName
  //   // 	Numerical value representing the meal type. Supported: 1=Breakfast | 2=Morning Snack | 3=Lunch | 4=Afternoon Snack | 5=Dinner | 7=Anytime
  //   required String mealTypeId,
  //   required String unitId,
  //   required double amount,
  //   required DateTime date,
  //   bool favorite = false, // Optional, defaults to false
  //   String? foodName, // Optional if foodId is provided
  //   String? brandName, // Optional, used with foodName
  //   int? calories, // Optional, used with foodName
  //   // Add more optional parameters for additional nutritional information if needed
  // }) async {
  //   // Format the date parameter
  //   String formattedDate = DateFormat("yyyy-MM-dd").format(date);

  //   // Prepare the URI
  //   String requestUri = 'https://api.fitbit.com/1/user/-/foods/log.json';

  //   // Prepare the headers
  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer $accessToken',
  //     'Content-Type': 'application/json',
  //     // Add more headers as required by the API
  //   };

  //   // Prepare the body. Ensure either foodId or foodName is provided.
  //   Map<String, dynamic> body = {
  //     if (foodId.isNotEmpty) 'foodId': foodId,
  //     if (foodName != null && foodName.isNotEmpty) 'foodName': foodName,
  //     'mealTypeId': mealTypeId,
  //     'unitId': unitId,
  //     'amount': amount.toString(),
  //     'date': formattedDate,
  //     'favorite': favorite.toString(),
  //     if (brandName != null) 'brandName': brandName,
  //     if (calories != null) 'calories': calories,
  //     // Include additional nutritional information if necessary
  //   };

  //   try {
  //     // Make the POST request
  //     var response = await http.post(
  //       Uri.parse(requestUri),
  //       headers: headers,
  //       body: json.encode(body),
  //     );

  //     // Check the response
  //     if (response.statusCode == 201) {
  //       // Success
  //       print("Food log created successfully.");
  //     } else {
  //       // Handle errors
  //       print("Failed to create food log: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("An error occurred while creating food log: $e");
  //     rethrow;
  //   }
  // }
}
