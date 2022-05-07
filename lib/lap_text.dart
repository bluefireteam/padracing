import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';

import 'game.dart';
import 'game_colors.dart';

class LapText extends PositionComponent with HasGameRef<PadRacingGame> {
  LapText({required this.lapNotifier, required Vector2 position})
      : super(position: position);

  final ValueNotifier<int> lapNotifier;
  late final TextComponent _timePassedComponent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final textStyle = GoogleFonts.vt323(
      fontSize: 35,
      color: GameColors.green.color,
    );
    final defaultRenderer = TextPaint(style: textStyle);
    final lapCountRenderer = TextPaint(
      style: textStyle.copyWith(fontSize: 55, fontWeight: FontWeight.bold),
    );
    add(
      TextComponent(
        text: 'Lap',
        position: Vector2(0, -20),
        anchor: Anchor.center,
        textRenderer: defaultRenderer,
      ),
    );
    final lapCounter = TextComponent(
      position: Vector2(0, 10),
      anchor: Anchor.center,
      textRenderer: lapCountRenderer,
    );
    add(lapCounter);
    void updateLapText() {
      if (lapNotifier.value <= PadRacingGame.numberOfLaps) {
        final prefix = lapNotifier.value < 10 ? '0' : '';
        lapCounter.text = '$prefix${lapNotifier.value}';
      } else {
        lapCounter.text = 'DONE';
      }
    }

    _timePassedComponent = TextComponent(
      position: Vector2(0, 70),
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(_timePassedComponent);

    lapNotifier.addListener(updateLapText);
    updateLapText();
  }

  @override
  void update(double dt) {
    if (gameRef.isGameOver) {
      return;
    }
    _timePassedComponent.text = gameRef.timePassed;
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
