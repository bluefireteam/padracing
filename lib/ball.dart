import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image;

import 'main.dart';

class Ball extends BodyComponent<PadRacingGame> {
  static const radius = 80.0;
  final Random rng = Random();
  late final Image _image;
  late final Path _clipPath;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    final trackSize = PadRacingGame.trackSize;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, trackSize.toRect());
    final colors = [
      Colors.lightBlue,
      Colors.blue,
      Colors.deepPurpleAccent,
    ];
    _clipPath = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.translate(radius, radius);

    for (var angle = 0.0; angle < 2 * pi; angle += 0.05) {
      canvas.rotate(0.05);
      for (var x = radius; x > 0; x -= 0.2) {
        paint
          ..color = (colors..shuffle(rng)).first
          ..darken(x / radius);
        canvas.drawCircle(Offset(x, 0), 3, paint);
      }
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage((radius * 2).toInt(), (radius * 2).toInt());
    //gameRef.camera.followBodyComponent(this);
  }

  @override
  Body createBody() {
    paint..color = Colors.amber;
    final startPosition = Vector2(200, 245);
    final def = BodyDef()
      ..type = BodyType.kinematic
      ..position = startPosition;
    final body = world.createBody(def)..angularVelocity = 1;

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.5
      ..friction = 0.5;
    return body..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    canvas.clipPath(_clipPath);
    canvas.translate(-radius, -radius);
    canvas.drawImage(_image, Offset.zero, paint);
  }
}
