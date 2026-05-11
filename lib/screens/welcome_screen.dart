import 'package:cheliah_fitness_app/screens/dashboard_screen.dart';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:cheliah_fitness_app/widgets/ambient_orbs.dart';
import 'package:cheliah_fitness_app/widgets/animated_glow.dart';
import 'package:cheliah_fitness_app/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {

  void _startWorkout() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 640;

    return Scaffold(
      backgroundColor: Colors.transparent, // Uses container gradient below
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity(),
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 350),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Deep background gradient
              Container(
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
              ),
              // Ambient floating orbs
              const AmbientOrbs(),
              // Content wrapper
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 28,
                      right: 28,
                      top: isCompact ? 40 : 60,
                      bottom: isCompact ? 32 : 48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // Greeting Entrance Animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            // Slower fade in
                            final opacity = (value / 0.6).clamp(0.0, 1.0);
                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(0, 60 * (1 - value)), // Increased offset for float
                                child: child, // Removed scale to emphasize just floating up and fading
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                'Welcome',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontSize: 44, // 2.75rem clamped
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.88,
                                  height: 1.15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFFF2D55), Color(0xFFFF6B81)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  'Cheliah',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white, // Mask overrides
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.88,
                                    height: 1.15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Quote Entrance Animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutQuart,
                          // Delay quote slightly
                          builder: (context, value, child) {
                            final delayedValue = (value - 0.2).clamp(0.0, 1.0) / 0.8;
                            final opacity = (delayedValue / 0.6).clamp(0.0, 1.0);
                            
                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(0, 60 * (1 - delayedValue)),
                                child: child,
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 280,
                            child: Text(
                              'Own Your Power',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 17.6, // 1.1rem
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.35,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // CTA Wrapper Entrance Animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            final delayedValue = (value - 0.4).clamp(0.0, 1.0) / 0.6;
                            final opacity = (delayedValue / 0.6).clamp(0.0, 1.0);
                            
                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(0, 60 * (1 - delayedValue)),
                                child: child, // Kept scale standard for the button area as requested, just floats
                              ),
                            );
                          },
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: isCompact ? 32.0 : 48.0),
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Glow beneath button
                                Positioned(
                                  bottom: -12,
                                  child: const AnimatedGlow(
                                    width: 180,
                                    height: 40,
                                  ),
                                ),
                                GradientButton(
                                  text: 'Start Workout',
                                  width: 280,
                                  onPressed: _startWorkout,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
