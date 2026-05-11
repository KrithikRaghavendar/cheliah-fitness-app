import 'package:cheliah_fitness_app/data/fitness_data.dart';
import 'package:cheliah_fitness_app/screens/month_detail_screen.dart';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:cheliah_fitness_app/widgets/month_card.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final int _currentMonthIdx = DateTime.now().month - 1; // 0-based
  bool _isExitingToDetail = false;
  bool _hasEntered = false;
  late String _heroImagePath;
  late String _greetingText;

  @override
  void initState() {
    super.initState();
    _initHeroData();
    // Entrance animation trigger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _hasEntered = true;
        });
        // Scroll to active month
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && _scrollController.hasClients) {
            // Approx 108 height per card + spacing. Rough estimate to center.
            double offset = (_currentMonthIdx * 108.0) -
                (MediaQuery.of(context).size.height / 2) +
                320; // 320 is hero image height
            _scrollController.animateTo(
              offset.clamp(0.0, _scrollController.position.maxScrollExtent),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  void _initHeroData() {
    final random = math.Random();
    final imageNum = random.nextInt(5) + 1; // 1 to 5
    _heroImagePath = 'assets/images/hero/hero_$imageNum.jpg';

    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      _greetingText = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      _greetingText = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      _greetingText = 'Good Evening';
    } else {
      final quotes = [
        "The grinding never stops",
        "Discipline equals freedom",
        "Train while they sleep",
      ];
      _greetingText = quotes[random.nextInt(quotes.length)];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openMonthDetail(int monthIdx) {
    setState(() {
      _isExitingToDetail = true;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) =>
                MonthDetailScreen(monthIndex: monthIdx),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final curve = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(curve),
                child: FadeTransition(
                  opacity: curve,
                  child: child,
                ),
              );
            },
          ),
        ).then((_) {
          // When returning back to dashboard
          if (mounted) {
            setState(() {
              _isExitingToDetail = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background provided by Container
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          // Dash fade in from scale 1.05 and x=-50%, exit to detail uses scale 1.05
          transform: Matrix4.translationValues(
              _hasEntered ? 0 : -size.width * 0.05, 0, 0)
            ..scale(_isExitingToDetail
                ? 1.05
                : (_hasEntered ? 1.0 : 1.05)),
          child: AnimatedOpacity(
            opacity: _isExitingToDetail ? 0.0 : (_hasEntered ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Image
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 320,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _heroImagePath,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              // Filter brightness 0.85 contrast 1.05 simulation
                              color: Colors.black.withOpacity(0.15),
                              colorBlendMode: BlendMode.darken,
                            ),
                            // Hero overlay gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0x80000000), // semi-transparent black
                                    AppTheme.bgDeep.withOpacity(0.95),
                                  ],
                                  stops: const [0.3, 0.65, 1.0],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Greeting Text
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              bottom: _hasEntered ? 24.0 : 8.0,
                              left: 24.0,
                              right: 24.0,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 400),
                                opacity: _hasEntered ? 1.0 : 0.0,
                                child: Text(
                                  _greetingText,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      const Shadow(
                                        color: Colors.black45,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Soft glow beneath hero
                      Positioned(
                        bottom: -20,
                        left: size.width * 0.15, // centered, width 70%
                        width: size.width * 0.7,
                        height: 40,
                        child: IgnorePointer(
                          child: Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x1FFF2D55),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Monthly Progress Section
                SliverPadding(
                  padding: const EdgeInsets.only(top: 28, bottom: 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Glowing Dumbbell Icon
                                Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x66FF2D55),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: Color(0xFFFF2D55),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Monthly Progress',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w800, // bolder
                                    fontSize: 19.5, // slightly larger
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Glowing red underline
                            Container(
                              width: 170, // Matches width of title row roughly
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: const Color(0xFFFF2D55),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x80FF2D55),
                                    blurRadius: 6,
                                  ),
                                  BoxShadow(
                                    color: Color(0x40FF2D55),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: FitnessData.monthData.asMap().entries.map((entry) {
                            int idx = entry.key;
                            MonthData month = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 28),
                              child: MonthCard(
                                monthData: month,
                                isActive: idx == _currentMonthIdx,
                                onTap: () => _openMonthDetail(idx),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
