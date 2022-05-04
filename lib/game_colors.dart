import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image;

enum GameColors {
  green,
  blue,
}

extension GameColorExtension on GameColors {
  static final colors = <GameColors, Color>{
    GameColors.green: ColorExtension.fromRGBHexString('#14F596'),
    GameColors.blue: ColorExtension.fromRGBHexString('#81DDF9'),
  };

  Color get color => colors[this]!;
  Paint get paint => Paint()..color = color;
}
