import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'main.dart';
import 'tire.dart';

class Car extends BodyComponent<PadRacingGame> {
  Car({required this.playerNumber}) : super(priority: 2);

  final int playerNumber;
  final double _backTireMaxDriveForce = 300.0;
  final double _frontTireMaxDriveForce = 500.0;
  final double _backTireMaxLateralImpulse = 8.5;
  final double _frontTireMaxLateralImpulse = 7.5;

  @override
  Body createBody() {
    paint..color = ColorExtension.random();
    final startPosition =
        Vector2.all(50) + Vector2.all(50) * playerNumber.toDouble();
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = startPosition;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final vertices = <Vector2>[
      Vector2(1.5, 0.0),
      Vector2(3.0, 2.5),
      Vector2(2.8, 5.5),
      Vector2(1.0, 10.0),
      Vector2(-1.0, 10.0),
      Vector2(-2.8, 5.5),
      Vector2(-3.0, 2.5),
      Vector2(-1.5, 0.0),
    ];

    final shape = PolygonShape()..set(vertices);
    final fixtureDef = FixtureDef(shape)
      ..density = 0.2
      ..restitution = 2.0;
    body.createFixture(fixtureDef);

    final jointDef = RevoluteJointDef();
    jointDef.bodyA = body;
    jointDef.enableLimit = true;
    jointDef.lowerAngle = 0.0;
    jointDef.upperAngle = 0.0;
    jointDef.localAnchorB.setZero();

    final tires = List.generate(4, (i) {
      final isFrontTire = i <= 1;
      final isLeftTire = i.isEven;
      return Tire(
        gameRef.pressedKeys[playerNumber],
        isFrontTire ? _frontTireMaxDriveForce : _backTireMaxDriveForce,
        isFrontTire ? _frontTireMaxLateralImpulse : _backTireMaxLateralImpulse,
        jointDef,
        isFrontTire
            ? Vector2(isLeftTire ? -3.0 : 3.0, 8.5)
            : Vector2(isLeftTire ? -3.0 : 3.0, 0.75),
        isTurnableTire: isFrontTire,
      );
    });

    gameRef.addAll(tires);
    return body;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gameRef.camera.followBodyComponent(this);
  }
}
