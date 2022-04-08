import 'package:flame/extensions.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';

import 'main.dart';

class Ball extends BodyComponent<PadRacingGame> {
  static const radius = 80.0;

  @override
  Body createBody() {
    paint..color = Colors.amber;
    final startPosition = Vector2(200, 245);
    final def = BodyDef()
      ..type = BodyType.kinematic
      ..position = startPosition;
    final body = world.createBody(def)
      ..userData = this
      ..angularVelocity = 30
      ..angularDamping = 0.0;

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)..restitution = 0.5;
    return body..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.drawCircle(Offset(radius / 2, radius / 2), radius / 10,
        Paint()..color = Colors.black);
  }
}
