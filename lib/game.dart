import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';

import 'background.dart';
import 'ball.dart';
import 'car.dart';
import 'game_colors.dart';
import 'ground_line.dart';
import 'lap_text.dart';
import 'wall.dart';

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

class PadRacingGame extends Forge2DGame with KeyboardEvents, FPSCounter {
  PadRacingGame() : super(gravity: Vector2.zero(), zoom: 1);

  @override
  Color backgroundColor() => Colors.black;

  static Vector2 trackSize = Vector2.all(500);
  static double playZoom = 8.0;
  static const int numberOfLaps = 1;
  late final World cameraWorld;
  late CameraComponent startCamera;
  late List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late List<Set<LogicalKeyboardKey>> pressedKeySets;
  late final TextComponent fpsText;
  final cars = <Car>[];
  bool isGameOver = false;
  Car? winner;
  double _timePassed = 0;

  @override
  Future<void> onLoad() async {
    children.register<CameraComponent>();
    fpsText =
        TextComponent(position: Vector2(20, canvasSize.y - 40), priority: 5);
    cameraWorld = World();
    add(cameraWorld);

    cameraWorld.addAll([
      Background(),
      GroundLine(1, Vector2(25, 50), Vector2(50, 5), false),
      GroundLine(2, Vector2(25, 70), Vector2(50, 5), false),
      GroundLine(3, Vector2(52.5, 25), Vector2(5, 50), true),
      Ball(),
      ...createWalls(trackSize),
    ]);

    addContactCallback(CarContactCallback());
    add(fpsText);
    openMenu();
  }

  void openMenu() {
    overlays.add('menu');
    startCamera = CameraComponent(
      world: cameraWorld,
    )
      ..viewfinder.position = trackSize / 2
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = canvasSize.x / trackSize.x - 0.2;
    add(startCamera);
  }

  void prepareStart({required int numberOfPlayers}) {
    overlays.remove('menu');
    startCamera.viewfinder
      ..add(
        ScaleEffect.to(
          Vector2.all(playZoom),
          EffectController(duration: 1.0),
        )..onFinishCallback = () => start(numberOfPlayers: numberOfPlayers),
      )
      ..add(
        MoveEffect.to(
          Vector2.all(20),
          EffectController(duration: 1.0),
        ),
      );
  }

  void start({required int numberOfPlayers}) {
    overlays.remove('menu');
    startCamera.removeFromParent();
    final viewportSize = Vector2(canvasSize.x / numberOfPlayers, canvasSize.y);

    RectangleComponent viewportRimGenerator() =>
        RectangleComponent(size: viewportSize, anchor: Anchor.center)
          ..paint.color = GameColors.blue.color
          ..paint.strokeWidth = 2.0
          ..paint.style = PaintingStyle.stroke;
    final cameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: cameraWorld,
        viewport: FixedSizeViewport(viewportSize.x, viewportSize.y)
          ..position = Vector2(
            (canvasSize.x / numberOfPlayers) * (i + 0.5),
            canvasSize.y / 2,
          )
          ..add(viewportRimGenerator()),
      )
        ..viewfinder.anchor = Anchor.center
        ..viewfinder.zoom = playZoom;
    });

    final mapCameraSize = Vector2.all(500);
    const mapCameraZoom = 0.5;
    final mapCameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: cameraWorld,
        viewport: FixedSizeViewport(mapCameraSize.x, mapCameraSize.y)
          ..position = Vector2(
            viewportSize.x / 2 - mapCameraSize.x * mapCameraZoom - 30,
            -(canvasSize.y / 2) + 30,
          ),
      )
        ..viewfinder.anchor = Anchor.center
        ..viewfinder.zoom = mapCameraZoom;
    });
    addAll(cameras);

    for (var i = 0; i < numberOfPlayers; i++) {
      final car = Car(playerNumber: i, cameraComponent: cameras[i]);
      final lapText = LapText(
        car: car,
        position: -cameras[i].viewport.size / 2 + Vector2.all(100),
      );

      car.lapNotifier.addListener(() {
        if (car.lapNotifier.value > numberOfLaps) {
          isGameOver = true;
          winner = car;
          overlays.add('gameover');
          lapText.addAll([
            ScaleEffect.by(
              Vector2.all(1.5),
              EffectController(duration: 0.2, alternate: true, repeatCount: 3),
            ),
            RotateEffect.by(pi * 2, EffectController(duration: 0.5)),
          ]);
        }
      });
      cars.add(car);
      cameraWorld.add(car);
      cameras[i].viewport.addAll([lapText, mapCameras[i]]);
    }

    pressedKeySets = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }
    _timePassed += dt;
    // TODO(Lukas): Remove
    fpsText.text = 'FPS: ${fps()}';
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (!isLoaded || isGameOver) {
      return KeyEventResult.ignored;
    }

    _clearPressedKeys();
    for (final key in keysPressed) {
      activeKeyMaps.forEachIndexed((i, keyMap) {
        if (keyMap.containsKey(key)) {
          pressedKeySets[i].add(keyMap[key]!);
        }
      });
    }
    return KeyEventResult.handled;
  }

  void _clearPressedKeys() {
    for (final pressedKeySet in pressedKeySets) {
      pressedKeySet.clear();
    }
  }

  void reset() {
    _clearPressedKeys();
    activeKeyMaps.forEach((keyMap) => keyMap.clear());
    isGameOver = false;
    _timePassed = 0;
    overlays.remove('gameover');
    openMenu();
    cars.forEach((car) => car.removeFromParent());
    children.query<CameraComponent>().forEach(
          (camera) => camera.removeFromParent(),
        );
  }

  String _maybePrefixZero(int number) {
    if (number < 10) {
      return '0$number';
    }
    return number.toString();
  }

  String get timePassed {
    final minutes = _maybePrefixZero((_timePassed / 60).floor());
    final seconds = _maybePrefixZero((_timePassed % 60).floor());
    final ms = _maybePrefixZero(((_timePassed % 1) * 100).floor());
    return [minutes, seconds, ms].join(':');
  }
}
