import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  bool _isPlaying = true;

  bool _prevPressed = false;
  bool _playPressed = false;
  bool _nextPressed = false;

  static const platform = MethodChannel('com.cheliah.fitness/media_control');

  Future<void> _sendMediaEvent(int keyCode) async {
    try {
      await platform.invokeMethod('sendMediaEvent', {'keyCode': keyCode});
    } on PlatformException catch (e) {
      debugPrint("Failed to send media event: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0x66121212), // Semi-transparent dark
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A30),
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/workout-hero.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Track Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unstoppable',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Eminem',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Controls
                _buildControlButton(
                  icon: Icons.skip_previous_rounded,
                  isPressed: _prevPressed,
                  onTapDown: () => setState(() => _prevPressed = true),
                  onTapUp: () {
                    setState(() => _prevPressed = false);
                    _sendMediaEvent(88); // KEYCODE_MEDIA_PREVIOUS
                  },
                ),
                const SizedBox(width: 4),
                _buildPlayPauseButton(),
                const SizedBox(width: 4),
                _buildControlButton(
                  icon: Icons.skip_next_rounded,
                  isPressed: _nextPressed,
                  onTapDown: () => setState(() => _nextPressed = true),
                  onTapUp: () {
                    setState(() => _nextPressed = false);
                    _sendMediaEvent(87); // KEYCODE_MEDIA_NEXT
                  },
                ),
                const SizedBox(width: 4),
                
                // Cast/device icon
                const Icon(
                  Icons.devices_rounded,
                  color: Colors.white38,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isPressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
  }) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapUp(),
      child: AnimatedScale(
        scale: isPressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.transparent, // expand hit area
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _playPressed = true),
      onTapUp: (_) {
        setState(() {
          _playPressed = false;
          _isPlaying = !_isPlaying;
        });
        _sendMediaEvent(85); // KEYCODE_MEDIA_PLAY_PAUSE
      },
      onTapCancel: () => setState(() => _playPressed = false),
      child: AnimatedScale(
        scale: _playPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0x33FF2D55),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1AFF2D55),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: const Color(0xFFFF2D55),
            size: 24,
          ),
        ),
      ),
    );
  }
}
