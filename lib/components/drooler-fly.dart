import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:game_test/components/fly.dart';
import 'package:game_test/langaw-game.dart';

class DroolerFly extends Fly {
  double get speed => game.tileSize * 1.5;
  DroolerFly(LangawGame game, double x, double y) : super(game) {
    flyRect = Rect.fromLTWH(x, y, game.tileSize * 1, game.tileSize * 1);
    flyingSprite = List();
    flyingSprite.add(Sprite('flies/drooler-fly-1.png'));
    flyingSprite.add(Sprite('flies/drooler-fly-2.png'));
    deadSprite = Sprite('flies/drooler-fly-dead.png');
  }
}