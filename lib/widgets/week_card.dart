import 'package:cheliah_fitness_app/screens/workout_screen.dart';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' show ImageFilter;

class WeekCard extends StatefulWidget {
  final int weekIndex;
  final int daysCompleted;
  final bool isCurrentMonth;
  final int currentWeekIdx;
  final int currentDayInWeek;
  final bool isExpanded;
  final VoidCallback onToggle;

  const WeekCard({
    Key? key,
    required this.weekIndex,
    required this.daysCompleted,
    required this.isCurrentMonth,
    required this.currentWeekIdx,
    required this.currentDayInWeek,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<WeekCard> createState() => _WeekCardState();
}

class _WeekCardState extends State<WeekCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _hasAppeared = false;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // slightly stagger bar appearance
        Future.delayed(Duration(milliseconds: 200 * widget.weekIndex), () {
          if (mounted) {
            setState(() {
              _hasAppeared = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = widget.weekIndex == widget.currentWeekIdx;
    
    // Calculate actual days completed logically based on current day
    int actualDaysCompleted = widget.daysCompleted;
    if (widget.isCurrentMonth && widget.weekIndex > widget.currentWeekIdx) {
      actualDaysCompleted = 0;
    } else if (widget.isCurrentMonth && widget.weekIndex == widget.currentWeekIdx) {
      actualDaysCompleted = widget.daysCompleted.clamp(0, (widget.currentDayInWeek - 1).clamp(0, 7)).toInt();
    }
    double pct = (actualDaysCompleted / 7.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onToggle();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          transform: Matrix4.translationValues(
              0, _isHovered && !_isPressed ? -2 : (isActive ? -2 : 0), 0)
            ..scale(_isPressed ? 0.97 : (isActive ? 1.02 : 1.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isActive
                ? const Color(0x1FFF2D55) // rgba(255, 45, 85, 0.12)
                : (_isHovered
                    ? const Color(0x8028282D) // rgba(40, 40, 45, 0.5)
                    : const Color(0x591E1E23)), // rgba(30, 30, 35, 0.35)
            border: Border.all(
              color: isActive
                  ? const Color(0x66FF2D55) // 0.4
                  : const Color(0x19FFFFFF), // 0.1
            ),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                        color: Color(0x40FF2D55), blurRadius: 28), // 0.25
                    BoxShadow(
                        color: Color(0x4D000000), // 0.3
                        blurRadius: 16,
                        offset: Offset(0, 6)),
                  ]
                : const [
                    BoxShadow(
                        color: Color(0x33000000), // 0.2
                        blurRadius: 16,
                        offset: Offset(0, 6))
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Week ${widget.weekIndex + 1}',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17.6, // 1.1rem
                    ),
                  ),
                  Text(
                    '$actualDaysCompleted / 7 days completed',
                    style: GoogleFonts.inter(
                      color: isActive
                          ? const Color(0xD9FFFFFF) // 0.85
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.6, // 0.85rem
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Mini progress bar track
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF), // 0.06
                  borderRadius: BorderRadius.circular(99),
                ),
                alignment: Alignment.centerLeft,
                // Fill
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.fastOutSlowIn,
                  alignment: Alignment.centerLeft,
                  widthFactor: _hasAppeared ? pct : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xE6FF2D55), // 0.9
                          Color(0xF2FF8296), // 0.95
                          Color(0xF2C41E3A), // 0.95
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x4DFF2D55), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
              // Expandable Detail section
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack, // soft spring animation
                child: widget.isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0x0FFFFFFF), // 0.06
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 18),
                              // Day circles
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  int day = index + 1;
                                  return _buildDayCircle(
                                      day, actualDaysCompleted);
                                }),
                              ),
                              const SizedBox(height: 20),
                              // Inline Start Workout button
                              // Start Workout Inline Button
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 300),
                                      pageBuilder: (context, animation, secondaryAnimation) => const WorkoutScreen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                                        return ScaleTransition(
                                          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curve),
                                          child: FadeTransition(opacity: curve, child: child),
                                        );
                                      }
                                    )
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                  backgroundColor: Colors.transparent, // Uses gradient
                                  shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.accentStart,
                                        AppTheme.accentEnd,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x4DFF2D55),
                                          blurRadius: 20,
                                          offset: Offset(0, 4)),
                                      BoxShadow(
                                          color: Color(0x26FF2D55),
                                          blurRadius: 12),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    child: Text(
                                      'Start Workout',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.2, // 0.95rem
                                        letterSpacing: 0.48, // 0.03em
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCircle(int day, int actualDaysCompleted) {
    String state = '';
    
    if (widget.weekIndex < widget.currentWeekIdx ||
        (widget.weekIndex == widget.currentWeekIdx &&
            day < widget.currentDayInWeek)) {
      state = day <= actualDaysCompleted ? 'completed' : 'incomplete';
    } else if (widget.weekIndex == widget.currentWeekIdx &&
        day == widget.currentDayInWeek) {
      state = 'current';
    } else if (!widget.isCurrentMonth) {
      state = day <= actualDaysCompleted ? 'completed' : 'incomplete';
    } else {
      state = 'future';
    }

    // Colors based on state
    BoxDecoration decoration;
    Color textColor;

    switch (state) {
      case 'completed':
        decoration = const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: [Color(0xE6FF2D55), Color(0xF2C41E3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: Color(0x40FF2D55), blurRadius: 8, offset: Offset(0, 2))
          ],
        );
        textColor = Colors.white;
        break;
      case 'incomplete':
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x0AFFFFFF), // 0.04
          border: Border.all(color: const Color(0x26FFFFFF), width: 1.5), // 0.15
        );
        textColor = const Color(0x66FFFFFF); // 0.4
        break;
      case 'current':
        return AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            double value = _glowController.value;
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: const Color(0xE6FF2D55), width: 2.5),
                boxShadow: [
                  BoxShadow(color: Color(0x80FF2D55).withOpacity(0.5 + (0.2 * value)), blurRadius: 16 + (6 * value)),
                  BoxShadow(color: Color(0x33FF2D55).withOpacity(0.2 + (0.1 * value)), blurRadius: 32 + (12 * value)),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.8,
                  shadows: const [
                    Shadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 3)
                  ],
                ),
              ),
            );
          },
        );
      case 'future':
      default:
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x08FFFFFF), // 0.03
          // dashed border is tricky, we'll use a solid dim border as fallback in pure flutter w/o packages
          border: Border.all(color: const Color(0x14FFFFFF), width: 1.5), // 0.08
        );
        textColor = const Color(0x4DFFFFFF); // 0.3
        break;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: state == 'future' ? 0.4 : 1.0,
      child: Container(
        width: 40,
        height: 40,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: GoogleFonts.outfit(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 12.8,
          ),
        ),
      ),
    );
  }
}
