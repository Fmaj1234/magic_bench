import 'package:magic_bench/models/workout.dart';
import 'package:magic_bench/models/workout_set.dart';
import 'package:magic_bench/models/exercise.dart';

class TestDataHelper {
  static Workout createSampleWorkout({
    String id = 'test-workout',
    DateTime? date,
    List<WorkoutSet>? sets,
  }) {
    return Workout(
      id: id,
      date: date ?? DateTime.now(),
      sets: sets ??
          [
            WorkoutSet(
              id: 'set1',
              exercise: Exercise.benchPress,
              weight: 50.0,
              repetitions: 10,
            ),
          ],
    );
  }

  static WorkoutSet createSampleSet({
    String id = 'test-set',
    Exercise exercise = Exercise.benchPress,
    double weight = 50.0,
    int repetitions = 10,
  }) {
    return WorkoutSet(
      id: id,
      exercise: exercise,
      weight: weight,
      repetitions: repetitions,
    );
  }

  static List<Workout> createSampleWorkouts(int count) {
    return List.generate(count, (index) {
      return createSampleWorkout(
        id: 'workout-$index',
        date: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }
}
