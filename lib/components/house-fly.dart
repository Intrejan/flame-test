import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:game_test/components/fly.dart';
import 'package:game_test/langaw-game.dart';

class HouseFly extends Fly {
  HouseFly(LangawGame game, double x, double y) : super(game) {
    flyRect = Rect.fromLTWH(x, y, game.tileSize * 1, game.tileSize * 1);
    flyingSprite = List<Sprite>();
    flyingSprite.add(Sprite('flies/house-fly-1.png'));
    flyingSprite.add(Sprite('flies/house-fly-2.png'));
    deadSprite = Sprite('flies/house-fly-dead.png');
  }
}