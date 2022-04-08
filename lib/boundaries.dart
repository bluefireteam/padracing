import 'package:flame_forge2d/flame_forge2d.dart';

import 'house.dart';

List<House> createBoundaries(Vector2 size) {
  final topCenter = Vector2(size.x / 2, 0);
  final bottomCenter = Vector2(size.x / 2, size.y);
  final leftCenter = Vector2(0, size.y / 2);
  final rightCenter = Vector2(size.x, size.y / 2);

  final filledSize = size.clone() + Vector2.all(5);
  return [
    House(topCenter, Vector2(filledSize.x, 5)),
    House(bottomCenter, Vector2(filledSize.y, 5)),
    House(leftCenter, Vector2(5, filledSize.y)),
    House(rightCenter, Vector2(5, filledSize.y)),
  ];
}
