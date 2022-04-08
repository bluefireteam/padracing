import 'package:collection/collection.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
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

  final Vector2 trackSize = Vector2.all(500);
  int numberOfPlayers = 2;
  late final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late final List<Set<LogicalKeyboardKey>> pressedKeys;

  @override
  Future<void> onLoad() async {
    pressedKeys = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
    add(Background());
    addAll(createWalls(trackSize));
    add(Ball());
    for (var i = 0; i < numberOfPlayers; i++) {
      add(Car(playerNumber: i));
    }
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
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
