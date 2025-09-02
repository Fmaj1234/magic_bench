import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_bench/repositories/workout_repository.dart';
import 'package:magic_bench/models/workout.dart';
import 'package:magic_bench/models/workout_set.dart';
import 'package:magic_bench/models/exercise.dart';

void main() {
  group('WorkoutRepository Tests', () {
    late WorkoutRepository repository;
    late List<Workout> testWorkouts;

    setUpAll(() async {
      // Set up test environment
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      repository = WorkoutRepository();

      testWorkouts = [
        Workout(
          id: 'workout-1',
          date: DateTime.utc(2024, 3, 15, 10, 0),
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
          date: DateTime.utc(2024, 3, 16, 11, 0),
          sets: [
            WorkoutSet(
              id: 'set-2',
              exercise: Exercise.squat,
              weight: 100.0,
              repetitions: 8,
            ),
            WorkoutSet(
              id: 'set-3',
              exercise: Exercise.deadlift,
              weight: 120.0,
              repetitions: 5,
            ),
          ],
        ),
      ];
    });

    test('should return empty list when no workouts stored', () async {
      final workouts = await repository.getWorkouts();
      expect(workouts, isEmpty);
    });

    test('should save and retrieve single workout', () async {
      await repository.saveWorkout(testWorkouts[0]);
      
      final retrievedWorkouts = await repository.getWorkouts();
      
      expect(retrievedWorkouts.length, 1);
      expect(retrievedWorkouts[0].id, testWorkouts[0].id);
      expect(retrievedWorkouts[0].sets.length, 1);
      expect(retrievedWorkouts[0].sets[0].exercise, Exercise.benchPress);
    });

    test('should save and retrieve multiple workouts', () async {
      for (final workout in testWorkouts) {
        await repository.saveWorkout(workout);
      }
      
      final retrievedWorkouts = await repository.getWorkouts();
      
      expect(retrievedWorkouts.length, 2);
      expect(retrievedWorkouts.map((w) => w.id), containsAll(['workout-1', 'workout-2']));
    });

    test('should update existing workout when saved with same ID', () async {
      // Save original workout
      await repository.saveWorkout(testWorkouts[0]);
      
      // Create updated version with same ID
      final updatedWorkout = Workout(
        id: testWorkouts[0].id, // Same ID
        date: testWorkouts[0].date,
        sets: [
          WorkoutSet(
            id: 'updated-set',
            exercise: Exercise.deadlift,
            weight: 80.0,
            repetitions: 6,
          ),
        ],
      );
      
      await repository.saveWorkout(updatedWorkout);
      
      final retrievedWorkouts = await repository.getWorkouts();
      
      expect(retrievedWorkouts.length, 1); // Still only one workout
      expect(retrievedWorkouts[0].sets[0].exercise, Exercise.deadlift);
      expect(retrievedWorkouts[0].sets[0].weight, 80.0);
    });

    test('should delete workout successfully', () async {
      // Save both workouts
      for (final workout in testWorkouts) {
        await repository.saveWorkout(workout);
      }
      
      // Verify they exist
      var retrievedWorkouts = await repository.getWorkouts();
      expect(retrievedWorkouts.length, 2);
      
      // Delete one workout
      await repository.deleteWorkout('workout-1');
      
      // Verify it's deleted
      retrievedWorkouts = await repository.getWorkouts();
      expect(retrievedWorkouts.length, 1);
      expect(retrievedWorkouts[0].id, 'workout-2');
    });

    test('should handle deleting non-existent workout', () async {
      await repository.saveWorkout(testWorkouts[0]);
      
      // Try to delete workout that doesn't exist - should not throw
      await repository.deleteWorkout('non-existent-id');
      
      // Original workout should still exist
      final retrievedWorkouts = await repository.getWorkouts();
      expect(retrievedWorkouts.length, 1);
      expect(retrievedWorkouts[0].id, testWorkouts[0].id);
    });

    test('should preserve complex workout data', () async {
      final complexWorkout = Workout(
        id: 'complex-workout',
        date: DateTime.utc(2024, 6, 15, 14, 30, 45),
        sets: [
          WorkoutSet(id: 'set-1', exercise: Exercise.benchPress, weight: 40.5, repetitions: 10),
          WorkoutSet(id: 'set-2', exercise: Exercise.benchPress, weight: 45.0, repetitions: 8),
          WorkoutSet(id: 'set-3', exercise: Exercise.deadlift, weight: 70.5, repetitions: 8),
        ],
      );

      await repository.saveWorkout(complexWorkout);
      final retrievedWorkouts = await repository.getWorkouts();
      final retrievedWorkout = retrievedWorkouts.first;

      expect(retrievedWorkout.id, complexWorkout.id);
      expect(retrievedWorkout.sets.length, 3);
      expect(retrievedWorkout.sets[0].weight, 40.5);
      expect(retrievedWorkout.sets[1].weight, 45.0);
      expect(retrievedWorkout.sets[2].exercise, Exercise.deadlift);
    });
  });
}