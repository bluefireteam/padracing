import 'package:flutter/material.dart' hide Image, Gradient;

import 'game.dart';
import 'menu_card.dart';

class GameOver extends StatelessWidget {
  const GameOver(this.game, {Key? key}) : super(key: key);

  final PadRacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            MenuCard(
              children: [
                Text(
                  'Player ${game.winner!.playerNumber + 1} wins!',
                  style: textTheme.headline1,
                ),
                const SizedBox(height: 10),
                Text(
                  'Time: ${game.timePassed}',
                  style: textTheme.bodyText1,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: const Text('Restart'),
                  onPressed: game.reset,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
