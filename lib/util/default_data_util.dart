import 'package:health/health.dart';
import 'package:intl/intl.dart';

class DefaultDataPoint {
  DateTime dateFrom;
  DateTime? dateTo;
  HealthValue value;
  HealthDataType type;
  HealthDataUnit unit;

  // Constructor
  DefaultDataPoint({
    required this.dateFrom,
    this.dateTo,
    required this.value,
    required this.type,
    required this.unit,
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
    NumericHealthValue duration = NumericHealthValue(sleepData['seconds']
            .toDouble() /
        60); // Assuming duration is provided in seconds, converting to minutes

    // Determine the HealthDataType based on the 'level' field in sleepData
    HealthDataType sleepType;
    switch (sleepData['level']) {
      case 'asleep':
        sleepType = HealthDataType.SLEEP_ASLEEP;
        break;
      case 'awake':
        sleepType = HealthDataType.SLEEP_AWAKE;
        break;
      case 'light':
        sleepType = HealthDataType.SLEEP_LIGHT;
        break;
      case 'restless':
        sleepType = HealthDataType.SLEEP_LIGHT;
        break;
      case 'deep':
        sleepType = HealthDataType.SLEEP_DEEP;
        break;
      case 'rem':
        sleepType = HealthDataType.SLEEP_REM;
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
}