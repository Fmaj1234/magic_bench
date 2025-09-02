import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_bench/widgets/set_item.dart';
import 'package:magic_bench/models/workout_set.dart';
import 'package:magic_bench/models/exercise.dart';

void main() {
  group('SetItem Widget Tests', () {
    late WorkoutSet testSet;
    bool editPressed = false;
    bool deletePressed = false;

    setUp(() {
      testSet = WorkoutSet(
        id: 'test-set',
        exercise: Exercise.benchPress,
        weight: 50.0,
        repetitions: 10,
      );
      editPressed = false;
      deletePressed = false;
    });

    Widget createSetItem() {
      return MaterialApp(
        home: Scaffold(
          body: SetItem(
            set: testSet,
            setNumber: 1,
            onEdit: () => editPressed = true,
            onDelete: () => deletePressed = true,
          ),
        ),
      );
    }

    testWidgets('should display set information correctly', (tester) async {
      await tester.pumpWidget(createSetItem());
      await tester.pumpAndSettle();

      expect(find.text('Bench press'), findsOneWidget);
      expect(find.text('50.0kg'), findsOneWidget);
      expect(find.text('10 reps'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Set number
    });

    testWidgets('should show edit and delete buttons', (tester) async {
      await tester.pumpWidget(createSetItem());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should call onEdit when edit button pressed', (tester) async {
      await tester.pumpWidget(createSetItem());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      expect(editPressed, true);
    });

    testWidgets('should show delete confirmation dialog', (tester) async {
      await tester.pumpWidget(createSetItem());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Remove Set'), findsOneWidget);
      expect(find.textContaining('Remove Set 1'), findsOneWidget);
    });

    testWidgets('should call onDelete when confirmed', (tester) async {
      await tester.pumpWidget(createSetItem());
      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(deletePressed, true);
    });

    testWidgets('should not call onDelete when cancelled', (tester) async {
      await tester.pumpWidget(createSetItem());
      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Cancel deletion
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(deletePressed, false);
    });

    testWidgets('should display total volume correctly', (tester) async {
      await tester.pumpWidget(createSetItem());
      await tester.pumpAndSettle();

      // Total volume: 50kg * 10 reps = 500kg
      expect(find.text('500kg'), findsOneWidget);
    });

    testWidgets('should handle different exercise types', (tester) async {
      final squatSet = WorkoutSet(
        id: 'squat-set',
        exercise: Exercise.squat,
        weight: 100.0,
        repetitions: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetItem(
              set: squatSet,
              setNumber: 2,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('100.0kg'), findsOneWidget);
      expect(find.text('5 reps'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('500kg'), findsOneWidget); // 100 * 5 = 500kg
    });

    testWidgets('should have proper widget structure', (tester) async {
      await tester.pumpWidget(createSetItem());
      await tester.pumpAndSettle();
      
      // Should have main structural elements
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });
  });
}