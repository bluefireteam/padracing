import 'package:flutter/material.dart';

import 'game.dart';
import 'game_colors.dart';

class Menu extends StatelessWidget {
  const Menu(this.game, {Key? key}) : super(key: key);

  final PadRacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            Card(
              color: Colors.black,
              shadowColor: GameColors.green.color,
              elevation: 10,
              margin: const EdgeInsets.all(20),
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'PadRacing',
                      style: textTheme.headline1,
                    ),
                    Text(
                      'First to 3 laps win',
                      style: textTheme.bodyText2,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('1 Player'),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 1);
                      },
                    ),
                    Text(
                      'Arrow keys',
                      style: textTheme.bodyText2,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('2 Players'),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 2);
                      },
                    ),
                    Text(
                      'ASDW',
                      style: textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
