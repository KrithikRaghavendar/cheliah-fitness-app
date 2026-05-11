import 'package:cheliah_fitness_app/data/fitness_data.dart';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' show ImageFilter;
import 'dart:math' as dart_math;

class MonthCard extends StatefulWidget {
  final MonthData monthData;
  final bool isActive;
  final VoidCallback onTap;

  const MonthCard({
    Key? key,
    required this.monthData,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<MonthCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _isHovered = false;
  bool _isPressed = false;
  bool _hasAppeared = false;

  @override
  void initState() {
    super.initState();
    _shimmerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();

    // Trigger appear animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _hasAppeared = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 80,
          transform: Matrix4.translationValues(
              0, _isHovered && !_isPressed ? -2 : (widget.isActive ? -1 : 0), 0)
            ..scale(_isPressed ? 0.97 : (widget.isActive ? 1.04 : 1.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.isActive
                ? const Color(0x40FF2D55) // Brighter active color base
                : (_isHovered
                    ? const Color(0x8028282D) // rgba(40, 40, 45, 0.5)
                    : const Color(0x591E1E23)), // rgba(30, 30, 35, 0.35)
            border: Border.all(
              color: widget.isActive
                  ? const Color(0xFFFF2D55) // Opaque bright red for neon outline
                  : const Color(0x33FFFFFF), // slightly brighter stroke for inactive
              width: widget.isActive ? 1.5 : 1.0,
            ),
            boxShadow: widget.isActive
                ? const [
                    // Massive outer red glow
                    BoxShadow(
                      color: Color(0x66FF2D55),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    )
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19), // match border
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Animated Progress Bar Fill
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(
                        begin: 0.0,
                        end: _hasAppeared ? (widget.monthData.pct / 100) : 0.0),
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: child,
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        // Use the shimmer controller (now acting as a pulse controller)
                        // It oscillates between 0 and 1 using sin wave
                        final double pulse = (0.5 + 0.5 * dart_math.sin(_shimmerController.value * 2 * dart_math.pi));
                        
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0x80E5093A), // glassy deep red (50% opacity)
                                Color.lerp(const Color(0xA6FF2D55), const Color(0xCCFF5273), pulse)!, // blazing red/pink middle (65-80% opacity)
                                const Color(0x80FF1E4D), // trailing glassy red (50% opacity)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Inner upper and lower specular highlights to create "glass tube" glow
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0x80FFFFFF), // top edge bright reflection
                                      Colors.transparent,
                                      Colors.transparent,
                                      Color(0x33FFFFFF), // bottom edge bounce light
                                    ],
                                    stops: [0.0, 0.15, 0.85, 1.0],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              // Live pulsing edge effect
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 14,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        const Color(0xFFFFFFFF).withOpacity(0.3 + 0.3 * pulse),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Text Overlay
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.monthData.name.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16.8, // 1.05rem
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            shadows: const [
                              Shadow(
                                  color: Color(0x80000000), // 0.5
                                  offset: Offset(0, 1),
                                  blurRadius: 3),
                            ],
                          ),
                        ),
                        Text(
                          '${widget.monthData.pct}%',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13.6, // 0.85rem
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            shadows: const [
                              Shadow(
                                  color: Color(0x66000000), // 0.4
                                  offset: Offset(0, 1),
                                  blurRadius: 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
