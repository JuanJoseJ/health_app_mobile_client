import 'package:health/health.dart';
import 'package:intl/intl.dart';

class DefaultDataPoint {
  DateTime dateFrom;
  DateTime? dateTo;
  HealthValue value;
  HealthDataType type;
  HealthDataUnit unit;
  String? name;

  // Constructor
  DefaultDataPoint({
    required this.dateFrom,
    this.dateTo,
    required this.value,
    required this.type,
    required this.unit,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateFrom': dateFrom.toIso8601String(),
      'dateTo': dateTo != null ? dateTo!.toIso8601String() : null,
      'value': value,
      'type': type,
      'unit': unit,
    };
  }

  factory DefaultDataPoint.fromJson(Map<String, dynamic> json) {
    return DefaultDataPoint(
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      value: json['value'],
      type: json['type'],
      unit: json['unit'],
    );
  }

  factory DefaultDataPoint.fromHealthDataPoint(
      HealthDataPoint healthDataPoint) {
    return DefaultDataPoint(
        dateFrom: healthDataPoint.dateFrom,
        dateTo: healthDataPoint.dateTo,
        value: healthDataPoint.value,
        type: healthDataPoint.type,
        unit: healthDataPoint.unit);
  }

  // Factory constructor in DefaultDataPoint for sleep data with internal type determination
  factory DefaultDataPoint.fromSleepData(Map<String, dynamic> sleepData) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    DateTime dateFrom = dateFormat.parse(sleepData['startTime']);
    DateTime dateTo = dateFormat.parse(sleepData['endTime']);
    NumericHealthValue duration =
        NumericHealthValue(sleepData['seconds'].toDouble() / 60);

    // Determine the HealthDataType based on the 'level' field in sleepData
    HealthDataType sleepType;
    switch (sleepData['level']) {
      case 'asleep':
        sleepType = HealthDataType.SLEEP_ASLEEP;
        break;
      case 'awake':
        sleepType = HealthDataType.SLEEP_AWAKE;
        break;
      case 'restless':
        sleepType = HealthDataType.SLEEP_LIGHT;
        break;
      default:
        sleepType = HealthDataType.SLEEP_ASLEEP;
        break;
    }

    return DefaultDataPoint(
      dateFrom: dateFrom,
      dateTo: dateTo,
      value: duration,
      type: sleepType,
      unit: HealthDataUnit.MINUTE, // Assuming duration is measured in minutes
    );
  }

  // Factory constructor for nutrition data
  factory DefaultDataPoint.fromNutritionData(
      Map<String, dynamic> nutritionData) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    DateTime date = nutritionData.containsKey('logDate')
        ? dateFormat.parse(nutritionData['logDate'])
        : dateFormat.parse(nutritionData['dateTime']);

    HealthDataType type = HealthDataType.DIETARY_ENERGY_CONSUMED;

    // Determine the value; assume calories for food and volume for water
    num value = nutritionData.containsKey('loggedFood')
        ? nutritionData['loggedFood']['calories'].toDouble()
        : double.parse(nutritionData['value']);

    HealthDataUnit unit = HealthDataUnit.KILOCALORIE;

    String? name = nutritionData.containsKey('loggedFood')
        ? nutritionData['loggedFood']['name']
        : null;

    return DefaultDataPoint(
      dateFrom: date,
      value: NumericHealthValue(value.toDouble()),
      type: type,
      unit: unit,
      name: name,
    );
  }

  factory DefaultDataPoint.fromHRVData(Map<String, dynamic> hrvData) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime date = dateFormat.parse(hrvData['dateTime']);

    // Use HEART_RATE_VARIABILITY_SDNN for HRV data
    HealthDataType hrvType = HealthDataType.HEART_RATE_VARIABILITY_SDNN;

    // Assume 'dailyRmssd' is the relevant value for HRV data points
    num hrvValue = hrvData['value']['dailyRmssd'] != null
        ? hrvData['value']['dailyRmssd'].toDouble()
        : 0.0;

    return DefaultDataPoint(
      dateFrom: date,
      value: NumericHealthValue(hrvValue),
      type: hrvType,
      unit: HealthDataUnit
          .MILLISECOND, // Assuming RMSSD values are in milliseconds
    );
  }

  factory DefaultDataPoint.fromBreathingRateData(Map<String, dynamic> brData) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime date = dateFormat.parse(brData['dateTime']);

    HealthDataType brType = HealthDataType.RESPIRATORY_RATE;

    num brValue = brData['value']['breathingRate'] != null
        ? brData['value']['breathingRate'].toDouble()
        : 0.0;

    return DefaultDataPoint(
        dateFrom: date,
        value: NumericHealthValue(brValue),
        type: brType,
        unit: HealthDataUnit.NO_UNIT);
  }

  factory DefaultDataPoint.fromSkinTemperatureData(
      Map<String, dynamic> tsData) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime date = dateFormat.parse(tsData['dateTime']);

    HealthDataType brType = HealthDataType.BODY_TEMPERATURE;

    num tsValue = tsData['value']['nightlyRelative'] != null
        ? tsData['value']['nightlyRelative'].toDouble()
        : 0.0;

    return DefaultDataPoint(
        dateFrom: date,
        value: NumericHealthValue(tsValue),
        type: brType,
        unit: HealthDataUnit.DEGREE_CELSIUS);
  }

  factory DefaultDataPoint.fromAVGSpO2Data(Map<String, dynamic> spO2Data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime date = dateFormat.parse(spO2Data['dateTime']);

    HealthDataType brType = HealthDataType.BLOOD_OXYGEN;

    num spO2Value = spO2Data['value']['avg'] != null
        ? spO2Data['value']['avg'].toDouble()
        : 0.0;

    return DefaultDataPoint(
        dateFrom: date,
        value: NumericHealthValue(spO2Value),
        type: brType,
        unit: HealthDataUnit.PERCENT);
  }

  factory DefaultDataPoint.fromHeartRateData(Map<String, dynamic> hrData) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime date = dateFormat.parse(hrData['dateTime']);

    HealthDataType hrType = HealthDataType.HEART_RATE;

    num hrValue = hrData['value']['restingHeartRate'] != null
        ? hrData['value']['restingHeartRate'].toDouble()
        : 0.0;

    return DefaultDataPoint(
        dateFrom: date,
        value: NumericHealthValue(hrValue),
        type: hrType,
        unit: HealthDataUnit.MILLISECOND);
  }
}