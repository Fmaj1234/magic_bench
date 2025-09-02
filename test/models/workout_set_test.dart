import 'package:flutter_test/flutter_test.dart';
import 'package:magic_bench/models/workout_set.dart';
import 'package:magic_bench/models/exercise.dart';

void main() {
  group('WorkoutSet Model Tests', () {
    late WorkoutSet testSet;

    setUp(() {
      testSet = WorkoutSet(
        id: 'test-set-1',
        exercise: Exercise.benchPress,
        weight: 50.0,
        repetitions: 10,
      );
    });

    test('should create workout set with correct properties', () {
      expect(testSet.id, 'test-set-1');
      expect(testSet.exercise, Exercise.benchPress);
      expect(testSet.weight, 50.0);
      expect(testSet.repetitions, 10);
    });

    test('should serialize to JSON correctly', () {
      final json = testSet.toJson();

      expect(json['id'], 'test-set-1');
      expect(json['exercise'], 'benchPress');
      expect(json['weight'], 50.0);
      expect(json['repetitions'], 10);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'json-set-1',
        'exercise': 'squat',
        'weight': 100.5,
        'repetitions': 8,
      };

      final set = WorkoutSet.fromJson(json);

      expect(set.id, 'json-set-1');
      expect(set.exercise, Exercise.squat);
      expect(set.weight, 100.5);
      expect(set.repetitions, 8);
    });

    test('should handle all exercise types in serialization', () {
      for (final exercise in Exercise.values) {
        final set = WorkoutSet(
          id: 'test-${exercise.name}',
          exercise: exercise,
          weight: 75.0,
          repetitions: 12,
        );

        final json = set.toJson();
        final deserializedSet = WorkoutSet.fromJson(json);

        expect(deserializedSet.exercise, exercise);
        expect(deserializedSet.weight, 75.0);
        expect(deserializedSet.repetitions, 12);
      }
    });

    test('should handle edge cases in serialization', () {
      final edgeCases = [
        {'weight': 0.5, 'reps': 100},
        {'weight': 200.0, 'reps': 1},
        {'weight': 42.75, 'reps': 15},
      ];

      for (final testCase in edgeCases) {
        final set = WorkoutSet(
          id: 'edge-test',
          exercise: Exercise.deadlift,
          weight: testCase['weight'] as double,
          repetitions: testCase['reps'] as int,
        );

        final json = set.toJson();
        final deserializedSet = WorkoutSet.fromJson(json);

        expect(deserializedSet.weight, testCase['weight']);
        expect(deserializedSet.repetitions, testCase['reps']);
      }
    });
  });
}