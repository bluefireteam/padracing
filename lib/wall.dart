import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image;

import 'main.dart';

List<Wall> createWalls(Vector2 size) {
  final topCenter = Vector2(size.x / 2, 0);
  final bottomCenter = Vector2(size.x / 2, size.y);
  final leftCenter = Vector2(0, size.y / 2);
  final rightCenter = Vector2(size.x, size.y / 2);

  final filledSize = size.clone() + Vector2.all(5);
  return [
    Wall(topCenter, Vector2(filledSize.x, 5)),
    Wall(bottomCenter, Vector2(filledSize.y, 5)),
    Wall(leftCenter, Vector2(5, filledSize.y)),
    Wall(rightCenter, Vector2(5, filledSize.y)),
    Wall(Vector2(52.5, 240), Vector2(5, 380)),
    Wall(Vector2(200, 50), Vector2(300, 5)),
    Wall(Vector2(72.5, 300), Vector2(5, 400)),
    Wall(Vector2(180, 100), Vector2(220, 5)),
    Wall(Vector2(350, 105), Vector2(5, 115)),
    Wall(Vector2(350, 312.5), Vector2(5, 180)),
    Wall(Vector2(310, 160), Vector2(240, 5)),
    Wall(Vector2(210, 400), Vector2(280, 5)),
    Wall(Vector2(430, 302.5), Vector2(5, 290)),
    Wall(Vector2(292.5, 450), Vector2(280, 5)),
  ];
}

class Wall extends BodyComponent<PadRacingGame> {
  Wall(this.position, this.size) : super(priority: 3);

  final Vector2 position;
  final Vector2 size;
  late final sizeRect = size.toRect();

  final Random rng = Random();
  late final Image _image;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint.color = Colors.green;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, size.toRect());

    for (var x = 0.0; x < size.x; x += 0.2) {
      for (var y = 0.0; y < size.y; y += 0.2) {
        paint.color = paint.color.darken(rng.nextDouble() / 20);
        paint.color = paint.color.brighten(rng.nextDouble() / 20);
        canvas.drawCircle(Offset(x, y), 0.2, paint);
      }
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(size.x.toInt(), size.y.toInt());
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(-size.x / 2, -size.y / 2);
    canvas.drawImageRect(
      _image,
      sizeRect,
      sizeRect,
      //position.toPositionedRect(size),
      paint,
    );
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.static
      ..position = position;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape)..restitution = 0.5;
    return body..createFixture(fixtureDef);
  }
}
