import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';

import 'background.dart';
import 'ball.dart';
import 'car.dart';
import 'ground_sensor.dart';
import 'wall.dart';

/// Change this to 2 if you want to play multiplayer.
const numberOfPlayers = 1;

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
  PadRacingGame() : super(gravity: Vector2.zero(), zoom: 1);

  @override
  Color backgroundColor() => Colors.grey.shade900;

  static Vector2 trackSize = Vector2.all(500);
  late final World cameraWorld;
  late final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late final List<Set<LogicalKeyboardKey>> pressedKeySets;

  @override
  Future<void> onLoad() async {
    children.query();
    cameraWorld = World();
    await add(cameraWorld);
    final viewportSize = Vector2(canvasSize.x / numberOfPlayers, canvasSize.y);
    RectangleComponent viewportRimGenerator() =>
        RectangleComponent(size: viewportSize, anchor: Anchor.center)
          ..paint.color = Colors.blue
          ..paint.strokeWidth = 2.0
          ..paint.style = PaintingStyle.stroke;
    final cameras = List.generate(
      numberOfPlayers,
      (i) => CameraComponent(
        world: cameraWorld,
        viewport: FixedSizeViewport(viewportSize.x, viewportSize.y)
          ..position = Vector2(
            (canvasSize.x / numberOfPlayers) * (i + 0.5),
            canvasSize.y / 2,
          )
          ..add(viewportRimGenerator()),
      )
        ..viewfinder.anchor = Anchor.center
        ..viewfinder.zoom = 10,
    );
    await addAll(cameras);
    cameraWorld.add(Background());
    cameraWorld.add(GroundSensor(Vector2(25, 50), Vector2(50, 5), true));
    cameraWorld.add(GroundSensor(Vector2(25, 70), Vector2(50, 5), true));
    cameraWorld.add(GroundSensor(Vector2(52.5, 25), Vector2(5, 50), false));
    cameraWorld.addAll(createWalls(trackSize));
    for (var i = 0; i < numberOfPlayers; i++) {
      cameraWorld.add(Car(playerNumber: i, cameraComponent: cameras[i]));
    }
    cameraWorld.add(Ball());

    pressedKeySets = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
    addContactCallback(CarContactCallback());
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (!isLoaded) {
      return KeyEventResult.ignored;
    }

    for (final pressedKeySet in pressedKeySets) {
      pressedKeySet.clear();
    }
    for (final key in keysPressed) {
      activeKeyMaps.forEachIndexed((i, keyMap) {
        if (keyMap.containsKey(key)) {
          pressedKeySets[i].add(keyMap[key]!);
        }
      });
    }
    return KeyEventResult.handled;
  }
}
