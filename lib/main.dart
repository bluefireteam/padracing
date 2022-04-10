import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'background.dart';
import 'ball.dart';
import 'car.dart';
import 'wall.dart';

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

  static const numberOfPlayers = 2;
  static Vector2 trackSize = Vector2.all(500);
  late final World cameraWorld;
  late final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late final List<Set<LogicalKeyboardKey>> pressedKeys;

  @override
  Future<void> onLoad() async {
    const numberOfPlayers = PadRacingGame.numberOfPlayers;
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
    //add(Background());
    cameraWorld.addAll(createWalls(trackSize));
    for (var i = 0; i < numberOfPlayers; i++) {
      cameraWorld.add(Car(playerNumber: i, cameraComponent: cameras[i]));
    }
    cameraWorld.add(Ball());

    pressedKeys = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
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
