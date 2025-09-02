import 'package:flutter_test/flutter_test.dart';
import 'package:magic_bench/models/exercise.dart';

void main() {
  group('Exercise Model Tests', () {
    test('should have all required exercises', () {
      expect(Exercise.values.length, 5);
      expect(Exercise.values, contains(Exercise.barbellRow));
      expect(Exercise.values, contains(Exercise.benchPress));
      expect(Exercise.values, contains(Exercise.shoulderPress));
      expect(Exercise.values, contains(Exercise.deadlift));
      expect(Exercise.values, contains(Exercise.squat));
    });

    test('should have correct display names', () {
      expect(Exercise.barbellRow.displayName, 'Barbell row');
      expect(Exercise.benchPress.displayName, 'Bench press');
      expect(Exercise.shoulderPress.displayName, 'Shoulder press');
      expect(Exercise.deadlift.displayName, 'Deadlift');
      expect(Exercise.squat.displayName, 'Squat');
    });

    test('should convert to string correctly', () {
      expect(Exercise.barbellRow.name, 'barbellRow');
      expect(Exercise.benchPress.name, 'benchPress');
      expect(Exercise.shoulderPress.name, 'shoulderPress');
      expect(Exercise.deadlift.name, 'deadlift');
      expect(Exercise.squat.name, 'squat');
    });
  });
}