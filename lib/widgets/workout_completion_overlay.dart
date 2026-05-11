import 'dart:math';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium workout completion overlay with glowing ring, animated streak
/// counter (count-up), staggered entry, and a single "Continue" button.
class WorkoutCompletionOverlay extends StatefulWidget {
  final VoidCallback onFinish;
  final int previousStreak;
  final int newStreak;

  const WorkoutCompletionOverlay({
    Key? key,
    required this.onFinish,
    this.previousStreak = 4,
    this.newStreak = 5,
  }) : super(key: key);

  @override
  State<WorkoutCompletionOverlay> createState() =>
      _WorkoutCompletionOverlayState();
}

class _WorkoutCompletionOverlayState extends State<WorkoutCompletionOverlay>
    with TickerProviderStateMixin {
  // ── Animation controllers ──

  // Phase 1: backdrop darkens
  late final AnimationController _backdropController;

  // Phase 2: ring appears (staggered element 1)
  late final AnimationController _ringEntryController;

  // Ring breathing pulse (loops continuously)
  late final AnimationController _ringBreathController;

  // Phase 3: title fades in (staggered element 2)
  late final AnimationController _titleController;

  // Phase 4: streak appears + count-up (staggered element 3)
  late final AnimationController _streakEntryController;
  late final AnimationController _streakCountController;
  late final Animation<double> _streakCountAnim;

  // Streak glow pop when reaching final value
  late final AnimationController _streakGlowController;

  // Phase 5: subtext (staggered element 4)
  late final AnimationController _subtextController;

  // Phase 6: button (staggered element 5)
  late final AnimationController _buttonController;

  // Displayed streak value (animated count-up)
  int _displayedStreak = 0;

  // Button tap state
  bool _btnPressed = false;

  @override
  void initState() {
    super.initState();
    _displayedStreak = widget.previousStreak;

    // ── Backdrop (0–400ms) ──
    _backdropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // ── Ring entry (stagger 1) ──
    _ringEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // ── Ring breathing (continuous) ──
    _ringBreathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // ── Title entry (stagger 2) ──
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // ── Streak entry (stagger 3) ──
    _streakEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // ── Streak count-up (700ms) ──
    _streakCountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _streakCountAnim = Tween<double>(
      begin: widget.previousStreak.toDouble(),
      end: widget.newStreak.toDouble(),
    ).animate(CurvedAnimation(
      parent: _streakCountController,
      curve: Curves.easeOutCubic,
    ));
    _streakCountAnim.addListener(() {
      final newVal = _streakCountAnim.value.round();
      if (newVal != _displayedStreak) {
        setState(() => _displayedStreak = newVal);
      }
    });

    // ── Streak glow pop ──
    _streakGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // ── Subtext entry (stagger 4) ──
    _subtextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // ── Button entry (stagger 5) ──
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // ── Staggered sequence ──
    // t=0ms       → backdrop starts
    // t=250ms     → ring entry
    // t=400ms     → ring breathing starts (loops)
    // t=350ms     → title entry (+100ms after ring)
    // t=450ms     → streak entry (+100ms after title)
    // t=650ms     → streak count-up starts (200ms after streak visible)
    // t=1350ms    → streak glow pop (after count-up finishes)
    // t=550ms     → subtext entry (+100ms after streak)
    // t=700ms     → button entry (+150ms after subtext)

    _backdropController.forward();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _ringEntryController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ringBreathController.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _titleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _streakEntryController.forward();
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        _streakCountController.forward().then((_) {
          if (mounted) _streakGlowController.forward();
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) _subtextController.forward();
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _backdropController.dispose();
    _ringEntryController.dispose();
    _ringBreathController.dispose();
    _titleController.dispose();
    _streakEntryController.dispose();
    _streakCountController.dispose();
    _streakGlowController.dispose();
    _subtextController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // ── Helper: staggered fade + slide-up wrapper ──
  Widget _staggeredEntry({
    required AnimationController controller,
    required Widget child,
    double slideDistance = 0.06,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ).value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1.0 - t)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Darkened backdrop ──
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _backdropController,
              curve: Curves.easeOut,
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xF0120A0E),
                    Color(0xF50A0A0A),
                  ],
                ),
              ),
            ),
          ),

          // ── Content (each element staggered independently) ──
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // 1. Glowing ring (staggered + breathing)
                _staggeredEntry(
                  controller: _ringEntryController,
                  child: _buildGlowingRing(),
                ),
                const SizedBox(height: 36),

                // 2. Title
                _staggeredEntry(
                  controller: _titleController,
                  child: _buildTitle(),
                ),
                const SizedBox(height: 28),

                // 3. Streak counter
                _staggeredEntry(
                  controller: _streakEntryController,
                  child: _buildStreakCounter(),
                ),
                const SizedBox(height: 16),

                // 4. Subtext
                _staggeredEntry(
                  controller: _subtextController,
                  child: _buildSubtext(),
                ),

                const Spacer(flex: 3),

                // 5. Continue button
                _staggeredEntry(
                  controller: _buttonController,
                  child: _buildContinueButton(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Glowing Ring with breathing scale ─────────────────────────────

  Widget _buildGlowingRing() {
    const Color neonStart = Color(0xFF39FF14);
    const Color neonEnd = Color(0xFF32CD32);

    return AnimatedBuilder(
      animation: _ringBreathController,
      builder: (context, child) {
        final breath = _ringBreathController.value;
        // Slow breathing: scale oscillates 1.0 → 1.06 → 1.0
        final breathScale = 1.0 + 0.06 * sin(breath * pi);
        // Glow intensity breathes with it
        final glowIntensity = 0.5 + 0.5 * sin(breath * pi);

        return Transform.scale(
          scale: breathScale,
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: neonStart
                            .withOpacity(0.15 + 0.15 * glowIntensity),
                        blurRadius: 50 + 30 * glowIntensity,
                        spreadRadius: 6 + 10 * glowIntensity,
                      ),
                      BoxShadow(
                        color: neonEnd
                            .withOpacity(0.08 + 0.10 * glowIntensity),
                        blurRadius: 70 + 20 * glowIntensity,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
                // Painted ring
                CustomPaint(
                  size: const Size(160, 160),
                  painter: _GlowRingPainter(pulse: breath),
                ),
                // Inner subtle circle
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        neonStart
                            .withOpacity(0.06 + 0.08 * glowIntensity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Title ──────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Text(
      'Workout Complete',
      style: GoogleFonts.outfit(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
    );
  }

  // ─── Streak Counter ─────────────────────────────────────────────────

  Widget _buildStreakCounter() {
    const Color neonStart = Color(0xFF39FF14);

    return AnimatedBuilder(
      animation:
          Listenable.merge([_streakCountController, _streakGlowController]),
      builder: (context, child) {
        // Scale animation: 1.0 → 1.1 during count-up → 1.0 at rest
        final countT = _streakCountController.value;
        // easeOutBack gives a nice overshoot: goes above 1.0 then settles
        final scaleUp =
            1.0 + 0.1 * Curves.easeOutBack.transform(countT);

        // Extra pop scale when glow fires (1.0 → 1.08 → 1.0)
        final glowT = _streakGlowController.value;
        final popCurve = glowT < 0.35
            ? Curves.easeOut.transform(glowT / 0.35)
            : 1.0 - Curves.easeInOut.transform((glowT - 0.35) / 0.65);
        final popScale = 1.0 + 0.08 * popCurve;

        final totalScale = scaleUp * popScale;

        // Glow opacity follows a bell curve
        final glowOpacity = glowT < 0.25
            ? glowT / 0.25
            : 1.0 - ((glowT - 0.25) / 0.75);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: neonStart.withOpacity(0.1),
            border: Border.all(
              color: neonStart
                  .withOpacity(0.2 + 0.2 * glowOpacity),
            ),
            boxShadow: [
              if (glowOpacity > 0)
                BoxShadow(
                  color: neonStart
                      .withOpacity(0.3 * glowOpacity),
                  blurRadius: 36 * glowOpacity,
                  spreadRadius: 6 * glowOpacity,
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fire emoji scales with the number
              Transform.scale(
                scale: totalScale,
                child: const Text('🔥', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              // Animated number with scale bounce
              Transform.scale(
                scale: totalScale,
                child: Text(
                  '$_displayedStreak',
                  style: GoogleFonts.outfit(
                    color: neonStart,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Day Streak',
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Subtext ────────────────────────────────────────────────────────

  Widget _buildSubtext() {
    return Text(
      "You're getting stronger every day",
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 1.5,
      ),
    );
  }

  // ─── Continue Button ────────────────────────────────────────────────

  Widget _buildContinueButton() {
    const Color neonStart = Color(0xFF39FF14);
    const Color neonEnd = Color(0xFF32CD32);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _btnPressed = true),
        onTapUp: (_) {
          setState(() => _btnPressed = false);
          widget.onFinish();
        },
        onTapCancel: () => setState(() => _btnPressed = false),
        child: AnimatedScale(
          scale: _btnPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [neonStart, neonEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: neonStart.withOpacity(0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: neonStart.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Continue',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Glowing Ring Painter ──────────────────────────────────────────────

class _GlowRingPainter extends CustomPainter {
  final double pulse; // 0.0 → 1.0 (oscillating)

  _GlowRingPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    const Color neonStart = Color(0xFF39FF14);
    const Color neonEnd = Color(0xFF32CD32);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final strokeWidth = 5.0 + 1.0 * pulse;

    // Track ring (dim)
    final trackPaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Gradient ring
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + 2 * pi,
      colors: [
        neonStart,
        neonStart,
        const Color(0xFFB4FF85),
        neonEnd,
        neonStart.withOpacity(0.6),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(-pi / 2 + pulse * 0.3),
    );

    // Glow arc (blurred)
    final glowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius, glowPaint);

    // Solid arc on top
    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, arcPaint);

    // Bright tip dot at top
    final tipAngle = -pi / 2 + pulse * pi * 2 * 0.08;
    final tipX = center.dx + radius * cos(tipAngle);
    final tipY = center.dy + radius * sin(tipAngle);

    final tipGlow = Paint()
      ..color = Colors.white.withOpacity(0.6 + 0.3 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(tipX, tipY), 4, tipGlow);

    final dotSolid = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(tipX, tipY), 2.5, dotSolid);
  }

  @override
  bool shouldRepaint(_GlowRingPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}
