import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/workout_set.dart';

/// Widget representing a single workout set in the workout creation/editing screen
/// Displays set details including exercise, weight, reps, and total volume
/// Provides edit and delete functionality with confirmation dialogs
class SetItem extends StatefulWidget {
  /// The workout set data to display
  final WorkoutSet set;
  
  /// The sequential number of this set within the workout
  final int setNumber;
  
  /// Callback triggered when user confirms set deletion
  final VoidCallback onDelete;
  
  /// Callback triggered when user wants to edit the set
  final VoidCallback onEdit;

  const SetItem({
    super.key,
    required this.set,
    required this.setNumber,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<SetItem> createState() => _SetItemState();
}

class _SetItemState extends State<SetItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initialize entrance animation for smooth set appearance
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.elasticOut,
      ),
    );
    
    // Start entrance animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: _buildSetCard(),
    );
  }

  /// Builds the main card container for the set
  Widget _buildSetCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: _buildCardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildCardContent(),
        ),
      ),
    );
  }

  /// Builds the gradient decoration for the card
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
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

  /// Builds the main content layout of the set card
  Widget _buildCardContent() {
    return Row(
      children: [
        _buildSetNumberIndicator(),
        const SizedBox(width: 16),
        _buildSetDetails(),
        _buildActionButtons(),
      ],
    );
  }

  /// Builds the circular set number indicator with gradient background
  Widget _buildSetNumberIndicator() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${widget.setNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Builds the expandable section containing set details
  Widget _buildSetDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExerciseName(),
          const SizedBox(height: 6),
          _buildInfoChips(),
        ],
      ),
    );
  }

  /// Builds the exercise name display
  Widget _buildExerciseName() {
    return Text(
      widget.set.exercise.displayName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3436),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the row of information chips showing weight, reps, and volume
  Widget _buildInfoChips() {
    return Row(
      children: [
        Flexible(
          child: _buildInfoChip(
            '${widget.set.weight}kg',
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: _buildInfoChip(
            '${widget.set.repetitions} reps',
            Icons.repeat,
            Colors.green,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: _buildInfoChip(
            '${_calculateVolume()}kg',
            Icons.scale,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  /// Builds an individual information chip with icon and text
  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 11, 
            color: color,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the column of action buttons (edit and delete)
  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildEditButton(),
        const SizedBox(height: 4),
        _buildDeleteButton(),
      ],
    );
  }

  /// Builds the edit button with proper styling and accessibility
  Widget _buildEditButton() {
    return IconButton(
      onPressed: widget.onEdit,
      icon: Icon(
        Icons.edit,
        color: Colors.blue.shade400,
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
      ),
      tooltip: 'Edit set ${widget.setNumber}',
    );
  }

  /// Builds the delete button with confirmation dialog
  Widget _buildDeleteButton() {
    return IconButton(
      onPressed: _showDeleteDialog,
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
      tooltip: 'Delete set ${widget.setNumber}',
    );
  }

  /// Shows confirmation dialog before deleting the set
  /// Provides clear information about what will be deleted
  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: _buildDialogTitle(),
          content: _buildDialogContent(),
          actions: _buildDialogActions(),
        );
      },
    );
  }

  /// Builds the dialog title with warning icon
  Widget _buildDialogTitle() {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 28,
        ),
        const SizedBox(width: 12),
        const Text('Remove Set'),
      ],
    );
  }

  /// Builds the dialog content explaining what will be removed
  Widget _buildDialogContent() {
    return Text(
      'Remove Set ${widget.setNumber} (${widget.set.exercise.displayName})?\n\n'
      'Details: ${widget.set.weight}kg × ${widget.set.repetitions} reps\n'
      'Volume: ${_calculateVolume()}kg\n\n'
      'This action cannot be undone.',
      style: const TextStyle(height: 1.4),
    );
  }

  /// Builds the dialog action buttons
  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          debugPrint('Set deletion cancelled for set ${widget.setNumber}');
        },
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _confirmDelete,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('Remove'),
      ),
    ];
  }

  /// Handles the confirmed deletion of the set
  void _confirmDelete() {
    Navigator.of(context).pop(); // Close dialog
    
    debugPrint('Confirmed deletion of set ${widget.setNumber}: '
        '${widget.set.exercise.displayName} - '
        '${widget.set.weight}kg × ${widget.set.repetitions} reps');
    
    widget.onDelete(); // Trigger parent callback
  }

  /// Calculates the total volume (weight × reps) for this set
  /// Returns the result as an integer for cleaner display
  int _calculateVolume() {
    return (widget.set.weight * widget.set.repetitions).toInt();
  }

  /// Gets the total volume as a double for precise calculations
  @visibleForTesting
  double get preciseVolume {
    return widget.set.weight * widget.set.repetitions;
  }

  /// Checks if this set represents a personal record for the exercise
  /// This would typically compare against historical data
  @visibleForTesting
  bool get isPotentialPersonalRecord {
    // Placeholder logic - in a real app, this would check against historical data
    return widget.set.weight >= 100.0 && widget.set.repetitions >= 5;
  }

  /// Returns a formatted string with complete set information
  @visibleForTesting
  String get setDescription {
    return '${widget.set.exercise.displayName}: ${widget.set.weight}kg × ${widget.set.repetitions} reps (${_calculateVolume()}kg total)';
  }

  /// Triggers the edit animation for visual feedback
  @visibleForTesting
  void animateEdit() {
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
  }
}

/// Extension on WorkoutSet to provide additional utility methods
extension WorkoutSetExtensions on WorkoutSet {
  /// Calculates the total volume (weight × repetitions) for this set
  double get volume => weight * repetitions;
  
  /// Returns a formatted string representation of the set
  String get displayString => '$weight kg × $repetitions reps';
  
  /// Determines if this set falls within typical strength training ranges
  bool get isTypicalStrengthRange => repetitions >= 1 && repetitions <= 12;
  
  /// Determines if this set falls within typical endurance training ranges
  bool get isTypicalEnduranceRange => repetitions >= 12 && repetitions <= 25;
  
  /// Returns the intensity category based on rep range
  String get intensityCategory {
    if (repetitions <= 5) return 'Strength';
    if (repetitions <= 12) return 'Hypertrophy';
    if (repetitions <= 25) return 'Endurance';
    return 'Ultra Endurance';
  }
}