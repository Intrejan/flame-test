import 'dart:ui';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:game_test/components/flies/fly.dart';
import 'package:flutter/gestures.dart';
import 'package:game_test/components/backyard.dart';
import 'package:game_test/components/flies/house-fly.dart';
import 'package:game_test/components/flies/agile-fly.dart';
import 'package:game_test/components/flies/drooler-fly.dart';
import 'package:game_test/components/flies/hungry-fly.dart';
import 'package:game_test/components/flies/macho-fly.dart';
import 'package:game_test/view.dart';
import 'package:game_test/views/home-view.dart';
import 'package:game_test/components/buttons/start-button.dart';
import 'package:game_test/components/views/lost-view.dart';
import 'package:game_test/controllers/spawner.dart';
import 'package:game_test/components/buttons/help-button.dart';
import 'package:game_test/components/buttons/credits-button.dart';
import 'package:game_test/components/views/credits-view.dart';
import 'package:game_test/components/views/help-view.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  Backyard background;
  List<Fly> flies;
  Random rnd;

  View activeView = View.home;
  HomeView homeView;
  LostView lostView;
  HelpView helpView;
  CreditsView creditsView;
  HelpButton helpButton;
  CreditsButton creditsButton;
  StartButton startButton;

  FlySpawner spawner;

  LangawGame(){
    initialize();
  }

  void initialize() async{
    flies = List<Fly>();
    rnd = Random();
    resize(await Flame.util.initialDimensions());

    background = Backyard(this);
    homeView = HomeView(this);
    lostView = LostView(this);
    helpView = HelpView(this);
    creditsView = CreditsView(this);
    startButton = StartButton(this);
    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);
    spawner = FlySpawner(this);
  }

  void spawnFly(){
    double x = rnd.nextDouble()*(screenSize.width - (tileSize*2.025));
    double y = rnd.nextDouble()*(screenSize.height - (tileSize*2.025));
    switch (rnd.nextInt(5)) {
      case 0:
        flies.add(HouseFly(this, x, y));
        break;
      case 1:
        flies.add(DroolerFly(this, x, y));
        break;
      case 2:
        flies.add(AgileFly(this, x, y));
        break;
      case 3:
        flies.add(MachoFly(this, x, y));
        break;
      case 4:
        flies.add(HungryFly(this, x, y));
        break;
    }
  }

  void render(Canvas canvas) {
    background.render(canvas);
    helpButton.render(canvas);
    creditsButton.render(canvas);
    flies.forEach((Fly fly)=>fly.render(canvas));
    if (activeView == View.home) homeView.render(canvas);
    if (activeView == View.lost) lostView.render(canvas);
    if(activeView == View.home || activeView == View.lost){
      startButton.render(canvas);
    }
    if (activeView == View.help) helpView.render(canvas);
    if (activeView == View.credits) creditsView.render(canvas);
  }

  void update(double t) {
    flies.forEach((Fly fly)=>fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
    spawner.update(t);
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void onTapDown(TapDownDetails d){
    bool isHandled = false;

    // help button
    if (!isHandled && helpButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }

    // credits button
    if (!isHandled && creditsButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }
    if(!isHandled && startButton.rect.contains(d.globalPosition)){
      if(activeView == View.home || activeView == View.lost){
        startButton.onTapDown();
        isHandled = true;
      }
    }

    if (!isHandled) {
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }

    if(!isHandled){
      bool didHitAfly = false;

      flies.forEach((Fly fly) {
        if (fly.flyRect.contains(d.globalPosition)) {
          fly.onTapDown();
          isHandled = true;
          didHitAfly = true;
        }
      });
      if(activeView == View.playing && !didHitAfly){
        activeView = View.lost;
      }
    }
  }
}