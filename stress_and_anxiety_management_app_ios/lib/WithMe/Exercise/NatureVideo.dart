import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Full-bleed, silent stock footage. Ambient sound is owned exclusively by
/// AmbientAudio so a video can never leak its own audio into another choice.
class NatureVideo extends StatefulWidget {
  const NatureVideo({super.key, required this.sound, this.still = false});

  final String sound;

  /// Reduced motion: hold the current frame instead of playing.
  final bool still;

  @override
  State<NatureVideo> createState() => _NatureVideoState();
}

class _NatureVideoState extends State<NatureVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.sound == 'None') return;
    final controller = VideoPlayerController.asset(
      'assets/video/${widget.sound.toLowerCase()}.mp4',
    );
    try {
      await controller.initialize();
    } catch (_) {
      // Widget tests and unsupported platforms keep the branded fallback;
      // iOS, Android, macOS and web use the actual full-bleed video.
      await controller.dispose();
      return;
    }
    await controller.setLooping(true);
    await controller.setVolume(0);
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
    if (!widget.still) await controller.play();
  }

  @override
  void didUpdateWidget(NatureVideo old) {
    super.didUpdateWidget(old);
    final controller = _controller;
    if (controller == null || old.still == widget.still) return;
    widget.still ? controller.pause() : controller.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(color: Color(0xFF183D3D));
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
