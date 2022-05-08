import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';

import 'game.dart';
import 'game_over.dart';
import 'menu.dart';

// NOTE: Be patient, it might take a few seconds for it to load after you have
// pressed the run button and it will just display a black screen meanwhile.

void main() {
  final theme = ThemeData(
    textTheme: TextTheme(
      headline1: GoogleFonts.vt323(
        fontSize: 35,
        color: Colors.white,
      ),
      button: GoogleFonts.vt323(
        fontSize: 30,
        fontWeight: FontWeight.w500,
      ),
      bodyText1: GoogleFonts.vt323(
        fontSize: 28,
        color: Colors.grey,
      ),
      bodyText2: GoogleFonts.vt323(
        fontSize: 18,
        color: Colors.grey,
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
          'gameover': (_, game) => GameOver(game),
        },
        initialActiveOverlays: const ['menu'],
      ),
      theme: theme,
    ),
  );
}
