import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;

import 'car.dart';
import 'game_colors.dart';

class GroundSensor extends BodyComponent {
  GroundSensor(this.id, this.position, this.size, this.isFinish)
      : super(priority: 1);

  final int id;
  final bool isFinish;
  final Vector2 position;
  final Vector2 size;
  late final Rect rect = size.toRect();

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

  @override
  void render(Canvas canvas) {
    canvas.translate(-size.x / 2, -size.y / 2);
    canvas.drawRect(
      rect,
      paint,
    );
  }
}

class CarContactCallback extends ContactCallback<Car, GroundSensor> {
  @override
  void begin(Car car, GroundSensor groundSensor, Contact contact) {
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
