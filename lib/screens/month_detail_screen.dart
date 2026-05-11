import 'package:cheliah_fitness_app/data/fitness_data.dart';
import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:cheliah_fitness_app/widgets/week_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthDetailScreen extends StatefulWidget {
  final int monthIndex;

  const MonthDetailScreen({Key? key, required this.monthIndex})
      : super(key: key);

  @override
  State<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends State<MonthDetailScreen> {
  final int _currentMonthIdx = DateTime.now().month - 1; // 0-based
  late int _currentWeekIdx;
  late int _currentDayInWeek;
  int? _expandedWeekIndex;
  final ScrollController _scrollController = ScrollController();

  bool _hasEntered = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    bool isCurrentMonth = widget.monthIndex == _currentMonthIdx;
    DateTime today = DateTime.now();

    _currentWeekIdx = isCurrentMonth
        ? ((today.day - 1) ~/ 7).clamp(0, 3)
        : -1;
    _currentDayInWeek = isCurrentMonth
        ? ((today.day - 1) % 7) + 1
        : -1;

    // Expand current week card if it exists
    if (isCurrentMonth) {
      _expandedWeekIndex = _currentWeekIdx;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _hasEntered = true;
        });
        
        // Scroll to active week if applicable
        if (isCurrentMonth && _scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 600), () {
            double offset = (_currentWeekIdx * 140.0) - 100; // rough estimation
            _scrollController.animateTo(
              offset.clamp(0.0, _scrollController.position.maxScrollExtent),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          });
        }
      }
    }); // Add this closing parenthesis and semicolon
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _backToDashboard() {
    setState(() {
      _isExiting = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _toggleWeekExpansion(int weekIdx) {
    setState(() {
      if (_expandedWeekIndex == weekIdx) {
        _expandedWeekIndex = null;
      } else {
        _expandedWeekIndex = weekIdx;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final month = FitnessData.monthData[widget.monthIndex];
    final weeks = FitnessData.weeklyData[widget.monthIndex] ?? [0, 0, 0, 0];
    bool isCurrentMonth = widget.monthIndex == _currentMonthIdx;

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits deep background
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
        child: AnimatedOpacity(
            opacity: _hasEntered && !_isExiting ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: SafeArea(
              child: Column(
                children: [
                  // Month Detail Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back button
                        InkWell(
                          onTap: _backToDashboard,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0x661E1E23), // rgba(30, 30, 35, 0.4)
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0x1AFFFFFF), // 0.1
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Titles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${month.fullName} Training',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 25.6, // 1.6rem
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your weekly workout progress',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13.6, // 0.85rem
                                  letterSpacing: 0.13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Weeks Section
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                          top: 24, left: 24, right: 24, bottom: 40),
                      itemCount: weeks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: WeekCard(
                            weekIndex: index,
                            daysCompleted: weeks[index],
                            isCurrentMonth: isCurrentMonth,
                            currentWeekIdx: _currentWeekIdx,
                            currentDayInWeek: _currentDayInWeek,
                            isExpanded: _expandedWeekIndex == index,
                            onToggle: () => _toggleWeekExpansion(index),
                          ),
                        );
                      },
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
