import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/exercise.dart';

/// A custom dropdown widget for selecting workout exercises
/// Provides a visually enhanced dropdown with icons for each exercise type
/// Used in both workout creation and set editing contexts
class ExerciseDropdown extends StatelessWidget {
  /// The currently selected exercise
  final Exercise value;

  /// Callback function triggered when the selection changes
  /// Passes the newly selected exercise or null if cleared
  final ValueChanged<Exercise?> onChanged;

  const ExerciseDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildContainerDecoration(),
      child: _buildDropdownFormField(context),
    );
  }

  /// Builds the decorative container styling for the dropdown
  /// Uses gradient background to match app theme
  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.grey.shade50,
        ],
      ),
    );
  }

  /// Builds the main dropdown form field with exercise options
  Widget _buildDropdownFormField(BuildContext context) {
    return DropdownButtonFormField<Exercise>(
      value: value,
      decoration: _buildInputDecoration(context),
      dropdownColor: Colors.white,
      items: _buildDropdownItems(context),
      onChanged: _handleSelectionChange,
      icon: _buildDropdownIcon(context),
      isExpanded: true, // Ensures full width utilization
      style: const TextStyle(
        color: Color(0xFF2D3436),
        fontSize: 16,
      ),
    );
  }

  /// Builds the input decoration for the dropdown field
  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      labelText: 'Exercise',
      prefixIcon: Icon(
        _getExerciseIcon(value),
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      labelStyle: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Builds all dropdown menu items for available exercises
  List<DropdownMenuItem<Exercise>> _buildDropdownItems(BuildContext context) {
    return Exercise.values.map((Exercise exercise) {
      return DropdownMenuItem<Exercise>(
        value: exercise,
        child: _buildDropdownItemContent(context, exercise),
      );
    }).toList();
  }

  /// Builds the content for each dropdown menu item
  /// Includes icon and exercise name for better visual identification
  Widget _buildDropdownItemContent(BuildContext context, Exercise exercise) {
    return Row(
      children: [
        Icon(
          _getExerciseIcon(exercise),
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          exercise.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  /// Builds the dropdown arrow icon
  Widget _buildDropdownIcon(BuildContext context) {
    return Icon(
      Icons.arrow_drop_down,
      color: Theme.of(context).colorScheme.primary,
      size: 28,
    );
  }

  /// Handles selection changes and provides validation
  /// Ensures non-null selection before triggering callback
  void _handleSelectionChange(Exercise? newValue) {
    if (newValue != null) {
      onChanged(newValue);
      debugPrint('Exercise selection changed to: ${newValue.displayName}');
    } else {
      debugPrint('Warning: Attempted to select null exercise');
    }
  }

  /// Maps exercise types to appropriate Material Design icons
  /// Provides visual cues to help users identify exercises quickly
  ///
  /// Returns:
  /// - [IconData]: The corresponding icon for the given exercise
  IconData _getExerciseIcon(Exercise exercise) {
    switch (exercise) {
      case Exercise.barbellRow:
        return Icons.drag_handle; // Represents horizontal rowing motion
      case Exercise.benchPress:
        return Icons.airline_seat_flat; // Represents bench position
      case Exercise.shoulderPress:
        return Icons.accessibility_new; // Represents overhead press position
      case Exercise.deadlift:
        return Icons.fitness_center; // Generic weight lifting icon
      case Exercise.squat:
        return Icons.chair_alt; // Represents squatting position
    }
  }

  /// Validates that all exercises have corresponding icons
  /// Useful for development and testing
  @visibleForTesting
  static bool validateAllExercisesHaveIcons() {
    final dropdown = ExerciseDropdown(
      value: Exercise.benchPress,
      onChanged: (_) {},
    );

    try {
      for (final exercise in Exercise.values) {
        dropdown._getExerciseIcon(exercise);
      }
      return true;
    } catch (e) {
      debugPrint('Error validating exercise icons: $e');
      return false;
    }
  }
}

/// Extension on Exercise enum to provide additional utility methods
extension ExerciseExtensions on Exercise {
  /// Returns a description of the exercise for accessibility
  String get description {
    switch (this) {
      case Exercise.barbellRow:
        return 'Upper body pulling exercise targeting back muscles';
      case Exercise.benchPress:
        return 'Upper body pushing exercise targeting chest muscles';
      case Exercise.shoulderPress:
        return 'Overhead pressing exercise targeting shoulder muscles';
      case Exercise.deadlift:
        return 'Full body compound exercise targeting posterior chain';
      case Exercise.squat:
        return 'Lower body compound exercise targeting leg muscles';
    }
  }

  /// Returns the primary muscle groups targeted by this exercise
  List<String> get primaryMuscles {
    switch (this) {
      case Exercise.barbellRow:
        return ['Back', 'Biceps', 'Rear Delts'];
      case Exercise.benchPress:
        return ['Chest', 'Triceps', 'Front Delts'];
      case Exercise.shoulderPress:
        return ['Shoulders', 'Triceps', 'Upper Chest'];
      case Exercise.deadlift:
        return ['Hamstrings', 'Glutes', 'Lower Back', 'Traps'];
      case Exercise.squat:
        return ['Quadriceps', 'Glutes', 'Core'];
    }
  }
}
