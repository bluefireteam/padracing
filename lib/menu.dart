import 'dart:html' as html;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image, Gradient;

import 'game.dart';
import 'game_colors.dart';
import 'menu_card.dart';

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
            Column(
              children: [
                MenuCard(
                  children: [
                    Text(
                      'PadRacing',
                      style: textTheme.headline1,
                    ),
                    Text(
                      'First to 3 laps win',
                      style: textTheme.bodyText1,
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
                MenuCard(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Made by ',
                            style: textTheme.bodyText2,
                          ),
                          TextSpan(
                            text: 'Lukas Klingsbo',
                            style: textTheme.bodyText2
                                ?.copyWith(color: GameColors.green.color),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //ignore: unsafe_html
                                html.window.open(
                                  'https://github.com/spydon',
                                  '_blank',
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Checkout the ',
                            style: textTheme.bodyText2,
                          ),
                          TextSpan(
                            text: 'repository',
                            style: textTheme.bodyText2
                                ?.copyWith(color: GameColors.green.color),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //ignore: unsafe_html
                                html.window.open(
                                  'https://github.com/bluefireteam/padracing',
                                  '_blank',
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
