import 'package:cheliah_fitness_app/data/workout_data.dart';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:cheliah_fitness_app/widgets/exercise_card.dart';
import 'package:cheliah_fitness_app/widgets/mini_player.dart';
import 'package:cheliah_fitness_app/widgets/workout_completion_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin {
  final List<Exercise> _exercises = WorkoutRoutine.defaultExercises;
  int _currentIndex = 0;
  bool _isCompleted = false;
  bool _showCheckMark = false;
  bool _timerFinished = false;

  // Timer animation controller — only used for timed exercises.
  Timer? _exerciseTimer;
  int _remainingTime = 0;

  // Two-phase slide transition — phase 1: slide-out, phase 2: slide-in
  late AnimationController _slideOutController;
  late AnimationController _slideInController;
  bool _isTransitioning = false;
  bool _showIncomingCard = false;

  // Progress bar animation
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Entry animation
  late AnimationController _entryController;

  // Button pulse for timer-finished state
  late AnimationController _pulseController;

  // Checkmark glow pulse
  late AnimationController _checkGlowController;

  // Tap-scale states
  bool _backPressed = false;
  bool _skipPressed = false;
  bool _nextPressed = false;

  // Fire glow pulse for card border
  late AnimationController _fireGlowController;

  @override
  void initState() {
    super.initState();
    
    // Enable immersive full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Slide-out: card moves left & fades
    _slideOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    // Slide-in: new card enters from right
    _slideInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _checkGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fireGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fireGlowController.repeat(reverse: true);

    // Start entry animation & timer for first exercise
    _entryController.forward();
    _startTimerForCurrentExercise();
    _updateProgressBar();
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _exerciseTimer?.cancel();
    _slideOutController.dispose();
    _slideInController.dispose();
    _progressController.dispose();
    _entryController.dispose();
    _pulseController.dispose();
    _checkGlowController.dispose();
    _fireGlowController.dispose();
    super.dispose();
  }

  Exercise get _currentExercise => _exercises[_currentIndex];
  int get _totalExercises => _exercises.length;

  void _startTimerForCurrentExercise() {
    _timerFinished = false;
    _pulseController.stop();
    _pulseController.reset();

    // Immediately cancel any existing timer instance.
    _exerciseTimer?.cancel();

    if (_currentExercise.isTimed) {
      // Reset the remainingTime variable to the new exercise's duration.
      setState(() {
        _remainingTime = _currentExercise.durationSeconds!;
      });

      // Reinitialize and start a new timer.
      _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
            if (_remainingTime == 0) {
              _timerFinished = true;
              _pulseController.repeat(reverse: true);
              timer.cancel();
            }
          }
        });
      });
    } else {
      setState(() {
        _remainingTime = 0;
      });
    }
  }

  void _updateProgressBar() {
    final oldValue = _progressAnimation.value;
    final newValue = _currentIndex / _totalExercises;
    _progressAnimation = Tween<double>(begin: oldValue, end: newValue).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.reset();
    _progressController.forward();
  }

  void _goToNextExercise() {
    if (_isTransitioning || _isCompleted) return;
    
    // Disable next button if timer hasn't finished (and exercise is timed)
    if (_currentExercise.isTimed && !_timerFinished) return;

    // Show check mark with glow pulse
    setState(() {
      _showCheckMark = true;
    });
    _checkGlowController.reset();
    _checkGlowController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _showCheckMark = false;
      });
      _performTransition();
    });
  }

  void _skipExercise() {
    if (_isTransitioning || _isCompleted) return;
    _performTransition();
  }

  void _performTransition() {
    if (_currentIndex >= _totalExercises - 1) {
      // Last exercise — show completion
      _exerciseTimer?.cancel();
      final oldValue = _progressAnimation.value;
      _progressAnimation =
          Tween<double>(begin: oldValue, end: 1.0).animate(
        CurvedAnimation(
            parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.reset();
      _progressController.forward();
      setState(() {
        _isCompleted = true;
      });
      return;
    }

    _isTransitioning = true;
    _exerciseTimer?.cancel();

    // Phase 1: Slide out current card
    _slideOutController.reset();
    _slideInController.reset();
    setState(() {
      _showIncomingCard = false;
    });

    _slideOutController.forward().then((_) {
      if (!mounted) return;

      // Switch index, begin phase 2
      setState(() {
        _currentIndex++;
        _showIncomingCard = true;
      });
      _startTimerForCurrentExercise();
      _updateProgressBar();

      // Phase 2: Slide in new card
      _slideInController.forward().then((_) {
        if (!mounted) return;
        // Reset slideOut so when we fall back to the !_showIncomingCard
        // branch the card is fully visible (opacity=1, offset=0).
        _slideOutController.reset();
        setState(() {
          _isTransitioning = false;
          _showIncomingCard = false;
        });
      });
    });
  }

  void _onFinish() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.bgGrey,
              AppTheme.bgDeep,
              AppTheme.bgMaroon,
              AppTheme.bgGreyMid,
              AppTheme.bgDeep,
            ],
            stops: [0.0, 0.18, 0.42, 0.65, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Main workout UI
            SafeArea(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entryController,
                  curve: Curves.easeOut,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _entryController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Column(
                    children: [
                      _buildTopSection(),
                      Expanded(child: _buildExerciseArea()),
                      _buildBottomButtons(),
                      _buildMiniPlayer(),
                    ],
                  ),
                ),
              ),
            ),

            // Completion overlay
            if (_isCompleted)
              WorkoutCompletionOverlay(
                onFinish: _onFinish,
              ),
          ],
        ),
      ),
    );
  }

  // ─── Top Section ────────────────────────────────────────────────────

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back arrow + title row
          Row(
            children: [
              // Back button with tap-scale
              GestureDetector(
                onTapDown: (_) => setState(() => _backPressed = true),
                onTapUp: (_) {
                  setState(() => _backPressed = false);
                  Navigator.of(context).pop();
                },
                onTapCancel: () => setState(() => _backPressed = false),
                child: AnimatedScale(
                  scale: _backPressed ? 0.90 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0x661E1E23),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Today's Workout",
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Exercise counter with animated number
          Row(
            children: [
              Text(
                'Exercise ',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              // Animated counter
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: Text(
                  '${_currentIndex + 1}',
                  key: ValueKey<int>(_currentIndex),
                  style: GoogleFonts.outfit(
                    color: AppTheme.accentStart,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                ' / $_totalExercises',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar with ember glow
          AnimatedBuilder(
            animation: Listenable.merge([_progressAnimation, _fireGlowController]),
            builder: (context, child) {
              final fireT = _fireGlowController.value;
              return Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(99),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.accentStart,
                          AppTheme.accentMid,
                          AppTheme.accentEnd,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(
                              255, 45, 85, 0.3 + 0.25 * fireT),
                          blurRadius: 10 + 6 * fireT,
                          spreadRadius: 1 + 2 * fireT,
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(
                              255, 120, 50, 0.15 + 0.15 * fireT),
                          blurRadius: 16 + 8 * fireT,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Exercise Area (with two-phase slide transition) ────────────────

  Widget _buildExerciseArea() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Green check overlay with glow pulse
        if (_showCheckMark)
          AnimatedBuilder(
            animation: _checkGlowController,
            builder: (context, child) {
              final t = _checkGlowController.value;
              // Elastic pop: overshoot then settle
              final scale = t < 0.4
                  ? Curves.easeOutBack.transform(t / 0.4)
                  : 1.0;
              // Glow ring expands outward
              final glowRadius = 24.0 + 20.0 * t;
              final glowOpacity = (1.0 - t) * 0.5;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4CD964),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(76, 217, 100, glowOpacity),
                            blurRadius: glowRadius,
                            spreadRadius: 8 * t,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white.withValues(alpha: scale.clamp(0.0, 1.0)),
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: (t * 2).clamp(0.0, 1.0),
                    child: Text(
                      'Done!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF4CD964),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        // Exercise card with two-phase slide
        if (!_showCheckMark)
          _buildAnimatedCard(),
      ],
    );
  }

  Widget _buildAnimatedCard() {
    // Phase 1: sliding OUT the current card
    if (!_showIncomingCard) {
      return AnimatedBuilder(
        animation: _slideOutController,
        builder: (context, child) {
          final t = Curves.easeInCubic.transform(_slideOutController.value);
          return Transform.translate(
            offset: Offset(-40 * t, 0),
            child: Opacity(
              opacity: (1.0 - t).clamp(0.0, 1.0),
              child: _buildCard(),
            ),
          );
        },
      );
    }

    // Phase 2: sliding IN the new card
    return AnimatedBuilder(
      animation: _slideInController,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_slideInController.value);
        return Transform.translate(
          offset: Offset(60 * (1.0 - t), 0),
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ExerciseCard(
        key: ValueKey<int>(_currentIndex),
        exercise: _currentExercise,
        remainingTime: _remainingTime,
      ),
    );
  }

  // ─── Bottom Buttons ─────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    if (_isCompleted) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          // Skip button with tap-scale
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _skipPressed = true),
              onTapUp: (_) {
                setState(() => _skipPressed = false);
                if (!_isTransitioning) _skipExercise();
              },
              onTapCancel: () => setState(() => _skipPressed = false),
              child: AnimatedScale(
                scale: _skipPressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutCubic,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0x33FFFFFF),
                    ),
                    color: _skipPressed
                        ? const Color(0x0DFFFFFF)
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Next Exercise button with tap-scale + pulse
          Expanded(
            flex: 3,
            child: _buildNextButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final bool highlight = _timerFinished || !_currentExercise.isTimed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _nextPressed = true),
      onTapUp: (_) {
        setState(() => _nextPressed = false);
        if (!_isTransitioning) _goToNextExercise();
      },
      onTapCancel: () => setState(() => _nextPressed = false),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final double pulseVal = _pulseController.value;
          final double pulseScale =
              _timerFinished ? 1.0 + 0.025 * pulseVal : 1.0;
          final double baseScale = _nextPressed ? 0.96 : 1.0;
          final double glowOpacity =
              _timerFinished ? 0.5 + 0.35 * pulseVal : 0.3;

          return AnimatedScale(
            scale: baseScale,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: Transform.scale(
              scale: pulseScale,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: highlight
                        ? const [AppTheme.accentStart, AppTheme.accentEnd]
                        : [
                            AppTheme.accentStart.withValues(alpha: 0.5),
                            AppTheme.accentEnd.withValues(alpha: 0.5),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentStart.withValues(alpha: glowOpacity),
                      blurRadius: _timerFinished ? 30 : 16,
                      offset: const Offset(0, 4),
                    ),
                    if (_timerFinished)
                      BoxShadow(
                        color: AppTheme.accentStart.withValues(alpha: 0.15 + 0.1 * pulseVal),
                        blurRadius: 50,
                        spreadRadius: 4 * pulseVal,
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Next Exercise',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniPlayer() {
    // Fades out when the workout is completed.
    // The entry animation (fade+slide up) is inherited from the parent Column's entryController.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isCompleted ? 0.0 : 1.0,
      child: const MiniPlayer(),
    );
  }
}

