import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';

import 'game_colors.dart';

class LapText extends PositionComponent {
  LapText({required this.lapNotifier, required Vector2 position})
      : super(position: position);

  final ValueNotifier<int> lapNotifier;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final textStyle = GoogleFonts.vt323(
      fontSize: 35,
      color: GameColors.green.color,
    );
    final lapLabelRenderer = TextPaint(style: textStyle);
    final lapCountRenderer = TextPaint(
      style: textStyle.copyWith(fontSize: 55, fontWeight: FontWeight.bold),
    );
    add(
      TextComponent(
        text: 'Lap',
        position: Vector2(0, -20),
        anchor: Anchor.center,
        textRenderer: lapLabelRenderer,
      ),
    );
    final lapCounter = TextComponent(
      position: Vector2(0, 10),
      anchor: Anchor.center,
      textRenderer: lapCountRenderer,
    );
    add(lapCounter);
    void updateLapText() {
      final prefix = lapNotifier.value < 10 ? '0' : '';
      lapCounter.text = '$prefix${lapNotifier.value}';
    }

    lapNotifier.addListener(updateLapText);
    updateLapText();
  }

  final _backgroundRect = RRect.fromRectAndRadius(
    Rect.fromCircle(center: Offset.zero, radius: 50),
    const Radius.circular(10),
  );
  final _backgroundPaint = GameColors.green.paint
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_backgroundRect, _backgroundPaint);
  }
}
