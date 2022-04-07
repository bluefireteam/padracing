import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

List<Wall> createBoundaries(Vector2 size) {
  final topLeft = Vector2.zero();
  final bottomRight = size;
  final topRight = Vector2(bottomRight.x, topLeft.y);
  final bottomLeft = Vector2(topLeft.x, bottomRight.y);

  return [
    Wall(topLeft, topRight),
    Wall(topRight, bottomRight),
    Wall(bottomRight, bottomLeft),
    Wall(bottomLeft, topLeft),
  ];
}

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    paint.color = Colors.black;

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.5
      ..friction = 0.3;

    final bodyDef = BodyDef()
      ..userData = this // To be able to determine object in collision
      ..position = Vector2.zero()
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
