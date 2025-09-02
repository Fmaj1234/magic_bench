import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_bench/widgets/workout_item.dart';
import 'package:magic_bench/models/workout.dart';
import 'package:magic_bench/models/workout_set.dart';
import 'package:magic_bench/models/exercise.dart';

void main() {
  group('WorkoutItem Widget Tests', () {
    late Workout testWorkout;
    late Workout recentWorkout;
    bool itemTapped = false;
    bool deletePressed = false;

    setUp(() {
      testWorkout = Workout(
        id: 'test-workout',
        date: DateTime.utc(2024, 3, 15, 14, 30),
        sets: [
          WorkoutSet(
            id: 'set-1',
            exercise: Exercise.benchPress,
            weight: 50.0,
            repetitions: 10,
          ),
          WorkoutSet(
            id: 'set-2',
            exercise: Exercise.squat,
            weight: 100.0,
            repetitions: 8,
          ),
        ],
      );

      // Create a recent workout for testing relative time
      recentWorkout = Workout(
        id: 'recent-workout',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        sets: [
          WorkoutSet(
            id: 'recent-set',
            exercise: Exercise.benchPress,
            weight: 60.0,
            repetitions: 8,
          ),
        ],
      );

      itemTapped = false;
      deletePressed = false;
    });

    Widget createWorkoutItem([Workout? workout]) {
      return MaterialApp(
        home: Scaffold(
          body: WorkoutItem(
            workout: workout ?? testWorkout,
            onTap: () => itemTapped = true,
            onDelete: () => deletePressed = true,
          ),
        ),
      );
    }

    testWidgets('should display workout date and relative time',
        (tester) async {
      await tester.pumpWidget(createWorkoutItem());
      await tester.pumpAndSettle();

      expect(find.text('Fri, 15 Mar'), findsOneWidget);

      // Since the workout is from 2024, it should show a relative time
      // We'll look for any text that indicates time passed
      final timeWidgets = find.byWidgetPredicate((widget) =>
          widget is Text &&
          widget.data != null &&
          (widget.data!.contains('ago') || widget.data == 'Just now'));
      expect(timeWidgets, findsAtLeastNWidgets(1));
    });

    testWidgets('should display recent workout with proper relative time',
        (tester) async {
      await tester.pumpWidget(createWorkoutItem(recentWorkout));
      await tester.pumpAndSettle();

      // Should show "2 hours ago" for a workout from 2 hours ago
      expect(find.textContaining('hours ago'), findsOneWidget);
    });

    testWidgets('should display set count', (tester) async {
      await tester.pumpWidget(createWorkoutItem());
      await tester.pumpAndSettle();

      expect(find.text('2 sets'), findsOneWidget);
    });

    testWidgets('should calculate and display total volume', (tester) async {
      await tester.pumpWidget(createWorkoutItem());
      await tester.pumpAndSettle();

      // Total volume: (50 * 10) + (100 * 8) = 1300kg
      expect(find.text('1300kg'), findsOneWidget);
    });

    testWidgets('should display exercise summary', (tester) async {
      await tester.pumpWidget(createWorkoutItem());
      await tester.pumpAndSettle();

      // Should show exercise summary
      expect(
          find.textContaining('Bench press (1) • Squat (1)'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      await tester.pumpWidget(createWorkoutItem());
      await tester.pumpAndSettle();

      // Tap on the Card widget instead of InkWell to avoid ambiguity
      await tester.tap(find.byType(Card));
      expect(itemTapped, true);
    });

    testWidgets('should call onDelete when delete button pressed',
        (tester) async {
      await tester.pumpWidget(createWorkoutItem());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deletePressed, true);
    });

    testWidgets('should handle single set workout', (tester) async {
      final singleSetWorkout = Workout(
        id: 'single-set',
        date: DateTime.now()
            .subtract(const Duration(minutes: 30)), // 30 minutes ago
        sets: [
          WorkoutSet(
            id: 'single',
            exercise: Exercise.deadlift,
            weight: 80.0,
            repetitions: 6,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutItem(
              workout: singleSetWorkout,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 set'), findsOneWidget);
      expect(find.text('Deadlift (1)'), findsOneWidget);
      expect(find.text('480kg'), findsOneWidget); // 80 * 6
      expect(find.textContaining('minutes ago'), findsOneWidget);
    });

    testWidgets('should truncate exercise summary for many exercises',
        (tester) async {
      final manyExercisesWorkout = Workout(
        id: 'many-exercises',
        date: DateTime.now().subtract(const Duration(days: 1)), // 1 day ago
        sets: [
          WorkoutSet(
              id: '1',
              exercise: Exercise.benchPress,
              weight: 50,
              repetitions: 10),
          WorkoutSet(
              id: '2', exercise: Exercise.squat, weight: 100, repetitions: 8),
          WorkoutSet(
              id: '3',
              exercise: Exercise.deadlift,
              weight: 120,
              repetitions: 5),
          WorkoutSet(
              id: '4',
              exercise: Exercise.barbellRow,
              weight: 70,
              repetitions: 8),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutItem(
              workout: manyExercisesWorkout,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('4 sets'), findsOneWidget);
      expect(find.textContaining('+2 more'), findsOneWidget);
      expect(find.textContaining('day ago'), findsOneWidget);
    });

    testWidgets('should have hero widget', (tester) async {
      await tester.pumpWidget(createWorkoutItem());
      await tester.pumpAndSettle();

      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('should show just now for very recent workouts',
        (tester) async {
      final justNowWorkout = Workout(
        id: 'just-now-workout',
        date: DateTime.now().subtract(const Duration(seconds: 30)),
        sets: [
          WorkoutSet(
            id: 'just-now-set',
            exercise: Exercise.benchPress,
            weight: 50.0,
            repetitions: 10,
          ),
        ],
      );

      await tester.pumpWidget(createWorkoutItem(justNowWorkout));
      await tester.pumpAndSettle();

      expect(find.text('Just now'), findsOneWidget);
    });

    testWidgets('should handle different time formats correctly',
        (tester) async {
      // Test various time scenarios
      final scenarios = [
        (DateTime.now().subtract(const Duration(minutes: 5)), 'minutes ago'),
        (DateTime.now().subtract(const Duration(hours: 1)), 'hour ago'),
        (DateTime.now().subtract(const Duration(days: 3)), 'days ago'),
        (DateTime.now().subtract(const Duration(days: 14)), 'weeks ago'),
      ];

      for (final (date, expectedText) in scenarios) {
        final workout = Workout(
          id: 'test-${date.millisecondsSinceEpoch}',
          date: date,
          sets: [
            WorkoutSet(
              id: 'set',
              exercise: Exercise.benchPress,
              weight: 50.0,
              repetitions: 10,
            ),
          ],
        );

        await tester.pumpWidget(createWorkoutItem(workout));
        await tester.pumpAndSettle();

        expect(find.textContaining(expectedText), findsOneWidget);
      }
    });
  });
}
