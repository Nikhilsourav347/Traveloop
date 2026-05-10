import 'package:uuid/uuid.dart';

class TripModel {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final double budget;
  final double spent;
  final List<Map<String, dynamic>> activities;

  TripModel({
    String? id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.budget = 0,
    this.spent = 0,
    this.activities = const [],
  }) : id = id ?? const Uuid().v4();

  int get durationDays => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'type': type,
        'budget': budget,
        'spent': spent,
        'activities': activities,
      };

  factory TripModel.fromMap(Map<String, dynamic> map) => TripModel(
        id: map['id'] as String,
        name: map['name'] as String,
        destination: map['destination'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        type: map['type'] as String,
        budget: (map['budget'] as num).toDouble(),
        spent: (map['spent'] as num).toDouble(),
        activities: (map['activities'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
      );
}
