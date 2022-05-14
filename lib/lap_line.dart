import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;

import 'car.dart';
import 'game_colors.dart';

class LapLine extends BodyComponent {
  LapLine(this.id, this.position, this.size, this.isFinish)
      : super(priority: 1);

  final int id;
  final bool isFinish;
  final Vector2 position;
  final Vector2 size;
  late final Rect rect = size.toRect();
  Image? _finishOverlay;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (isFinish) {
      _finishOverlay = await createFinishOverlay();
    }
  }

  @override
  Body createBody() {
    paint.color = (isFinish ? GameColors.green.color : GameColors.green.color)
      ..withOpacity(0.5);
    paint
      ..style = PaintingStyle.fill
      ..shader = Gradient.radial(
        (size / 2).toOffset(),
        max(size.x, size.y),
        [
          paint.color,
          Colors.black,
        ],
      );

    final groundBody = world.createBody(
      BodyDef(
        position: position,
        userData: this,
      ),
    );
    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape, isSensor: true);
    return groundBody..createFixture(fixtureDef);
  }

  late final Rect _scaledRect = (size * 10).toRect();
  late final Rect _drawRect = size.toRect();

  Future<Image> createFinishOverlay() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final step = _scaledRect.width / 2;
    final black = BasicPalette.black.paint();

    for (var i = 0; i * step < _scaledRect.height; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i.isEven ? 0 : step, i * step, step, step),
        black,
      );
    }
    final picture = recorder.endRecording();
    return picture.toImage(
      _scaledRect.width.toInt(),
      _scaledRect.height.toInt(),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(-size.x / 2, -size.y / 2);
    canvas.drawRect(rect, paint);
    if (_finishOverlay != null) {
      canvas.drawImageRect(_finishOverlay!, _scaledRect, _drawRect, paint);
    }
  }
}

class CarLapContactCallback extends ContactCallback<Car, LapLine> {
  @override
  void begin(Car car, LapLine groundSensor, Contact contact) {
    if (groundSensor.isFinish && car.passedStartControl.length == 2) {
      car.lapNotifier.value++;
      car.passedStartControl.clear();
    } else if (!groundSensor.isFinish) {
      car.passedStartControl
          .removeWhere((passedControl) => passedControl.id > groundSensor.id);
      car.passedStartControl.add(groundSensor);
    }
  }
}
