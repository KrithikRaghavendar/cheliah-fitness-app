/// Data model for individual exercises and the full workout routine.

enum ExerciseCategory {
  warmUp,
  cardio,
  strength,
  core,
  stretching,
}

enum TargetMuscle {
  shoulders,
  core,
  legs,
  fullBody,
  chest,
  hamstrings,
}

class Exercise {
  final String name;
  final String instruction;
  final ExerciseCategory category;
  final TargetMuscle targetMuscle;
  /// Duration in seconds for timed exercises; null for rep-based.
  final int? durationSeconds;
  /// Number of reps for rep-based exercises; null for timed.
  final int? reps;

  const Exercise({
    required this.name,
    required this.instruction,
    required this.category,
    required this.targetMuscle,
    this.durationSeconds,
    this.reps,
  });

  bool get isTimed => durationSeconds != null;
}

extension ExerciseCategoryLabel on ExerciseCategory {
  String get label {
    switch (this) {
      case ExerciseCategory.warmUp:
        return 'Warm-Up';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.strength:
        return 'Strength';
      case ExerciseCategory.core:
        return 'Core';
      case ExerciseCategory.stretching:
        return 'Stretching';
    }
  }
}

extension TargetMuscleInfo on TargetMuscle {
  String get label {
    switch (this) {
      case TargetMuscle.shoulders:
        return 'Shoulders';
      case TargetMuscle.core:
        return 'Core';
      case TargetMuscle.legs:
        return 'Legs';
      case TargetMuscle.fullBody:
        return 'Full Body';
      case TargetMuscle.chest:
        return 'Chest';
      case TargetMuscle.hamstrings:
        return 'Hamstrings';
    }
  }

  String get imagePath {
    switch (this) {
      case TargetMuscle.shoulders:
        return 'assets/images/muscles/muscle_shoulders.png';
      case TargetMuscle.core:
        return 'assets/images/muscles/muscle_core.png';
      case TargetMuscle.legs:
        return 'assets/images/muscles/muscle_legs.png';
      case TargetMuscle.fullBody:
        return 'assets/images/muscles/muscle_full_body.png';
      case TargetMuscle.chest:
        return 'assets/images/muscles/muscle_chest.png';
      case TargetMuscle.hamstrings:
        return 'assets/images/muscles/muscle_hamstrings.png';
    }
  }
}

class WorkoutRoutine {
  static const List<Exercise> defaultExercises = [
    // ── Warm-Up ──
    Exercise(
      name: 'Hands Up',
      instruction:
          'Stand tall with feet shoulder-width apart. Reach both arms overhead as high as possible, stretching through your fingertips. Hold briefly, then lower and repeat.',
      category: ExerciseCategory.warmUp,
      targetMuscle: TargetMuscle.shoulders,
      durationSeconds: 45,
    ),
    Exercise(
      name: 'Arm Circles',
      instruction:
          'Extend arms straight out to the sides. Make small circles, gradually increasing to large circles. Go forward for 30 seconds, then reverse direction for 30 seconds.',
      category: ExerciseCategory.warmUp,
      targetMuscle: TargetMuscle.shoulders,
      durationSeconds: 60,
    ),
    Exercise(
      name: 'Hip Circles',
      instruction:
          'Place hands on your hips, feet shoulder-width apart. Rotate your hips in large circles — 30 seconds clockwise, then 30 seconds counter-clockwise.',
      category: ExerciseCategory.warmUp,
      targetMuscle: TargetMuscle.core,
      durationSeconds: 60,
    ),
    Exercise(
      name: 'Ankle Circles',
      instruction:
          'Lift one foot off the ground and rotate the ankle in circles — 30 seconds each direction per foot. Use a wall for balance if needed.',
      category: ExerciseCategory.warmUp,
      targetMuscle: TargetMuscle.legs,
      durationSeconds: 120,
    ),
    Exercise(
      name: 'March in Place',
      instruction:
          'Stand tall and march on the spot, lifting knees to hip height. Swing opposite arms naturally. Keep your core engaged throughout.',
      category: ExerciseCategory.warmUp,
      targetMuscle: TargetMuscle.legs,
      durationSeconds: 45,
    ),
    Exercise(
      name: 'Half Squats',
      instruction:
          'Stand with feet shoulder-width apart. Lower your hips halfway down as if sitting in a chair, keeping knees behind toes. Rise back up and repeat.',
      category: ExerciseCategory.warmUp,
      targetMuscle: TargetMuscle.legs,
      reps: 15,
    ),

    // ── Cardio ──
    Exercise(
      name: 'Jumping Jacks',
      instruction:
          'Start standing with arms at your sides. Jump feet apart while raising arms overhead. Jump back to start. Maintain a steady rhythm.',
      category: ExerciseCategory.cardio,
      targetMuscle: TargetMuscle.fullBody,
      durationSeconds: 30,
    ),
    Exercise(
      name: 'High Knees',
      instruction:
          'Run in place, driving knees as high as possible toward your chest. Pump your arms and keep your core tight. Go as fast as you can.',
      category: ExerciseCategory.cardio,
      targetMuscle: TargetMuscle.legs,
      durationSeconds: 30,
    ),
    Exercise(
      name: 'Butt Kicks',
      instruction:
          'Run in place, kicking your heels up toward your glutes with each step. Keep your upper body upright and arms pumping.',
      category: ExerciseCategory.cardio,
      targetMuscle: TargetMuscle.hamstrings,
      durationSeconds: 30,
    ),

    // ── Strength ──
    Exercise(
      name: 'Push-ups',
      instruction:
          'Start in a high plank position, hands slightly wider than shoulders. Lower your chest to the ground, then push back up. Keep your body in a straight line.',
      category: ExerciseCategory.strength,
      targetMuscle: TargetMuscle.chest,
      reps: 15,
    ),
    Exercise(
      name: 'Bodyweight Squats',
      instruction:
          'Stand with feet shoulder-width apart. Lower your hips until thighs are parallel to the floor, keeping chest up and weight in your heels. Drive back up.',
      category: ExerciseCategory.strength,
      targetMuscle: TargetMuscle.legs,
      reps: 15,
    ),
    Exercise(
      name: 'Lunges',
      instruction:
          'Step one foot forward and lower your body until both knees form 90-degree angles. Push back to standing and switch legs. 10 reps each leg.',
      category: ExerciseCategory.strength,
      targetMuscle: TargetMuscle.legs,
      reps: 20,
    ),

    // ── Core ──
    Exercise(
      name: 'Plank',
      instruction:
          'Hold a forearm plank position — elbows under shoulders, body in a straight line from head to heels. Engage your core and breathe steadily.',
      category: ExerciseCategory.core,
      targetMuscle: TargetMuscle.core,
      durationSeconds: 45,
    ),
    Exercise(
      name: 'Bicycle Crunches',
      instruction:
          'Lie on your back, hands behind your head. Bring one knee toward the opposite elbow while extending the other leg. Alternate sides in a pedaling motion.',
      category: ExerciseCategory.core,
      targetMuscle: TargetMuscle.core,
      reps: 20,
    ),

    // ── Stretching ──
    Exercise(
      name: 'Hamstring Stretch',
      instruction:
          'Sit on the floor with one leg extended. Reach toward your toes, keeping your back straight. Hold for 30 seconds, then switch legs.',
      category: ExerciseCategory.stretching,
      targetMuscle: TargetMuscle.hamstrings,
      durationSeconds: 30,
    ),
    Exercise(
      name: 'Quad Stretch',
      instruction:
          'Stand on one leg and pull the other foot toward your glutes. Keep knees together and hips pushed forward. Hold 30 seconds each leg.',
      category: ExerciseCategory.stretching,
      targetMuscle: TargetMuscle.legs,
      durationSeconds: 60,
    ),
    Exercise(
      name: 'Shoulder Stretch',
      instruction:
          'Bring one arm across your body at shoulder height. Use the opposite hand to gently press the arm closer to your chest. Hold 30 seconds each side.',
      category: ExerciseCategory.stretching,
      targetMuscle: TargetMuscle.shoulders,
      durationSeconds: 30,
    ),
  ];
}
