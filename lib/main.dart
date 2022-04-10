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
  runApp(GameWidget(game: WrapperGame()));
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

class WrapperGame extends FlameGame with KeyboardEvents {
  late final PadRacingGame game;

  @override
  Future<void> onLoad() async {
    const numberOfPlayers = PadRacingGame.numberOfPlayers;
    final world = World();
    await add(world);
    final viewportSize = Vector2(canvasSize.x / numberOfPlayers, canvasSize.y);
    RectangleComponent viewportRimGenerator() =>
        RectangleComponent(size: viewportSize, anchor: Anchor.center)
          ..paint.color = Colors.red
          ..paint.strokeWidth = 2.0
          ..paint.style = PaintingStyle.stroke;
    final cameras = List.generate(
      numberOfPlayers,
      (i) => CameraComponent(
        world: world,
        viewport: FixedSizeViewport(viewportSize.x, viewportSize.y)
          ..position = Vector2(
            (canvasSize.x / numberOfPlayers) * (i + 0.5),
            canvasSize.y / 2,
          )
          ..add(viewportRimGenerator()),
      )
        ..viewfinder.anchor = Anchor.center
        //..viewfinder.visibleGameSize = PadRacingGame.trackSize
        ..viewfinder.zoom = 10,
    );
    await addAll(cameras);
    world.add(game = PadRacingGame(cameras));
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (!game.isLoaded) {
      return KeyEventResult.ignored;
    }

    game.pressedKeys.forEach((e) => e.clear());
    keysPressed.forEach((LogicalKeyboardKey key) {
      game.activeKeyMaps.forEachIndexed((i, keyMap) {
        if (keyMap.containsKey(key)) {
          game.pressedKeys[i].add(keyMap[key]!);
        }
      });
    });
    return KeyEventResult.handled;
  }
}

class PadRacingGame extends Forge2DGame with KeyboardEvents {
  PadRacingGame(this.cameras) : super(gravity: Vector2.zero(), zoom: 1);

  static const numberOfPlayers = 2;
  static Vector2 trackSize = Vector2.all(500);
  final List<CameraComponent> cameras;
  late final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late final List<Set<LogicalKeyboardKey>> pressedKeys;

  @override
  Future<void> onLoad() async {
    pressedKeys = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
    add(Background());
    addAll(createWalls(trackSize));
    for (var i = 0; i < numberOfPlayers; i++) {
      add(Car(playerNumber: i, cameraComponent: cameras[i]));
    }
    add(Ball());
  }
}
