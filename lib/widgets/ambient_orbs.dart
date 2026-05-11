import 'package:flutter/material.dart';

class AmbientOrbs extends StatefulWidget {
  const AmbientOrbs({Key? key}) : super(key: key);

  @override
  State<AmbientOrbs> createState() => _AmbientOrbsState();
}

class _AmbientOrbsState extends State<AmbientOrbs>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _controller2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 15))
      ..repeat(reverse: true);
    _controller3 = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Orb 1
        Positioned(
          top: -80,
          right: -60,
          child: AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              final double value = _controller1.value;
              return Transform.translate(
                offset: Offset(-30 * value, 40 * value),
                child: Transform.scale(
                  scale: 1.0 + (0.1 * value),
                  child: Opacity(
                    opacity: 0.7 + (0.3 * value),
                    child: _buildOrb(
                      size: 340,
                      color: const Color(0x38781428), // rgba(120, 20, 40, 0.22)
                      blurRadius: 80,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Orb 2
        Positioned(
          bottom: 60,
          left: -80,
          child: AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              final double value = _controller2.value;
              return Transform.translate(
                offset: Offset(25 * value, -30 * value),
                child: Transform.scale(
                  scale: 1.0 + (0.15 * value),
                  child: Opacity(
                    opacity: 0.6 + (0.3 * value),
                    child: _buildOrb(
                      size: 280,
                      color: const Color(0x26A01432), // rgba(160, 20, 50, 0.15)
                      blurRadius: 80,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Orb 3
        Positioned(
          bottom: -40,
          right: 20,
          child: AnimatedBuilder(
            animation: _controller3,
            builder: (context, child) {
              final double value = _controller3.value;
              return Transform.translate(
                offset: Offset(-20 * value, -25 * value),
                child: Transform.scale(
                  scale: 1.0 + (0.05 * value),
                  child: Opacity(
                    opacity: 0.5 + (0.3 * value),
                    child: _buildOrb(
                      size: 200,
                      color: const Color(0x1E50141E), // rgba(80, 20, 30, 0.12)
                      blurRadius: 80,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrb(
      {required double size,
      required Color color,
      required double blurRadius}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}
