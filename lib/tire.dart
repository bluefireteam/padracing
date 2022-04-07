import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forge2d/forge2d.dart' hide Particle;

import 'ground_area.dart';
import 'main.dart';

class Tire extends BodyComponent<PadRacingGame> {
  Tire(
    this.pressedKeys,
    this._maxDriveForce,
    this._maxLateralImpulse,
    this.jointDef,
    this.jointAnchor, {
    this.isTurnableTire = false,
  }) : super(paint: Paint()..color = Colors.grey.shade700, priority: 2);

  final Set<LogicalKeyboardKey> pressedKeys;
  final double _maxDriveForce;
  final double _maxLateralImpulse;
  double _currentTraction = 0.0;
  final Set<GroundArea> _groundAreas = <GroundArea>{};

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
  final ColorTween colorTween = ColorTween(
    begin: Colors.brown,
    end: Colors.black,
  );

  @override
  Body createBody() {
    final def = BodyDef()..type = BodyType.dynamic;
    final body = world.createBody(def)..userData = this;

    final polygonShape = PolygonShape();
    polygonShape.setAsBoxXY(0.5, 1.25);
    final fixture = body.createFixtureFromShape(polygonShape, 1.0);
    fixture.userData = this;

    _currentTraction = 1.0;

    jointDef.bodyB = body;
    jointDef.localAnchorA.setFrom(jointAnchor);
    world.createJoint(joint = RevoluteJoint(jointDef));
    joint.setLimits(0, 0);
    return body;
  }

  @override
  void update(double dt) {
    if (body.isAwake || pressedKeys.isNotEmpty) {
      body.setAwake(true);
      _updateTurn(dt);
      _updateFriction();
      _updateDrive();
      if (body.linearVelocity.length2 > 100) {
        gameRef.add(
          ParticleSystemComponent(
            position: body.position,
            particle: Particle.generate(
              count: 8,
              generator: (i) {
                return AcceleratedParticle(
                  lifespan: 2,
                  speed: Vector2(
                        noise.transform(random.nextDouble()),
                        noise.transform(random.nextDouble()),
                      ) *
                      i.toDouble(),
                  child: CircleParticle(
                    radius: 0.2,
                    paint: Paint()
                      ..color = colorTween.transform(random.nextDouble())!,
                  ),
                );
              },
            ),
            priority: 1,
          ),
        );
      }
    }
  }

  void _updateFriction() {
    final impulse = _lateralVelocity..scale(-body.mass);
    if (impulse.length > _maxLateralImpulse) {
      impulse.scale(_maxLateralImpulse / impulse.length);
    }
    body.applyLinearImpulse(impulse..scale(_currentTraction));
    body.applyAngularImpulse(
      0.1 * _currentTraction * body.getInertia() * (-body.angularVelocity),
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

  void _updateTraction() {
    if (_groundAreas.isEmpty) {
      _currentTraction = 1.0;
    } else {
      _currentTraction = 0.0;
      _groundAreas.forEach((element) {
        _currentTraction = max(_currentTraction, element.frictionModifier);
      });
    }
  }

  void addGroundArea(GroundArea groundArea) {
    final newlyAdded = _groundAreas.add(groundArea);
    if (newlyAdded) {
      _updateTraction();
    }
  }

  void removeGroundArea(GroundArea ga) {
    if (_groundAreas.remove(ga)) {
      _updateTraction();
    }
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
