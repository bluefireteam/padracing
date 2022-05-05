import 'package:flutter/material.dart';

import 'game.dart';

class Menu extends StatelessWidget {
  const Menu(this.game, {Key? key}) : super(key: key);

  final PadRacingGame game;

  static const instructionText =
      '''You are a crazy scientist god solving a slider puzzle in space. 
Since you are a god, some rules can be bent (press the buttons),
it doesn't necessarily make it easier though...\n
The blocks don't have to have the correct angle for you to win
(they can be upside-down for example), as long as they go from
1 to 15 in a square.''';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            Card(
              color: Colors.grey.shade200.withOpacity(0.8),
              elevation: 5,
              margin: const EdgeInsets.all(20),
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    //LogoGameWidget(),
                    const Text(
                      'PadRacing',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    //if (state.showInstructions)
                    //  const Text(
                    //    instructionText,
                    //    style: TextStyle(color: Colors.black, fontSize: 16),
                    //  ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('1 Player'),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 1);
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('2 Players'),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 2);
                      },
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
