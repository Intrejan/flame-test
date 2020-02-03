import 'package:flame/sprite.dart';
import 'package:game_test/components/fly.dart';
import 'package:game_test/langaw-game.dart';
import 'dart:ui';

class AgileFly extends Fly {
  double get speed => game.tileSize * 5;
  AgileFly(LangawGame game, double x, double y) : super(game) {
    flyRect = Rect.fromLTWH(x, y, game.tileSize * 1.5, game.tileSize * 1.5);
    flyingSprite = List();
    flyingSprite.add(Sprite('flies/agile-fly-1.png'));
    flyingSprite.add(Sprite('flies/agile-fly-2.png'));
    deadSprite = Sprite('flies/agile-fly-dead.png');
  }
}