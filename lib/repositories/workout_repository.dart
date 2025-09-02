import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';

/// Repository class responsible for persisting and retrieving workout data
/// Uses SharedPreferences for local storage with JSON serialization
class WorkoutRepository {
  static const String _workoutsKey = 'workouts';

  /// Retrieves all stored workouts from SharedPreferences
  /// Returns an empty list if no workouts are found or if there's an error
  /// 
  /// Throws:
  /// - [FormatException] if stored JSON is malformed
  /// - [Exception] for other storage-related errors
  Future<List<Workout>> getWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getStringList(_workoutsKey) ?? [];
      
      return workoutsJson
          .map((json) => Workout.fromJson(jsonDecode(json)))
          .toList();
    } on FormatException catch (e) {
      debugPrint('Error parsing workout JSON: $e');
      // Return empty list instead of crashing the app
      return [];
    } catch (e) {
      debugPrint('Error loading workouts from storage: $e');
      rethrow; // Propagate unexpected errors
    }
  }

  /// Saves a workout to local storage
  /// If a workout with the same ID exists, it will be updated
  /// If no workout with the ID exists, a new one will be added
  /// 
  /// Parameters:
  /// - [workout]: The workout object to save
  /// 
  /// Throws:
  /// - [Exception] if save operation fails
  Future<void> saveWorkout(Workout workout) async {
    try {
      final workouts = await getWorkouts();
      final index = workouts.indexWhere((w) => w.id == workout.id);
      
      if (index >= 0) {
        // Update existing workout
        workouts[index] = workout;
        debugPrint('Updated existing workout with ID: ${workout.id}');
      } else {
        // Add new workout
        workouts.add(workout);
        debugPrint('Added new workout with ID: ${workout.id}');
      }
      
      await _saveWorkouts(workouts);
    } catch (e) {
      debugPrint('Error saving workout: $e');
      rethrow;
    }
  }

  /// Deletes a workout with the specified ID
  /// If no workout with the given ID exists, the operation completes silently
  /// 
  /// Parameters:
  /// - [id]: The unique identifier of the workout to delete
  /// 
  /// Throws:
  /// - [Exception] if delete operation fails
  Future<void> deleteWorkout(String id) async {
    try {
      final workouts = await getWorkouts();
      final initialLength = workouts.length;
      
      workouts.removeWhere((w) => w.id == id);
      
      if (workouts.length < initialLength) {
        debugPrint('Deleted workout with ID: $id');
      } else {
        debugPrint('No workout found with ID: $id');
      }
      
      await _saveWorkouts(workouts);
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      rethrow;
    }
  }

  /// Checks if a workout with the given ID exists
  /// 
  /// Parameters:
  /// - [id]: The unique identifier to check
  /// 
  /// Returns:
  /// - [bool]: true if workout exists, false otherwise
  Future<bool> workoutExists(String id) async {
    try {
      final workouts = await getWorkouts();
      return workouts.any((workout) => workout.id == id);
    } catch (e) {
      debugPrint('Error checking if workout exists: $e');
      return false;
    }
  }

  /// Gets the total number of workouts stored
  /// 
  /// Returns:
  /// - [int]: The count of stored workouts
  Future<int> getWorkoutCount() async {
    try {
      final workouts = await getWorkouts();
      return workouts.length;
    } catch (e) {
      debugPrint('Error getting workout count: $e');
      return 0;
    }
  }

  /// Clears all stored workout data
  /// This operation cannot be undone
  /// 
  /// Throws:
  /// - [Exception] if clear operation fails
  @visibleForTesting
  Future<void> clearAllWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_workoutsKey);
      debugPrint('Cleared all workout data');
    } catch (e) {
      debugPrint('Error clearing workout data: $e');
      rethrow;
    }
  }

  /// Internal method to persist the workout list to SharedPreferences
  /// Converts all workouts to JSON format and stores them
  /// 
  /// Parameters:
  /// - [workouts]: List of workouts to persist
  /// 
  /// Throws:
  /// - [Exception] if storage operation fails
  Future<void> _saveWorkouts(List<Workout> workouts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = workouts
          .map((workout) => jsonEncode(workout.toJson()))
          .toList();
      
      await prefs.setStringList(_workoutsKey, workoutsJson);
      debugPrint('Successfully saved ${workouts.length} workouts to storage');
    } catch (e) {
      debugPrint('Error saving workouts to storage: $e');
      rethrow;
    }
  }

  /// Validates the integrity of stored workout data
  /// Useful for detecting corruption or data inconsistencies
  /// 
  /// Returns:
  /// - [bool]: true if all data is valid, false if corruption detected
  @visibleForTesting
  Future<bool> validateStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getStringList(_workoutsKey) ?? [];
      
      // Try to parse each JSON string
      for (final json in workoutsJson) {
        try {
          final decoded = jsonDecode(json);
          Workout.fromJson(decoded); // Will throw if invalid
        } catch (e) {
          debugPrint('Invalid workout JSON detected: $json');
          return false;
        }
      }
      
      debugPrint('All stored workout data is valid');
      return true;
    } catch (e) {
      debugPrint('Error validating stored data: $e');
      return false;
    }
  }

  /// Exports all workout data as a JSON string
  /// Useful for backup or data transfer purposes
  /// 
  /// Returns:
  /// - [String]: JSON representation of all workouts
  Future<String> exportData() async {
    try {
      final workouts = await getWorkouts();
      return jsonEncode(workouts.map((w) => w.toJson()).toList());
    } catch (e) {
      debugPrint('Error exporting workout data: $e');
      rethrow;
    }
  }

  /// Imports workout data from a JSON string
  /// Replaces all existing workout data
  /// 
  /// Parameters:
  /// - [jsonData]: JSON string containing workout data
  /// 
  /// Throws:
  /// - [FormatException] if JSON is malformed
  /// - [Exception] if import operation fails
  @visibleForTesting
  Future<void> importData(String jsonData) async {
    try {
      final List<dynamic> decodedData = jsonDecode(jsonData);
      final workouts = decodedData
          .map((json) => Workout.fromJson(json))
          .toList();
      
      await _saveWorkouts(workouts);
      debugPrint('Successfully imported ${workouts.length} workouts');
    } on FormatException catch (e) {
      debugPrint('Invalid JSON format during import: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error importing workout data: $e');
      rethrow;
    }
  }
}