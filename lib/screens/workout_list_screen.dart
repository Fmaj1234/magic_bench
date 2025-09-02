import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:magic_bench/models/workout.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_item.dart';
import 'workout_screen.dart';

/// Main screen that displays a list of all user workouts
/// Follows the requirements by showing complete workouts (not individual sets)
/// Each workout can be tapped to edit or deleted via confirmation dialog
class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadWorkoutsAfterBuild();
  }

  /// Initialize animation controllers and animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// Load workouts after the widget is built to avoid calling setState during build
  void _loadWorkoutsAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WorkoutProvider>().loadWorkouts();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildWorkoutsList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds the expandable app bar with gradient background and workout count
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'My Workouts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6C5CE7),
                Color(0xFFA29BFE),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              _buildBackgroundIcon(),
              _buildWorkoutCounter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the decorative background fitness icon
  Widget _buildBackgroundIcon() {
    return const Positioned(
      top: 50,
      right: -20,
      child: Opacity(
        opacity: 0.1,
        child: Icon(
          Icons.fitness_center,
          size: 120,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds the workout counter display in the app bar
  Widget _buildWorkoutCounter() {
    return Positioned(
      bottom: 60,
      left: 20,
      child: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${provider.workouts.length}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Total Workouts',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the main content area showing workouts list or empty state
  Widget _buildWorkoutsList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while data is being fetched
          if (provider.isLoading) {
            return const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Show empty state when no workouts exist
          if (provider.workouts.isEmpty) {
            return SliverFillRemaining(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Center(
                  child: EmptyWorkoutsWidget(),
                ),
              ),
            );
          }

          // Show animated list of workouts
          return _buildAnimatedWorkoutsList(provider.workouts);
        },
      ),
    );
  }

  /// Builds the animated list of workout items
  Widget _buildAnimatedWorkoutsList(List<Workout> workouts) {
    return SliverAnimatedList(
      initialItemCount: workouts.length,
      itemBuilder: (context, index, animation) {
        // Ensure index is within bounds
        if (index >= workouts.length) {
          debugPrint('Warning: Index $index out of bounds for workouts list');
          return const SizedBox.shrink();
        }

        final workout = workouts[index];
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1, 0), end: Offset.zero),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: WorkoutItem(
              workout: workout,
              onTap: () => _navigateToWorkoutScreen(context, workout.id),
              onDelete: () => _showDeleteDialog(context, workout),
            ),
          ),
        );
      },
    );
  }

  /// Builds the floating action button for creating new workouts
  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fadeAnimation,
      child: FloatingActionButton(
        onPressed: () => _navigateToWorkoutScreen(context, null),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        tooltip: 'Add new workout',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  /// Navigates to the workout screen for creating or editing a workout
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [workoutId]: ID of workout to edit, or null for creating new workout
  void _navigateToWorkoutScreen(BuildContext context, String? workoutId) {
    debugPrint('Navigating to workout screen with ID: $workoutId');

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WorkoutScreen(workoutId: workoutId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1, 0), end: Offset.zero),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  /// Shows confirmation dialog before deleting a workout
  /// Displays workout details and warns about permanent deletion
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [workout]: The workout to be deleted
  void _showDeleteDialog(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Delete Workout'),
            ],
          ),
          content: _buildDeleteDialogContent(workout),
          actions: _buildDeleteDialogActions(context, workout),
        );
      },
    );
  }

  /// Builds the content for the delete confirmation dialog
  Widget _buildDeleteDialogContent(Workout workout) {
    return Text(
      'Are you sure you want to delete the workout from '
      '${_formatRelativeTime(workout.date)}?\n\n'
      'This workout contains ${workout.sets.length} '
      '${workout.sets.length == 1 ? 'set' : 'sets'} '
      'and will be permanently deleted.\n\n'
      'This action cannot be undone.',
      style: const TextStyle(height: 1.4),
    );
  }

  /// Builds the action buttons for the delete confirmation dialog
  List<Widget> _buildDeleteDialogActions(
      BuildContext context, Workout workout) {
    return [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          debugPrint('Delete workout cancelled');
        },
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => _confirmDeleteWorkout(context, workout),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
        ),
        child: const Text('Delete'),
      ),
    ];
  }

  /// Handles the actual workout deletion after user confirmation
  void _confirmDeleteWorkout(BuildContext context, Workout workout) async {
    Navigator.of(context).pop(); // Close dialog immediately

    try {
      await context.read<WorkoutProvider>().deleteWorkout(workout.id);

      if (mounted) {
        _showSuccessSnackBar(context, 'Workout deleted');
        debugPrint('Successfully deleted workout: ${workout.id}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Error deleting workout');
        debugPrint('Error deleting workout: $e');
      }
    }
  }

  /// Shows a success message using SnackBar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an error message using SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Formats a DateTime to relative time string (e.g., "2 hours ago")
  /// Provides human-readable time differences for better UX
  ///
  /// Parameters:
  /// - [date]: The date to format
  ///
  /// Returns:
  /// - [String]: Formatted relative time string
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

  /// Refreshes the workout list by reloading from repository
  /// Useful for pull-to-refresh functionality if added later
  @visibleForTesting
  Future<void> refreshWorkouts() async {
    if (mounted) {
      await context.read<WorkoutProvider>().loadWorkouts();
    }
  }

  /// Gets the current workout count for testing purposes
  @visibleForTesting
  int get workoutCount {
    return context.read<WorkoutProvider>().workouts.length;
  }
}

/// Widget displayed when no workouts exist
/// Provides clear call-to-action to create the first workout
class EmptyWorkoutsWidget extends StatelessWidget {
  const EmptyWorkoutsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconContainer(context),
        const SizedBox(height: 24),
        _buildHeadlineText(context),
        const SizedBox(height: 8),
        _buildDescriptionText(context),
        const SizedBox(height: 32),
        _buildCallToActionChip(context),
      ],
    );
  }

  /// Builds the decorative icon container
  Widget _buildIconContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.fitness_center_rounded,
        size: 64,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Builds the main headline text
  Widget _buildHeadlineText(BuildContext context) {
    return Text(
      'No workouts yet',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3436),
          ),
    );
  }

  /// Builds the descriptive text explaining next steps
  Widget _buildDescriptionText(BuildContext context) {
    return Text(
      'Start your fitness journey by\nadding your first workout',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            height: 1.5,
          ),
    );
  }

  /// Builds the call-to-action chip with instructions
  Widget _buildCallToActionChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Tap the + button to begin',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
