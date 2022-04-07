import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image;

import 'main.dart';

class Background extends PositionComponent
    with HasGameRef<PadRacingGame>, HasPaint {
  Background() : super(priority: 0);

  final Random rng = Random(1337);
  late final Image _image;

  @override
  Future<void> onLoad() async {
    final trackSize = gameRef.trackSize;
    paint..color = Colors.green;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, trackSize.toRect());
    final colors = [
      Colors.green.withAlpha(100),
      Colors.brown.withAlpha(100),
      Colors.lightGreen.withAlpha(100),
    ];

    for (var x = 0.0; x < trackSize.x; x += 0.2) {
      for (var y = 0.0; y < trackSize.y; y += 0.2) {
        paint
          ..color = (colors..shuffle(rng)).first
          ..darken(rng.nextDouble());
        canvas.drawCircle(Offset(x, y), 0.3, paint);
      }
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(trackSize.x.toInt(), trackSize.y.toInt());
  }

  final _whitePaint = Paint();

  @override
  void render(Canvas canvas) {
    canvas.drawImage(_image, Offset.zero, _whitePaint);
  }
}
