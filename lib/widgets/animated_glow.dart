import 'package:flutter/material.dart';

class AnimatedGlow extends StatefulWidget {
  final double width;
  final double height;

  const AnimatedGlow({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<AnimatedGlow> createState() => _AnimatedGlowState();
}

class _AnimatedGlowState extends State<AnimatedGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOutSine,
      ),
    );

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _glowAnimation.value,
          child: Opacity(
            opacity: _glowAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x47FF2D55), // 0.28 opacity accent red
              blurRadius: 12,
              spreadRadius: 4,
            )
          ],
        ),
      ),
    );
  }
}
