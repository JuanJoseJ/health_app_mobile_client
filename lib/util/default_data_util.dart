import 'package:health/health.dart';

class DefaultDataPoint {
  DateTime dateFrom;
  DateTime dateTo;
  HealthValue value;
  HealthDataType type;
  HealthDataUnit unit;

  // Constructor
  DefaultDataPoint({
    required this.dateFrom,
    required this.dateTo,
    required this.value,
    required this.type,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateFrom': dateFrom.toIso8601String(),
      'dateTo': dateTo.toIso8601String(),
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
}