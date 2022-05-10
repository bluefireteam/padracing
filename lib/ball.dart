import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:padracing/wall.dart';

import 'car.dart';
import 'game.dart';
import 'game_colors.dart';

class Ball extends BodyComponent<PadRacingGame> {
  final double radius;
  final Vector2 position;
  final double rotation;
  final bool isSensor;
  final Random rng = Random();
  late final Paint _shaderPaint;

  Ball({
    required this.position,
    this.radius = 80.0,
    this.rotation = 1.0,
    this.isSensor = true,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    _shaderPaint = GameColors.green.paint
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
        Offset(radius / 2, radius / 2),
      );
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..userData = this
      ..type = BodyType.kinematic
      ..position = position;
    final body = world.createBody(def)..angularVelocity = rotation;

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..isSensor = isSensor
      ..restitution = 0.5
      ..friction = 0.5;
    return body..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, _shaderPaint);
  }

  late Rect asRect = Rect.fromCircle(
    center: position.toOffset(),
    radius: radius,
  );
}

List<Ball> createBalls(Vector2 trackSize, List<Wall> walls, Ball bigBall) {
  final balls = <Ball>[];
  final rng = Random();
  while (balls.length < 20) {
    final ball = Ball(
      position: Vector2.random(rng)..multiply(trackSize),
      radius: 3.0 + rng.nextInt(5),
      rotation: (rng.nextBool() ? 1 : -1) * rng.nextInt(5).toDouble(),
    );
    final touchesBall = ball.position.distanceTo(bigBall.position) <
        ball.radius + bigBall.radius;
    if (!touchesBall) {
      final touchesWall =
          walls.any((wall) => wall.asRect.overlaps(ball.asRect));
      if (!touchesWall) {
        balls.add(ball);
      }
    }
  }
  return balls;
}

class CarBallContactCallback extends ContactCallback<Car, Ball> {
  @override
  void begin(Car car, Ball ball, Contact contact) {
    if (ball.isSensor) {
      ball.removeFromParent();
    }
    final body = car.body;
    body.applyAngularImpulse(3 * body.mass * 100);
  }
}
