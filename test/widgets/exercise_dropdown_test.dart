import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_bench/widgets/exercise_dropdown.dart';
import 'package:magic_bench/models/exercise.dart';

void main() {
  group('ExerciseDropdown Widget Tests', () {
    testWidgets('should display exercise label', (tester) async {
      Exercise selectedExercise = Exercise.benchPress;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseDropdown(
              value: selectedExercise,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Should display the label
      expect(find.text('Exercise'), findsOneWidget);
      // Should have a dropdown
      expect(find.byType(DropdownButtonFormField<Exercise>), findsOneWidget);
    });

    testWidgets('should show all exercises when opened', (tester) async {
      Exercise selectedExercise = Exercise.benchPress;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseDropdown(
              value: selectedExercise,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Tap to open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<Exercise>));
      await tester.pumpAndSettle();

      // Should show all exercise options
      expect(find.text('Barbell row'), findsOneWidget);
      expect(find.text('Bench press'), findsAtLeastNWidgets(1));
      expect(find.text('Shoulder press'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
    });

    testWidgets('should call onChanged when selection changes', (tester) async {
      Exercise selectedExercise = Exercise.benchPress;
      Exercise? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseDropdown(
              value: selectedExercise,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<Exercise>));
      await tester.pumpAndSettle();

      // Select a different exercise
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      expect(changedValue, Exercise.squat);
    });

    testWidgets('should have container decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseDropdown(
              value: Exercise.benchPress,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Should have a Container with decoration
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<Exercise>), findsOneWidget);
    });
  });
}