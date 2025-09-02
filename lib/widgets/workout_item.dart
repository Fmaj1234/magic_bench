import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

/// Widget representing a complete workout in the workout list screen
/// Displays workout summary including date, exercises, sets count, and total volume
/// Provides tap-to-edit and delete functionality with Hero animation support
class WorkoutItem extends StatelessWidget {
  /// The workout data to display
  final Workout workout;

  /// Callback triggered when user taps the workout (for editing)
  final VoidCallback onTap;

  /// Callback triggered when user confirms workout deletion
  final VoidCallback onDelete;

  const WorkoutItem({
    super.key,
    required this.workout,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'workout-${workout.id}',
      child: _buildWorkoutCard(context),
    );
  }

  /// Builds the main workout card with all styling and content
  Widget _buildWorkoutCard(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: _buildCardDecoration(),
        child: _buildTappableContent(context),
      ),
    );
  }

  /// Builds the gradient decoration for the workout card
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
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

  /// Builds the tappable content area with proper interaction handling
  Widget _buildTappableContent(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint('Workout tapped for editing: ${workout.id}');
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildCardContent(context),
      ),
    );
  }

  /// Builds the main content layout of the workout card
  Widget _buildCardContent(BuildContext context) {
    return Row(
      children: [
        _buildWorkoutIcon(context),
        const SizedBox(width: 16),
        _buildWorkoutDetails(context),
        _buildActionColumn(context),
      ],
    );
  }

  /// Builds the decorative workout icon with gradient background
  Widget _buildWorkoutIcon(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.fitness_center,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Builds the expandable section containing workout details
  Widget _buildWorkoutDetails(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkoutHeader(context),
          const SizedBox(height: 8),
          _buildExerciseSummary(context),
          const SizedBox(height: 8),
          _buildWorkoutMetrics(context),
        ],
      ),
    );
  }

  /// Builds the workout header with date and sets count
  Widget _buildWorkoutHeader(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            _formatDate(workout.date),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildSetsCountBadge(context),
      ],
    );
  }

  /// Builds the badge showing the number of sets in the workout
  Widget _buildSetsCountBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${workout.sets.length} ${workout.sets.length == 1 ? 'set' : 'sets'}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Builds the exercise summary showing which exercises were performed
  Widget _buildExerciseSummary(BuildContext context) {
    return Text(
      _getExerciseSummary(),
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the bottom row with time and volume metrics
  Widget _buildWorkoutMetrics(BuildContext context) {
    return Row(
      children: [
        _buildTimeIndicator(context),
        const Spacer(),
        _buildVolumeChip(),
      ],
    );
  }

  /// Builds the time indicator showing when the workout was performed
  Widget _buildTimeIndicator(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          _formatRelativeTime(
              workout.date), // Changed from _formatTime to _formatRelativeTime
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  /// Builds the volume statistics chip showing total weight moved
  Widget _buildVolumeChip() {
    return _buildStatsChip(
      'Total Volume',
      '${_calculateTotalVolume().toInt()}kg',
      Icons.scale,
    );
  }

  /// Builds a reusable statistics chip widget
  Widget _buildStatsChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action column with delete button and navigation indicator
  Widget _buildActionColumn(BuildContext context) {
    return Column(
      children: [
        _buildDeleteButton(context),
        const SizedBox(width: 8),
        _buildNavigationIndicator(context),
      ],
    );
  }

  /// Builds the delete button with proper styling and accessibility
  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        debugPrint('Delete requested for workout: ${workout.id}');
        onDelete();
      },
      icon: Icon(
        Icons.delete_outline,
        color: Colors.red.shade400,
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
      ),
      tooltip: 'Delete workout from ${_formatDate(workout.date)}',
    );
  }

  /// Builds the navigation indicator arrow
  Widget _buildNavigationIndicator(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      color: Colors.grey.shade400,
      size: 24,
    );
  }

  /// Formats the workout date in a human-readable format
  /// Returns format: "Mon, 15 Jan"
  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  /// Formats a DateTime to relative time string (e.g., "2 hours ago")
  /// Provides human-readable time differences for better UX
  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Handle immediate past
    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    // Handle minutes
    if (difference.inMinutes < 60) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    }

    // Handle hours
    if (difference.inHours < 24) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    }

    // Handle days
    if (difference.inDays < 7) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    }

    // Handle weeks
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }

    // Handle months
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }

    // Handle years
    final years = (difference.inDays / 365).floor();
    return years == 1 ? '1 year ago' : '$years years ago';
  }

  /// Generates a summary of exercises performed in the workout
  /// Groups exercises by type and shows counts
  /// Returns format: "Bench press (3) • Squat (2)" or with "+X more" if too many
  String _getExerciseSummary() {
    // Group exercises by type and count occurrences
    final exerciseGroups = <Exercise, int>{};
    for (final set in workout.sets) {
      exerciseGroups[set.exercise] = (exerciseGroups[set.exercise] ?? 0) + 1;
    }

    // Convert to display strings with counts
    final exercises = exerciseGroups.entries
        .map((entry) => '${entry.key.displayName} (${entry.value})')
        .toList();

    // Handle display based on number of different exercises
    if (exercises.isEmpty) {
      return 'No exercises recorded';
    } else if (exercises.length <= 2) {
      return exercises.join(' • ');
    } else {
      // Show first 2 exercises and indicate there are more
      return '${exercises.take(2).join(' • ')} +${exercises.length - 2} more';
    }
  }

  /// Calculates the total volume (weight × reps) across all sets
  /// Returns the sum of all set volumes in the workout
  double _calculateTotalVolume() {
    return workout.sets.fold(0.0, (total, set) {
      return total + (set.weight * set.repetitions);
    });
  }

  /// Gets the workout duration estimate based on number of sets
  /// Assumes approximately 2-3 minutes per set including rest
  @visibleForTesting
  Duration get estimatedDuration {
    const minutesPerSet = 2.5;
    final totalMinutes = workout.sets.length * minutesPerSet;
    return Duration(minutes: totalMinutes.round());
  }

  /// Gets the number of unique exercises in the workout
  @visibleForTesting
  int get uniqueExerciseCount {
    final uniqueExercises = <Exercise>{};
    for (final set in workout.sets) {
      uniqueExercises.add(set.exercise);
    }
    return uniqueExercises.length;
  }

  /// Gets the exercise with the most sets in this workout
  @visibleForTesting
  Exercise? get primaryExercise {
    if (workout.sets.isEmpty) return null;

    final exerciseCounts = <Exercise, int>{};
    for (final set in workout.sets) {
      exerciseCounts[set.exercise] = (exerciseCounts[set.exercise] ?? 0) + 1;
    }

    return exerciseCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Gets the heaviest weight lifted in this workout
  @visibleForTesting
  double get maxWeight {
    if (workout.sets.isEmpty) return 0.0;
    return workout.sets
        .map((set) => set.weight)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Determines if this workout represents a high-volume session
  /// Based on total volume being above average threshold
  @visibleForTesting
  bool get isHighVolumeWorkout {
    const highVolumeThreshold = 1000.0; // kg
    return _calculateTotalVolume() > highVolumeThreshold;
  }

  /// Gets a detailed description of the workout for accessibility
  @visibleForTesting
  String get accessibilityDescription {
    final volume = _calculateTotalVolume().toInt();
    final setCount = workout.sets.length;
    final exerciseCount = uniqueExerciseCount;
    final date = _formatDate(workout.date);
    final time = _formatRelativeTime(workout.date);

    return 'Workout from $date at $time. '
        '$setCount sets across $exerciseCount exercises. '
        'Total volume: ${volume}kg. '
        'Tap to edit, or use delete button to remove.';
  }
}

/// Extension on Workout to provide additional utility methods
extension WorkoutExtensions on Workout {
  /// Calculates the total volume (weight × repetitions) for all sets
  double get totalVolume {
    return sets.fold(
        0.0, (total, set) => total + (set.weight * set.repetitions));
  }

  /// Gets the number of unique exercises in this workout
  int get uniqueExerciseCount {
    return sets.map((set) => set.exercise).toSet().length;
  }

  /// Gets the exercise performed most frequently in this workout
  Exercise? get mostFrequentExercise {
    if (sets.isEmpty) return null;

    final exerciseCounts = <Exercise, int>{};
    for (final set in sets) {
      exerciseCounts[set.exercise] = (exerciseCounts[set.exercise] ?? 0) + 1;
    }

    return exerciseCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Gets the heaviest weight used in any set of this workout
  double get maxWeight {
    if (sets.isEmpty) return 0.0;
    return sets.map((set) => set.weight).reduce((a, b) => a > b ? a : b);
  }

  /// Gets the total number of repetitions across all sets
  int get totalReps {
    return sets.fold(0, (total, set) => total + set.repetitions);
  }

  /// Determines if this is a strength-focused workout (low reps, high weight)
  bool get isStrengthFocused {
    if (sets.isEmpty) return false;
    final avgReps = totalReps / sets.length;
    return avgReps <= 6.0;
  }

  /// Determines if this is an endurance-focused workout (high reps, lower weight)
  bool get isEnduranceFocused {
    if (sets.isEmpty) return false;
    final avgReps = totalReps / sets.length;
    return avgReps >= 15.0;
  }

  /// Gets a brief summary string of the workout
  String get summary {
    return '${sets.length} sets, ${uniqueExerciseCount} exercises, ${totalVolume.toInt()}kg total';
  }
}
