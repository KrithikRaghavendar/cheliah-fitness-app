import 'dart:math';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated circular countdown timer with gradient arc, glow, and smooth
/// digit transitions.
class CircularTimer extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final VoidCallback? onComplete;

  const CircularTimer({
    Key? key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double targetProgress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetProgress),
      duration: const Duration(milliseconds: 1000), // Animate over 1s for smooth movement
      curve: Curves.linear,
      builder: (context, progress, child) {
        // The `progress` value from TweenAnimationBuilder is 0.0 to 1.0,
        // where 1.0 means full (start of countdown) and 0.0 means empty (end).
        // This matches the `_TimerRingPainter`'s expectation.

        return SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow — pulses gently with progress
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentStart.withOpacity(
                        0.20 + 0.10 * (sin(progress * pi * 4).abs()),
                      ),
                      blurRadius: 45,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
              // Ring painter
              CustomPaint(
                size: const Size(170, 170),
                painter: _TimerRingPainter(
                  progress: progress,
                ),
              ),
              // Time display with smooth digit transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey<int>(remainingSeconds),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$remainingSeconds',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 44,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remainingSeconds == 1 ? 'second' : 'seconds',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress; // 1.0 = full, 0.0 = empty

  _TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 7.0;

    // Track (dim background ring)
    final trackPaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);

      final gradient = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        colors: const [
          AppTheme.accentStart,
          AppTheme.accentMid,
          Color(0xFFFF8296), // lighter pink
          AppTheme.accentEnd,
          AppTheme.accentStart,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        transform: const GradientRotation(-pi / 2),
      );

      // Glow arc (wider, blurred)
      final glowPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, glowPaint);

      // Solid arc on top
      final arcPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, arcPaint);

      // Glowing tip dot
      final tipAngle = -pi / 2 + 2 * pi * progress;
      final tipX = center.dx + radius * cos(tipAngle);
      final tipY = center.dy + radius * sin(tipAngle);

      // Outer glow of tip
      final tipGlow = Paint()
        ..color = AppTheme.accentStart
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(tipX, tipY), 5, tipGlow);

      // Bright inner dot
      final dotSolid = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(tipX, tipY), 3.5, dotSolid);
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
