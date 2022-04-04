import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'car.dart';

void main() {
  runApp(GameWidget(game: PadRacingGame()));
}

final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> playersKeys = [
  {
    LogicalKeyboardKey.arrowUp: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight: LogicalKeyboardKey.arrowRight,
  },
  {
    LogicalKeyboardKey.keyW: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.keyS: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.keyA: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.keyD: LogicalKeyboardKey.arrowRight,
  },
];

class PadRacingGame extends Forge2DGame with KeyboardEvents {
  PadRacingGame() : super(gravity: Vector2.zero());

  int numberOfPlayers = 2;
  late final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late final List<Set<LogicalKeyboardKey>> pressedKeys;

  @override
  Future<void> onLoad() async {
    pressedKeys = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
    final worldCenter = screenToWorld(size * camera.zoom / 2);
    final blobCenter = worldCenter + Vector2(0, -30);
    final blobRadius = Vector2.all(6.0);
    final jointDef = ConstantVolumeJointDef()
      ..frequencyHz = 20.0
      ..dampingRatio = 1.0
      ..collideConnected = false;

    await addAll(
      List.generate(20, (i) => BlobPart(i, jointDef, blobRadius, blobCenter)),
    );
    for (var i = 0; i < numberOfPlayers; i++) {
      add(Car(playerNumber: i));
    }
    world.createJoint(ConstantVolumeJoint(world, jointDef));
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    // TODO: Add support for second player
    pressedKeys.forEach((e) => e.clear());
    keysPressed.forEach((LogicalKeyboardKey key) {
      activeKeyMaps.forEachIndexed((i, keyMap) {
        if (keyMap.containsKey(key)) {
          pressedKeys[i].add(keyMap[key]!);
        }
      });
    });

    return KeyEventResult.handled;
  }
}

class BlobPart extends BodyComponent {
  final ConstantVolumeJointDef jointDef;
  final int bodyNumber;
  final Vector2 blobRadius;
  final Vector2 blobCenter;

  BlobPart(
    this.bodyNumber,
    this.jointDef,
    this.blobRadius,
    this.blobCenter,
  );

  @override
  Body createBody() {
    const nBodies = 20.0;
    const bodyRadius = 0.5;
    final angle = (bodyNumber / nBodies) * pi * 2;
    final rng = Random();
    final x = blobCenter.x + blobRadius.x * sin(angle) + rng.nextDouble();
    final y = blobCenter.y + blobRadius.y * cos(angle) + rng.nextDouble();

    final bodyDef = BodyDef()
      ..fixedRotation = true
      ..position.setValues(x, y)
      ..type = BodyType.dynamic;
    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = bodyRadius;
    final fixtureDef = FixtureDef(shape)..density = 1.0;
    body.createFixture(fixtureDef);
    jointDef.addBody(body);
    return body;
  }
}
