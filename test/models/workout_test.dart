import 'package:flutter_test/flutter_test.dart';
import 'package:magic_bench/models/workout.dart';
import 'package:magic_bench/models/workout_set.dart';
import 'package:magic_bench/models/exercise.dart';

void main() {
  group('Workout Model Tests', () {
    late WorkoutSet sampleSet1;
    late WorkoutSet sampleSet2;
    late Workout testWorkout;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.utc(2024, 3, 15, 10, 30);

      sampleSet1 = WorkoutSet(
        id: 'set-1',
        exercise: Exercise.benchPress,
        weight: 50.0,
        repetitions: 10,
      );

      sampleSet2 = WorkoutSet(
        id: 'set-2',
        exercise: Exercise.squat,
        weight: 100.0,
        repetitions: 8,
      );

      testWorkout = Workout(
        id: 'workout-1',
        date: testDate,
        sets: [sampleSet1, sampleSet2],
      );
    });

    test('should create workout with correct properties', () {
      expect(testWorkout.id, 'workout-1');
      expect(testWorkout.date, testDate);
      expect(testWorkout.sets.length, 2);
      expect(testWorkout.sets, contains(sampleSet1));
      expect(testWorkout.sets, contains(sampleSet2));
    });

    test('should serialize to JSON correctly', () {
      final json = testWorkout.toJson();

      expect(json['id'], 'workout-1');
      expect(json['date'], isA<String>());
      expect(json['date'], startsWith('2024-03-15T10:30:00'));
      expect(json['sets'], isA<List>());
      expect(json['sets'].length, 2);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'json-workout',
        'date': '2024-03-15T10:30:00.000Z',
        'sets': [
          {
            'id': 'set-1',
            'exercise': 'benchPress',
            'weight': 50.0,
            'repetitions': 10,
          },
          {
            'id': 'set-2',
            'exercise': 'squat',
            'weight': 100.0,
            'repetitions': 8,
          }
        ],
      };

      final workout = Workout.fromJson(json);

      expect(workout.id, 'json-workout');
      expect(workout.sets.length, 2);
      expect(workout.sets[0].exercise, Exercise.benchPress);
      expect(workout.sets[1].exercise, Exercise.squat);
    });

    test('should handle empty sets list', () {
      final emptyWorkout = Workout(
        id: 'empty',
        date: DateTime.utc(2024, 1, 1),
        sets: [],
      );

      expect(emptyWorkout.sets, isEmpty);

      final json = emptyWorkout.toJson();
      expect(json['sets'], isEmpty);

      final deserializedWorkout = Workout.fromJson(json);
      expect(deserializedWorkout.sets, isEmpty);
    });

    test('should preserve data through complete serialization cycle', () {
      final json = testWorkout.toJson();
      final deserializedWorkout = Workout.fromJson(json);

      expect(deserializedWorkout.id, testWorkout.id);
      expect(deserializedWorkout.sets.length, testWorkout.sets.length);

      for (int i = 0; i < testWorkout.sets.length; i++) {
        expect(deserializedWorkout.sets[i].id, testWorkout.sets[i].id);
        expect(
            deserializedWorkout.sets[i].exercise, testWorkout.sets[i].exercise);
        expect(deserializedWorkout.sets[i].weight, testWorkout.sets[i].weight);
        expect(deserializedWorkout.sets[i].repetitions,
            testWorkout.sets[i].repetitions);
      }
    });
  });
}
