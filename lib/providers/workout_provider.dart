import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';

class WorkoutProvider with ChangeNotifier {
  WorkoutRepository _repository = WorkoutRepository();

  List<Workout> _workouts = [];
  bool _isLoading = false;

  List<Workout> get workouts => List.unmodifiable(_workouts);
  bool get isLoading => _isLoading;

  // Testing support methods
  @visibleForTesting
  void setRepository(WorkoutRepository repository) {
    _repository = repository;
  }
  
  @visibleForTesting
  void setWorkouts(List<Workout> workouts) {
    _workouts = workouts;
    notifyListeners();
  }

  /// Loads all workouts from the repository and sorts them by date (most recent first)
  Future<void> loadWorkouts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _workouts = await _repository.getWorkouts();
      _workouts.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      // Keep the existing workouts in case of error
      // Don't clear them to maintain app state
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Saves a workout (creates new or updates existing) and reloads the list
  Future<void> saveWorkout(Workout workout) async {
    try {
      await _repository.saveWorkout(workout);
      await loadWorkouts(); // Refresh the list to reflect changes
    } catch (e) {
      debugPrint('Error saving workout: $e');
      rethrow; // Propagate error to UI for user feedback
    }
  }

  /// Deletes a workout by ID and reloads the list
  Future<void> deleteWorkout(String id) async {
    try {
      await _repository.deleteWorkout(id);
      await loadWorkouts(); // Refresh the list to reflect changes
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      rethrow; // Propagate error to UI for user feedback
    }
  }

  /// Finds a workout by its ID
  /// Returns null if no workout with the given ID exists
  Workout? getWorkoutById(String id) {
    try {
      return _workouts.firstWhere((workout) => workout.id == id);
    } catch (e) {
      debugPrint('Workout with ID $id not found');
      return null;
    }
  }

  /// Gets the total number of sets across all workouts
  int get totalSets {
    return _workouts.fold(0, (total, workout) => total + workout.sets.length);
  }

  /// Gets the total volume (weight × reps) across all workouts
  double get totalVolume {
    return _workouts.fold(0.0, (total, workout) {
      return total + workout.sets.fold(0.0, (workoutTotal, set) {
        return workoutTotal + (set.weight * set.repetitions);
      });
    });
  }

  /// Gets workouts from the last N days
  List<Workout> getRecentWorkouts(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _workouts
        .where((workout) => workout.date.isAfter(cutoffDate))
        .toList();
  }

  /// Clears all workouts (useful for testing or reset functionality)
  @visibleForTesting
  void clearWorkouts() {
    _workouts.clear();
    notifyListeners();
  }
}