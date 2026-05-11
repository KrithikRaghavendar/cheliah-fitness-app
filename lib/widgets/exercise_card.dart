import 'package:cheliah_fitness_app/data/workout_data.dart';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:cheliah_fitness_app/widgets/circular_timer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Glassmorphic exercise card displaying name, category, target muscle image,
/// instruction, and either a circular timer or rep counter.
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int remainingTime;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    this.remainingTime = 0,
  }) : super(key: key);

  Color _categoryColor() {
    switch (exercise.category) {
      case ExerciseCategory.warmUp:
        return const Color(0xFFFF9500);
      case ExerciseCategory.cardio:
        return const Color(0xFFFF2D55);
      case ExerciseCategory.strength:
        return const Color(0xFF5AC8FA);
      case ExerciseCategory.core:
        return const Color(0xFFFFCC00);
      case ExerciseCategory.stretching:
        return const Color(0xFF4CD964);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0x591E1E23),
        border: Border.all(
          color: const Color(0x19FFFFFF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category badge + muscle target row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: catColor.withOpacity(0.3)),
                ),
                child: Text(
                  exercise.category.label,
                  style: GoogleFonts.inter(
                    color: catColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Target muscle badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentStart.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppTheme.accentStart.withOpacity(0.25)),
                ),
                child: Text(
                  exercise.targetMuscle.label,
                  style: GoogleFonts.inter(
                    color: AppTheme.accentStart,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Muscle group image
          _buildMuscleImage(),
          const SizedBox(height: 20),

          // Exercise name
          Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Instruction text
          Text(
            exercise.instruction,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),

          // Timer or Rep display
          if (exercise.isTimed)
            CircularTimer(
              totalSeconds: exercise.durationSeconds!,
              remainingSeconds: remainingTime,
            )
          else
            _buildRepCounter(),
        ],
      ),
    );
  }

  Widget _buildMuscleImage() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F),
        border: Border.all(
          color: const Color(0x22FFFFFF),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentStart.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          exercise.targetMuscle.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon if image fails to load
            return Icon(
              Icons.fitness_center,
              color: AppTheme.accentStart.withOpacity(0.5),
              size: 32,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRepCounter() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x0FFFFFFF),
        border: Border.all(
          color: AppTheme.accentStart.withOpacity(0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentStart.withOpacity(0.15),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${exercise.reps}',
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 42,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'repetitions',
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
