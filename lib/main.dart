import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'background.dart';
import 'ball.dart';
import 'car.dart';
import 'ground_sensor.dart';
import 'menu.dart';
import 'wall.dart';

void main() {
  final theme = ThemeData(
    textTheme: TextTheme(
      headline1: GoogleFonts.saira(
        fontSize: 21,
        color: Colors.white,
      ),
      button: GoogleFonts.saira(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyText2: GoogleFonts.saira(
        fontSize: 18,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.black,
        minimumSize: const Size(150, 50),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hoverColor: Colors.red.shade700,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red.shade700,
        ),
      ),
    ),
  );

  runApp(
    MaterialApp(
      title: 'PadRacing',
      home: GameWidget<PadRacingGame>(
        game: PadRacingGame(),
        loadingBuilder: (context) => Center(
          child: Text(
            'Loading...',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
        overlayBuilderMap: {
          'menu': (_, game) => Menu(game),
        },
        initialActiveOverlays: const ['menu'],
      ),
      theme: theme,
    ),
  );
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
  late final CameraComponent startCamera;
  late final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late final List<Set<LogicalKeyboardKey>> pressedKeySets;

  @override
  Future<void> onLoad() async {
    children.query();
    cameraWorld = World();
    final ball = Ball();
    add(cameraWorld);

    cameraWorld.add(Background());
    cameraWorld.add(GroundSensor(Vector2(25, 50), Vector2(50, 5), true));
    cameraWorld.add(GroundSensor(Vector2(25, 70), Vector2(50, 5), true));
    cameraWorld.add(GroundSensor(Vector2(52.5, 25), Vector2(5, 50), false));
    cameraWorld.addAll(createWalls(trackSize));
    cameraWorld.add(ball);

    startCamera = CameraComponent(
      world: cameraWorld,
    )
      ..viewfinder.position = trackSize / 2
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = canvasSize.x / trackSize.x - 0.2;
    add(startCamera);

    addContactCallback(CarContactCallback());
  }

  void prepareStart({required int numberOfPlayers}) {
    overlays.remove('menu');
    startCamera.viewfinder
      ..add(
        ScaleEffect.to(
          Vector2.all(10),
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
          ..paint.color = Colors.blue
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
        ..viewfinder.zoom = 10;
    });
    final mapCameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: cameraWorld,
        viewport: FixedSizeViewport(300, 300)
          ..position = Vector2(
            (canvasSize.x / numberOfPlayers) * (i + 0.7),
            40,
          ),
      )
        ..viewfinder.anchor = Anchor.center
        ..viewfinder.zoom = 0.3;
    });
    addAll(cameras);
    addAll(mapCameras);
    for (var i = 0; i < numberOfPlayers; i++) {
      cameraWorld.add(Car(playerNumber: i, cameraComponent: cameras[i]));
    }

    pressedKeySets = List.generate(numberOfPlayers, (_) => {});
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
