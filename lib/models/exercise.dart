enum Exercise {
  barbellRow('Barbell row'),
  benchPress('Bench press'),
  shoulderPress('Shoulder press'),
  deadlift('Deadlift'),
  squat('Squat');

  const Exercise(this.displayName);
  final String displayName;
}