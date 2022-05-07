import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';

import 'car.dart';
import 'game.dart';
import 'trail.dart';

class Tire extends BodyComponent<PadRacingGame> {
  Tire(
    this.car,
    this.color,
    this.pressedKeys,
    this._maxDriveForce,
    this._maxLateralImpulse,
    this.jointDef,
    this.jointAnchor, {
    this.isTurnableTire = false,
  }) : super(
          paint: Paint()
            ..color = color
            ..strokeWidth = 0.2
            ..style = PaintingStyle.stroke,
          priority: 2,
        );

  final Car car;
  final size = Vector2(0.5, 1.25);
  late final RRect _renderRect = RRect.fromLTRBR(
    -size.x,
    -size.y,
    size.x,
    size.y,
    const Radius.circular(0.3),
  );

  final Set<LogicalKeyboardKey> pressedKeys;
  final double _maxDriveForce;
  final double _maxLateralImpulse;
  // Make mutable if ice or something should be implemented
  final double _currentTraction = 1.0;

  final double _maxForwardSpeed = 250.0;
  final double _maxBackwardSpeed = -40.0;

  final RevoluteJointDef jointDef;
  late final RevoluteJoint joint;
  final Vector2 jointAnchor;
  final bool isTurnableTire;

  final double _lockAngle = 0.6;
  final double _turnSpeedPerSecond = 4;

  final random = Random();
  final Tween<double> noise = Tween(begin: -1, end: 1);
  late final List<Paint> particlePaints;
  final Color color;
  late final ColorTween colorTween = ColorTween(
    begin: color,
    end: Colors.black,
  );
  final Paint _black = BasicPalette.black.paint();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameRef.cameraWorld.add(Trail(car: car, tire: this));
  }

  @override
  Body createBody() {
    final def = BodyDef()..type = BodyType.dynamic;
    final body = world.createBody(def)..userData = this;

    final polygonShape = PolygonShape();
    polygonShape.setAsBoxXY(0.5, 1.25);
    final fixture = body.createFixtureFromShape(polygonShape, 1.0);
    fixture.userData = this;

    jointDef.bodyB = body;
    jointDef.localAnchorA.setFrom(jointAnchor);
    world.createJoint(joint = RevoluteJoint(jointDef));
    joint.setLimits(0, 0);
    return body;
  }

  @override
  void update(double dt) {
    if (body.isAwake || pressedKeys.isNotEmpty) {
      _updateTurn(dt);
      _updateFriction();
      _updateDrive();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_renderRect, _black);
    canvas.drawRRect(_renderRect, paint);
  }

  void _updateFriction() {
    final impulse = _lateralVelocity
      ..scale(-body.mass)
      ..clampScalar(-_maxLateralImpulse, _maxLateralImpulse)
      ..scale(_currentTraction);
    body.applyLinearImpulse(impulse);
    body.applyAngularImpulse(
      0.1 * _currentTraction * body.getInertia() * -body.angularVelocity,
    );

    final currentForwardNormal = _forwardVelocity;
    final currentForwardSpeed = currentForwardNormal.length;
    currentForwardNormal.normalize();
    final dragForceMagnitude = -2 * currentForwardSpeed;
    body.applyForce(
      currentForwardNormal..scale(_currentTraction * dragForceMagnitude),
    );
  }

  void _updateDrive() {
    var desiredSpeed = 0.0;
    if (pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      desiredSpeed = _maxForwardSpeed;
    }
    if (pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      desiredSpeed += _maxBackwardSpeed;
    }

    final currentForwardNormal = body.worldVector(Vector2(0.0, 1.0));
    final currentSpeed = _forwardVelocity.dot(currentForwardNormal);
    var force = 0.0;
    if (desiredSpeed < currentSpeed) {
      force = -_maxDriveForce;
    } else if (desiredSpeed > currentSpeed) {
      force = _maxDriveForce;
    }

    if (force.abs() > 0) {
      body.applyForce(currentForwardNormal..scale(_currentTraction * force));
    }
  }

  void _updateTurn(double dt) {
    var desiredAngle = 0.0;
    var desiredTorque = 0.0;
    var isTurning = false;
    if (pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      desiredTorque = -15.0;
      desiredAngle = -_lockAngle;
      isTurning = true;
    }
    if (pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      desiredTorque += 15.0;
      desiredAngle += _lockAngle;
      isTurning = true;
    }
    if (isTurnableTire && isTurning) {
      final turnPerTimeStep = _turnSpeedPerSecond * dt;
      final angleNow = joint.jointAngle();
      final angleToTurn = (desiredAngle - angleNow)
          .clamp(-turnPerTimeStep, turnPerTimeStep)
          .toDouble();
      final angle = angleNow + angleToTurn;
      joint.setLimits(angle, angle);
    } else {
      joint.setLimits(0, 0);
    }
    body.applyTorque(desiredTorque);
  }

  // Cached Vectors to reduce unnecessary object creation.
  final Vector2 _worldLeft = Vector2(1.0, 0.0);
  final Vector2 _worldUp = Vector2(0.0, -1.0);

  Vector2 get _lateralVelocity {
    final currentRightNormal = body.worldVector(_worldLeft);
    return currentRightNormal
      ..scale(currentRightNormal.dot(body.linearVelocity));
  }

  Vector2 get _forwardVelocity {
    final currentForwardNormal = body.worldVector(_worldUp);
    return currentForwardNormal
      ..scale(currentForwardNormal.dot(body.linearVelocity));
  }
}
