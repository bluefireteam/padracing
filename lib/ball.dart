import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';

import 'main.dart';

class Ball extends BodyComponent<PadRacingGame> {
  @override
  Body createBody() {
    paint..color = Colors.amber;
    final startPosition = gameRef.camera.gameSize / 2;
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = startPosition;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shape = CircleShape()..radius = 3.0;
    final fixtureDef = FixtureDef(shape)..restitution = 0.5;
    return body..createFixture(fixtureDef);
  }
}
