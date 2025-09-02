import 'package:magic_bench/models/exercise.dart';

class WorkoutSet {
  final String id;
  final Exercise exercise;
  final double weight;
  final int repetitions;

  WorkoutSet({
    required this.id,
    required this.exercise,
    required this.weight,
    required this.repetitions,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'],
      exercise: Exercise.values.firstWhere(
        (e) => e.name == json['exercise'],
      ),
      weight: json['weight'].toDouble(),
      repetitions: json['repetitions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise': exercise.name,
      'weight': weight,
      'repetitions': repetitions,
    };
  }
}