import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_bench/providers/workout_provider.dart';
import 'package:magic_bench/models/workout.dart';
import 'package:magic_bench/models/workout_set.dart';
import 'package:magic_bench/models/exercise.dart';

void main() {
  group('WorkoutProvider Tests', () {
    late WorkoutProvider provider;
    late List<Workout> testWorkouts;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = WorkoutProvider();

      testWorkouts = [
        Workout(
          id: 'workout-1',
          date: DateTime.utc(2024, 3, 15),
          sets: [
            WorkoutSet(
              id: 'set-1',
              exercise: Exercise.benchPress,
              weight: 50.0,
              repetitions: 10,
            ),
          ],
        ),
        Workout(
          id: 'workout-2',
          date: DateTime.utc(2024, 3, 16),
          sets: [
            WorkoutSet(
              id: 'set-2',
              exercise: Exercise.squat,
              weight: 100.0,
              repetitions: 8,
            ),
          ],
        ),
      ];
    });

    test('should start with empty state', () {
      expect(provider.workouts, isEmpty);
      expect(provider.isLoading, false);
    });

    test('should load empty workouts correctly', () async {
      await provider.loadWorkouts();

      expect(provider.workouts, isEmpty);
      expect(provider.isLoading, false);
    });

    test('should save workout successfully', () async {
      final newWorkout = testWorkouts[0];

      await provider.saveWorkout(newWorkout);

      expect(provider.workouts.length, 1);
      expect(provider.workouts[0].id, newWorkout.id);
      expect(provider.workouts[0].sets[0].exercise, Exercise.benchPress);
    });

    test('should delete workout successfully', () async {
      // First save a workout
      await provider.saveWorkout(testWorkouts[0]);
      expect(provider.workouts.length, 1);

      // Then delete it
      await provider.deleteWorkout('workout-1');
      expect(provider.workouts, isEmpty);
    });

    test('should find workout by ID', () async {
      await provider.saveWorkout(testWorkouts[0]);
      await provider.saveWorkout(testWorkouts[1]);

      final foundWorkout = provider.getWorkoutById('workout-1');

      expect(foundWorkout, isNotNull);
      expect(foundWorkout!.id, 'workout-1');
      expect(foundWorkout.sets[0].exercise, Exercise.benchPress);
    });

    test('should return null for non-existent workout ID', () async {
      await provider.saveWorkout(testWorkouts[0]);

      final foundWorkout = provider.getWorkoutById('non-existent');
      expect(foundWorkout, isNull);
    });

    test('should sort workouts by date descending', () async {
      await provider.saveWorkout(testWorkouts[0]); // 2024-03-15
      await provider.saveWorkout(testWorkouts[1]); // 2024-03-16

      expect(provider.workouts.length, 2);
      expect(
          provider.workouts[0].date.isAfter(provider.workouts[1].date), true);
      expect(provider.workouts[0].id, 'workout-2'); // Newer workout first
    });

    test('should handle errors gracefully', () async {
      // Test loading with no issues
      await provider.loadWorkouts();
      expect(provider.isLoading, false);

      // Test saving valid workout
      await provider.saveWorkout(testWorkouts[0]);
      expect(provider.workouts.length, 1);

      // Test deleting non-existent workout (should not throw)
      await provider.deleteWorkout('non-existent');
      expect(provider.workouts.length, 1); // Should still have the one workout
    });
  });
}
