import 'package:cheliah_fitness_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 60,
    this.borderRadius = 16,
    this.textStyle,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(
            0,
            _isPressed
                ? 1
                : _isHovered
                    ? -2
                    : 0,
            0,
          )..scale(_isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: const Color(0x4DFF2D55), // 30% opacity
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : (_isHovered ? AppTheme.shadowBtnHover : AppTheme.shadowBtn),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                // Animated Gradient Background
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final alignX = (_controller.value * 2) - 1; // -1 to 1
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: const [
                            AppTheme.accentStart,
                            AppTheme.accentMid,
                            AppTheme.accentEnd,
                          ],
                          begin: Alignment(alignX - 1, 0),
                          end: Alignment(alignX + 1, 0),
                        ),
                      ),
                    );
                  },
                ),
                // Hover highlight overlay
                AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: const Alignment(0.2, 1), // approx 60%
                      ),
                    ),
                  ),
                ),
                // Text
                Center(
                  child: Text(
                    widget.text,
                    style: widget.textStyle ??
                        GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17.6, // ~1.1rem
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                // Material Ripple
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    onHighlightChanged: (isHighlight) {
                      setState(() => _isPressed = isHighlight);
                    },
                    splashColor: Colors.white.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
