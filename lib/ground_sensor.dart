import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image;

import 'car.dart';

class GroundSensor extends BodyComponent {
  GroundSensor(this.position, this.size, this.isStart) : super(priority: 1);

  final bool isStart;
  final Vector2 position;
  final Vector2 size;
  late final Rect rect = size.toRect();

  @override
  Body createBody() {
    paint.color =
        (isStart ? Colors.lightGreenAccent : Colors.red).withOpacity(0.5);
    final groundBody = world.createBody(
      BodyDef(
        position: position,
        userData: this,
      ),
    );
    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape, isSensor: true);
    return groundBody..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(-size.x / 2, -size.y / 2);
    canvas.drawRect(
      rect,
      paint,
    );
  }
}

class CarContactCallback extends ContactCallback<Car, GroundSensor> {
  @override
  void begin(Car car, GroundSensor groundSensor, Contact contact) {
    if (groundSensor.isStart) {
      if (car.passedStartControl.contains(groundSensor)) {
        // If the car has driven over one start control but then backed out
        // again, to be able to go over the finish line.
        car.passedStartControl.clear();
        print('Clearing');
      }
      print('Adding');
      car.passedStartControl.add(groundSensor);
    } else if (car.passedStartControl.length == 2) {
      print('Finished');
      car.lap.value++;
      car.passedStartControl.clear();
    }
  }
}
