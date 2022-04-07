import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/src/dynamics/body.dart';

import 'main.dart';

class House extends BodyComponent<PadRacingGame> {
  House(this.position, this.size) : super(priority: 3);

  final Vector2 position;
  final Vector2 size;
  late final sizeRect = size.toRect();

  final Random rng = Random();
  late final Image _image;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint..color = Colors.green;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, size.toRect());

    for (var x = 0.0; x < size.x; x += 0.2) {
      for (var y = 0.0; y < size.y; y += 0.2) {
        paint..color = paint.color.darken(rng.nextDouble() / 20);
        paint..color = paint.color.brighten(rng.nextDouble() / 20);
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
