import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../providers/workout_provider.dart';
import '../widgets/set_item.dart';
import '../widgets/exercise_dropdown.dart';

/// Screen for creating new workouts or editing existing ones
/// Allows users to add multiple sets with different exercises, weights, and repetitions
/// Supports both creation mode (workoutId = null) and edit mode (workoutId provided)
class WorkoutScreen extends StatefulWidget {
  /// Optional workout ID for editing existing workouts
  /// If null, creates a new workout
  final String? workoutId;

  const WorkoutScreen({super.key, this.workoutId});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin {
  // Form management
  final _formKey = GlobalKey<FormState>();
  final List<WorkoutSet> _sets = [];
  final _uuid = const Uuid();

  // Input controllers for set creation form
  Exercise _selectedExercise = Exercise.benchPress;
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  // Animation controllers for smooth UI transitions
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> fabScaleAnimation;

  // State management
  bool _isLoading = false;
  bool get _isEditing => widget.workoutId != null;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadWorkoutDataIfEditing();
  }

  /// Initialize animation controllers and animations for smooth UI transitions
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    // Start entrance animation
    _animationController.forward();
  }

  /// Load existing workout data if in edit mode
  void _loadWorkoutDataIfEditing() {
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingWorkout();
      });
    }
  }

  /// Loads an existing workout's data for editing
  /// Populates the sets list with the workout's existing sets
  void _loadExistingWorkout() {
    try {
      final provider = context.read<WorkoutProvider>();
      final workout = provider.getWorkoutById(widget.workoutId!);

      if (workout != null) {
        setState(() {
          _sets.clear(); // Clear any existing data
          _sets.addAll(workout.sets);
        });

        // Show save button if sets exist
        if (_sets.isNotEmpty) {
          _fabAnimationController.forward();
        }

        debugPrint(
            'Loaded ${_sets.length} sets for workout ${widget.workoutId}');
      } else {
        debugPrint('Warning: Workout ${widget.workoutId} not found');
        _showErrorMessage('Workout not found');
      }
    } catch (e) {
      debugPrint('Error loading workout: $e');
      _showErrorMessage('Error loading workout data');
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildAddSetForm(),
          _buildSetsList(),
        ],
      ),
    );
  }

  /// Builds the app bar with dynamic title and save button
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _isEditing ? 'Edit Workout' : 'New Workout',
          style: const TextStyle(
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
                Color(0xFF74B9FF),
                Color(0xFF0984E3),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ),
      actions: [_buildSaveButton()],
    );
  }

  /// Builds the animated save button that appears when sets are added
  Widget _buildSaveButton() {
    if (_sets.isEmpty) return const SizedBox.shrink();

    return AnimatedScale(
      scale: _sets.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: TextButton.icon(
          onPressed: _isLoading ? null : _saveWorkout,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save, color: Colors.white),
          label: Text(
            _isLoading ? 'Saving...' : 'Save',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Builds the form for adding new sets
  Widget _buildAddSetForm() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildFormContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main form content for adding sets
  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormHeader(),
          const SizedBox(height: 20),
          _buildExerciseSelector(),
          const SizedBox(height: 16),
          _buildWeightAndRepsInputs(),
          const SizedBox(height: 20),
          _buildAddSetButton(),
        ],
      ),
    );
  }

  /// Builds the header section of the form
  Widget _buildFormHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Add New Set',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  /// Builds the exercise selection dropdown
  Widget _buildExerciseSelector() {
    return ExerciseDropdown(
      value: _selectedExercise,
      onChanged: (Exercise? value) {
        if (value != null) {
          setState(() {
            _selectedExercise = value;
          });
          debugPrint('Exercise changed to: ${value.displayName}');
        }
      },
    );
  }

  /// Builds the weight and repetitions input fields
  Widget _buildWeightAndRepsInputs() {
    return Row(
      children: [
        Flexible(
          child: _buildInputField(
            controller: _weightController,
            label: 'Weight',
            suffix: 'kg',
            icon: Icons.fitness_center,
            validator: _validateWeight,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: _buildInputField(
            controller: _repsController,
            label: 'Reps',
            suffix: 'reps',
            icon: Icons.repeat,
            validator: _validateReps,
          ),
        ),
      ],
    );
  }

  /// Builds the add set button
  Widget _buildAddSetButton() {
    return ElevatedButton.icon(
      onPressed: _addSet,
      icon: const Icon(Icons.add),
      label: const Text('Add Set'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Builds a reusable input field with validation
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      validator: validator,
      textInputAction:
          label == 'Weight' ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (label == 'Reps' && _formKey.currentState!.validate()) {
          _addSet();
        }
      },
    );
  }

  /// Builds the list of added sets or empty state
  Widget _buildSetsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: _sets.isEmpty
          ? const SliverFillRemaining(
              child: EmptyWorkoutSetsWidget(),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Ensure index is within bounds
                  if (index >= _sets.length) {
                    debugPrint(
                        'Warning: Index $index out of bounds for sets list');
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SetItem(
                      set: _sets[index],
                      setNumber: index + 1,
                      onDelete: () => _removeSet(index),
                      onEdit: () => _editSet(index),
                    ),
                  );
                },
                childCount: _sets.length,
              ),
            ),
    );
  }

  /// Validates weight input
  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter weight';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Invalid number format';
    }

    if (weight <= 0) {
      return 'Weight must be positive';
    }

    if (weight > 1000) {
      return 'Weight seems unrealistic';
    }

    return null;
  }

  /// Validates repetitions input
  String? _validateReps(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter reps';
    }

    final reps = int.tryParse(value);
    if (reps == null) {
      return 'Invalid number format';
    }

    if (reps <= 0) {
      return 'Reps must be positive';
    }

    if (reps > 100) {
      return 'Reps seem excessive';
    }

    return null;
  }

  /// Adds a new set to the workout
  /// Validates input and provides user feedback
  void _addSet() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final weight = double.parse(_weightController.text);
      final reps = int.parse(_repsController.text);

      final set = WorkoutSet(
        id: _uuid.v4(),
        exercise: _selectedExercise,
        weight: weight,
        repetitions: reps,
      );

      setState(() {
        _sets.add(set);
        _weightController.clear();
        _repsController.clear();
      });

      // Show save button animation on first set
      if (_sets.length == 1) {
        _fabAnimationController.forward();
      }

      // Provide success feedback
      _showSuccessMessage('Set ${_sets.length} added!');

      debugPrint(
          'Added set: ${_selectedExercise.displayName} - ${weight}kg x $reps');
    } catch (e) {
      debugPrint('Error adding set: $e');
      _showErrorMessage('Error adding set');
    }
  }

  /// Removes a set at the specified index
  /// Provides confirmation and user feedback
  void _removeSet(int index) {
    if (index < 0 || index >= _sets.length) {
      debugPrint('Error: Invalid set index $index');
      return;
    }

    final removedSet = _sets[index];

    setState(() {
      _sets.removeAt(index);
    });

    // Hide save button if no sets remain
    if (_sets.isEmpty) {
      _fabAnimationController.reverse();
    }

    _showWarningMessage('Set ${index + 1} removed');
    debugPrint(
        'Removed set: ${removedSet.exercise.displayName} - ${removedSet.weight}kg x ${removedSet.repetitions}');
  }

  /// Opens the edit dialog for a specific set
  void _editSet(int index) {
    if (index < 0 || index >= _sets.length) {
      debugPrint('Error: Invalid set index $index');
      return;
    }

    final currentSet = _sets[index];

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return EditSetDialog(
          set: currentSet,
          setNumber: index + 1,
          onSave: (updatedSet) => _updateSet(index, updatedSet),
        );
      },
    );
  }

  /// Updates a set with new values
  void _updateSet(int index, WorkoutSet updatedSet) {
    if (index < 0 || index >= _sets.length) {
      debugPrint('Error: Invalid set index $index');
      return;
    }

    setState(() {
      _sets[index] = updatedSet;
    });

    Navigator.of(context).pop(); // Close dialog
    _showSuccessMessage('Set ${index + 1} updated!');

    debugPrint(
        'Updated set ${index + 1}: ${updatedSet.exercise.displayName} - ${updatedSet.weight}kg x ${updatedSet.repetitions}');
  }

  /// Saves the workout (creates new or updates existing)
  /// Handles validation, loading states, and error handling
  Future<void> _saveWorkout() async {
    // Validate that workout has at least one set
    if (_sets.isEmpty) {
      _showWarningMessage('Please add at least one set');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final workout = Workout(
        id: widget.workoutId ?? _uuid.v4(),
        date: _isEditing
            ? context
                    .read<WorkoutProvider>()
                    .getWorkoutById(widget.workoutId!)
                    ?.date ??
                DateTime.now()
            : DateTime.now(),
        sets: List.from(_sets),
      );

      await context.read<WorkoutProvider>().saveWorkout(workout);

      if (mounted) {
        Navigator.of(context).pop();

        // Show success message in parent screen
        final message = _isEditing ? 'Workout updated!' : 'Workout saved!';
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
          ),
        );

        debugPrint(
            'Successfully ${_isEditing ? 'updated' : 'saved'} workout with ${_sets.length} sets');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showErrorMessage('Error saving workout');
        debugPrint('Error saving workout: $e');
      }
    }
  }

  /// Shows a success message using SnackBar
  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Shows a warning message using SnackBar
  void _showWarningMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an error message using SnackBar
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Gets the total volume of the current workout for testing
  @visibleForTesting
  double get totalWorkoutVolume {
    return _sets.fold(
        0.0, (total, set) => total + (set.weight * set.repetitions));
  }

  /// Gets the current number of sets for testing
  @visibleForTesting
  int get currentSetCount => _sets.length;
}

/// Widget displayed when no sets have been added to the workout
/// Provides clear guidance on how to add the first set
class EmptyWorkoutSetsWidget extends StatelessWidget {
  const EmptyWorkoutSetsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconContainer(),
          const SizedBox(height: 16),
          _buildHeadlineText(context),
          const SizedBox(height: 8),
          _buildDescriptionText(context),
        ],
      ),
    );
  }

  /// Builds the decorative icon container
  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.playlist_add,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }

  /// Builds the headline text
  Widget _buildHeadlineText(BuildContext context) {
    return Text(
      'No sets yet',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
    );
  }

  /// Builds the descriptive text
  Widget _buildDescriptionText(BuildContext context) {
    return Text(
      'Add your first set using\nthe form above',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey.shade500,
        height: 1.5,
      ),
    );
  }
}

/// Dialog for editing an existing workout set
/// Allows modification of exercise, weight, and repetitions
class EditSetDialog extends StatefulWidget {
  final WorkoutSet set;
  final int setNumber;
  final Function(WorkoutSet) onSave;

  const EditSetDialog({
    super.key,
    required this.set,
    required this.setNumber,
    required this.onSave,
  });

  @override
  State<EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<EditSetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late Exercise _selectedExercise;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Initialize form controllers with current set values
  void _initializeControllers() {
    _weightController =
        TextEditingController(text: widget.set.weight.toString());
    _repsController =
        TextEditingController(text: widget.set.repetitions.toString());
    _selectedExercise = widget.set.exercise;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: _buildDialogTitle(),
      content: _buildDialogContent(),
      actions: _buildDialogActions(),
    );
  }

  /// Builds the dialog title with set number indicator
  Widget _buildDialogTitle() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${widget.setNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('Edit Set ${widget.setNumber}'),
      ],
    );
  }

  /// Builds the dialog form content
  Widget _buildDialogContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExerciseDropdown(
            value: _selectedExercise,
            onChanged: (Exercise? value) {
              setState(() {
                _selectedExercise = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildInputRow(),
        ],
      ),
    );
  }

  /// Builds the weight and reps input row
  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Weight',
              suffixText: 'kg',
              prefixIcon: Icon(Icons.fitness_center),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _validateWeight,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _repsController,
            decoration: const InputDecoration(
              labelText: 'Reps',
              suffixText: 'reps',
              prefixIcon: Icon(Icons.repeat),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _validateReps,
          ),
        ),
      ],
    );
  }

  /// Builds the dialog action buttons
  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _saveSet,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        child: const Text('Save Changes'),
      ),
    ];
  }

  /// Validates weight input
  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter weight';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Invalid number';
    }

    if (weight <= 0) {
      return 'Must be positive';
    }

    if (weight > 1000) {
      return 'Seems unrealistic';
    }

    return null;
  }

  /// Validates repetitions input
  String? _validateReps(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter reps';
    }

    final reps = int.tryParse(value);
    if (reps == null) {
      return 'Invalid number';
    }

    if (reps <= 0) {
      return 'Must be positive';
    }

    if (reps > 100) {
      return 'Seems excessive';
    }

    return null;
  }

  /// Saves the edited set if validation passes
  void _saveSet() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final updatedSet = WorkoutSet(
        id: widget.set.id, // Preserve original ID
        exercise: _selectedExercise,
        weight: double.parse(_weightController.text),
        repetitions: int.parse(_repsController.text),
      );

      widget.onSave(updatedSet);
      debugPrint('Set ${widget.setNumber} updated successfully');
    } catch (e) {
      debugPrint('Error saving set: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving changes'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
