import 'dart:ui';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:game_test/components/fly.dart';
import 'package:flutter/gestures.dart';
import 'package:game_test/components/backyard.dart';
import 'package:game_test/components/house-fly.dart';
import 'package:game_test/components/agile-fly.dart';
import 'package:game_test/components/drooler-fly.dart';
import 'package:game_test/components/hungry-fly.dart';
import 'package:game_test/components/macho-fly.dart';
import 'package:game_test/view.dart';
import 'package:game_test/views/home-view.dart';
import 'package:game_test/components/start-button.dart';
import 'package:game_test/components/lost-view.dart';
import 'package:game_test/controllers/spawner.dart';
import 'package:game_test/components/help-button.dart';
import 'package:game_test/components/credits-button.dart';
import 'package:game_test/components/credits-view.dart';
import 'package:game_test/components/help-view.dart';
import 'package:game_test/components/score-display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_test/components/highscore-display.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:game_test/components/music-button.dart';
import 'package:game_test/components/sound-button.dart';


class LangawGame extends Game {
  final SharedPreferences storage;
  Size screenSize;
  double tileSize;
  Backyard background;
  List<Fly> flies;
  Random rnd;
  int score;

  View activeView = View.home;
  HomeView homeView;
  LostView lostView;
  HelpView helpView;
  CreditsView creditsView;
  HelpButton helpButton;
  CreditsButton creditsButton;
  StartButton startButton;
  ScoreDisplay scoreDisplay;
  FlySpawner spawner;
  HighscoreDisplay highscoreDisplay;
  AudioPlayer homeBGM;
  AudioPlayer playingBGM;
  MusicButton musicButton;
  SoundButton soundButton;

  LangawGame(this.storage){
    initialize();
  }

  void initialize() async{
    flies = List<Fly>();
    rnd = Random();
    resize(await Flame.util.initialDimensions());
    score = 0;

    background = Backyard(this);
    homeView = HomeView(this);
    lostView = LostView(this);
    helpView = HelpView(this);
    creditsView = CreditsView(this);
    startButton = StartButton(this);
    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);
    spawner = FlySpawner(this);
    scoreDisplay = ScoreDisplay(this);
    highscoreDisplay = HighscoreDisplay(this);
    musicButton = MusicButton(this);
    soundButton = SoundButton(this);

    homeBGM = await Flame.audio.loop('bgm/home.mp3', volume: .25);
    homeBGM.pause();
    playingBGM = await Flame.audio.loop('bgm/playing.mp3', volume: .25);
    playingBGM.pause();

    playHomeBGM();
  }

  void spawnFly(){
    double x = rnd.nextDouble() * (screenSize.width - (tileSize * 1.35));
    double y = (rnd.nextDouble() * (screenSize.height - (tileSize * 2.85))) + (tileSize * 1.5);
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

  void playHomeBGM() {
    playingBGM.pause();
    playingBGM.seek(Duration.zero);
    homeBGM.resume();
  }

  void playPlayingBGM() {
    homeBGM.pause();
    homeBGM.seek(Duration.zero);
    playingBGM.resume();
  }
  void render(Canvas canvas) {
    background.render(canvas);

    highscoreDisplay.render(canvas);
    if (activeView == View.playing || activeView == View.lost) scoreDisplay.render(canvas);

    flies.forEach((Fly fly) => fly.render(canvas));

    if (activeView == View.home) homeView.render(canvas);
    if (activeView == View.lost) lostView.render(canvas);
    if (activeView == View.home || activeView == View.lost) {
      startButton.render(canvas);
      helpButton.render(canvas);
      creditsButton.render(canvas);
    }
    if (activeView == View.help) helpView.render(canvas);
    if (activeView == View.credits) creditsView.render(canvas);
    musicButton.render(canvas);
    soundButton.render(canvas);
  }

  void update(double t) {
    flies.forEach((Fly fly)=>fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
    spawner.update(t);
    if (activeView == View.playing) scoreDisplay.update(t);
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
        if (soundButton.isEnabled) {
          Flame.audio.play('sfx/haha' + (rnd.nextInt(5) + 1).toString() + '.ogg');
        }
        playHomeBGM();
        activeView = View.lost;
      }
    }

    // music button
    if (!isHandled && musicButton.rect.contains(d.globalPosition)) {
      musicButton.onTapDown();
      isHandled = true;
    }

    // sound button
    if (!isHandled && soundButton.rect.contains(d.globalPosition)) {
      soundButton.onTapDown();
      isHandled = true;
    }
  }
}