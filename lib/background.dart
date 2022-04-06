import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image;

class Background extends PositionComponent with HasGameRef, HasPaint {
  Background() : super(priority: -2);

  final Random rng = Random(1337);
  late final Image _image;

  @override
  Future<void> onLoad() async {
    paint..color = Colors.green;
    final gameSize = gameRef.camera.gameSize;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, gameSize.toRect());
    final colors = [
      Colors.green.withAlpha(100),
      Colors.brown.withAlpha(100),
      Colors.lightGreen.withAlpha(100),
    ];

    for (var x = 0.0; x < gameSize.x; x += 0.2) {
      for (var y = 0.0; y < gameSize.y; y += 0.2) {
        paint
          ..color = (colors..shuffle(rng)).first
          ..darken(rng.nextDouble());
        //paint..color = paint.color.darken(rng.nextDouble() / 20);
        //paint..color = paint.color.brighten(rng.nextDouble() / 20);
        canvas.drawCircle(Offset(x, y), 0.2, paint);
      }
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(gameSize.x.toInt(), gameSize.y.toInt());
  }

  final _whitePaint = Paint();

  @override
  void render(Canvas canvas) {
    canvas.drawImage(_image, Offset.zero, _whitePaint);
  }
}
