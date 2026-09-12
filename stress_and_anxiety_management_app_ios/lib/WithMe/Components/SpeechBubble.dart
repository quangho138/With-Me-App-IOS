import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// Which edge the bubble's tail points from.
enum BubbleTail { bottom, bottomLeft, left, none }

/// The cream speech bubble the companion talks through.
///
/// Text is revealed a character at a time when [typewriter] is set, which is
/// what makes the companion feel like it is speaking rather than pasting.
class SpeechBubble extends StatefulWidget {
  const SpeechBubble({
    super.key,
    required this.text,
    this.tail = BubbleTail.bottom,
    this.typewriter = false,
    this.maxWidth = 320,
    this.style,
    this.onFinished,
  });

  final String text;
  final BubbleTail tail;

  /// Reveal the text progressively instead of all at once.
  final bool typewriter;

  final double maxWidth;
  final TextStyle? style;

  /// Fires once the full text is on screen.
  final VoidCallback? onFinished;

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(vsync: this, duration: _durationFor(widget.text))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onFinished?.call();
      });
    if (widget.typewriter) {
      _reveal.forward();
    } else {
      _reveal.value = 1;
      // Let the caller know immediately; the text is already complete.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onFinished?.call());
    }
  }

  @override
  void didUpdateWidget(covariant SpeechBubble old) {
    super.didUpdateWidget(old);
    if (widget.text != old.text) {
      _reveal
        ..duration = _durationFor(widget.text)
        ..reset();
      if (widget.typewriter) {
        _reveal.forward();
      } else {
        _reveal.value = 1;
      }
    }
  }

  /// Roughly 28 ms a character, floored so short lines still read as spoken.
  Duration _durationFor(String text) =>
      Duration(milliseconds: (text.length * 28).clamp(400, 6000));

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: CustomPaint(
        painter: _BubblePainter(tail: widget.tail),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            widget.tail == BubbleTail.left ? 26 : 20,
            18,
            20,
            widget.tail == BubbleTail.bottom || widget.tail == BubbleTail.bottomLeft
                ? 26
                : 18,
          ),
          child: AnimatedBuilder(
            animation: _reveal,
            builder: (context, _) {
              final shown =
                  (widget.text.length * _reveal.value).round().clamp(0, widget.text.length);
              return Text(
                widget.text.substring(0, shown),
                textAlign: TextAlign.center,
                style: widget.style ?? WithMeText.bubble,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.tail});

  final BubbleTail tail;

  @override
  void paint(Canvas canvas, Size size) {
    // The tail eats into the padded box, so the rounded body stops short of it.
    final bodyHeight = switch (tail) {
      BubbleTail.bottom || BubbleTail.bottomLeft => size.height - 10,
      _ => size.height,
    };
    final bodyLeft = tail == BubbleTail.left ? 10.0 : 0.0;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyLeft, 0, size.width - bodyLeft, bodyHeight),
      const Radius.circular(WithMeSpace.radiusLg),
    );

    final path = Path()..addRRect(body);

    switch (tail) {
      case BubbleTail.bottom:
        final cx = size.width / 2;
        path
          ..moveTo(cx - 12, bodyHeight - 1)
          ..lineTo(cx, bodyHeight + 12)
          ..lineTo(cx + 12, bodyHeight - 1)
          ..close();
        break;
      case BubbleTail.bottomLeft:
        final cx = size.width * 0.26;
        path
          ..moveTo(cx - 11, bodyHeight - 1)
          ..lineTo(cx - 4, bodyHeight + 12)
          ..lineTo(cx + 12, bodyHeight - 1)
          ..close();
        break;
      case BubbleTail.left:
        final cy = size.height * 0.62;
        path
          ..moveTo(bodyLeft + 1, cy - 10)
          ..lineTo(bodyLeft - 10, cy)
          ..lineTo(bodyLeft + 1, cy + 10)
          ..close();
        break;
      case BubbleTail.none:
        break;
    }

    canvas.drawShadow(path, WithMeColors.creamShadow, 5, true);
    canvas.drawPath(path, Paint()..color = WithMeColors.creamLight);
    canvas.drawPath(
      path,
      Paint()
        ..color = WithMeColors.lei.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => old.tail != tail;
}
