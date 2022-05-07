import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;

import 'game.dart';
import 'game_colors.dart';

class Ball extends BodyComponent<PadRacingGame> {
  static const radius = 80.0;
  final Vector2 position = Vector2(200, 245);
  final Random rng = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.kinematic
      ..position = position;
    final body = world.createBody(def)..angularVelocity = 1;

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.5
      ..friction = 0.5;
    return body..createFixture(fixtureDef);
  }

  final _shaderPaint = GameColors.green.paint
    ..shader = Gradient.radial(
      Offset.zero,
      radius,
      [
        GameColors.green.color,
        BasicPalette.black.color,
      ],
      null,
      TileMode.clamp,
      null,
      const Offset(radius / 2, radius / 2),
    );

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, _shaderPaint);
  }
}
