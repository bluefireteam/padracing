import 'package:collection/collection.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'background.dart';
import 'ball.dart';
import 'boundaries.dart';
import 'car.dart';
import 'house.dart';

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
  PadRacingGame() : super(gravity: Vector2.zero(), zoom: 10);

  final Vector2 trackSize = Vector2.all(500);
  int numberOfPlayers = 2;
  late final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late final List<Set<LogicalKeyboardKey>> pressedKeys;

  @override
  Future<void> onLoad() async {
    pressedKeys = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
    add(Background());
    addAll(createBoundaries(trackSize));
    add(Ball());
    add(House(Vector2(52.5, 240), Vector2(5, 380)));
    add(House(Vector2(200, 50), Vector2(300, 5)));
    add(House(Vector2(72.5, 300), Vector2(5, 400)));
    add(House(Vector2(180, 100), Vector2(220, 5)));
    add(House(Vector2(350, 105), Vector2(5, 115)));
    add(House(Vector2(350, 312.5), Vector2(5, 180)));
    add(House(Vector2(310, 160), Vector2(240, 5)));
    add(House(Vector2(210, 400), Vector2(280, 5)));
    add(House(Vector2(430, 302.5), Vector2(5, 290)));
    add(House(Vector2(292.5, 450), Vector2(280, 5)));
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
