import 'package:magic_bench/models/workout_set.dart';

class Workout {
  final String id;
  final DateTime date;
  final List<WorkoutSet> sets;

  Workout({
    required this.id,
    required this.date,
    required this.sets,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      date: DateTime.parse(json['date']),
      sets: (json['sets'] as List)
          .map((setJson) => WorkoutSet.fromJson(setJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }
}