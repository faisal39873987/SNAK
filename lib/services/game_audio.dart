import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class GameAudio {
  static final GameAudio _instance = GameAudio._internal();
  factory GameAudio() => _instance;
  GameAudio._internal();

  final AudioPlayer _eatPlayer = AudioPlayer();
  final AudioPlayer _powerUpPlayer = AudioPlayer();
  final AudioPlayer _gameOverPlayer = AudioPlayer();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    
    // Pre-configure players for low latency
    await _eatPlayer.setReleaseMode(ReleaseMode.stop);
    await _powerUpPlayer.setReleaseMode(ReleaseMode.stop);
    await _gameOverPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playEat() async {
    try {
      await _eatPlayer.stop();
      await _eatPlayer.play(
        AssetSource('sounds/eat.mp3'),
        volume: 0.5,
      );
    } catch (e) {
      // Fallback: try URL source
      try {
        await _eatPlayer.play(
          UrlSource('https://assets.mixkit.co/active_storage/sfx/2571/2571-preview.mp3'),
          volume: 0.5,
        );
      } catch (_) {}
    }
  }

  Future<void> playPowerUp() async {
    try {
      await _powerUpPlayer.stop();
      await _powerUpPlayer.play(
        AssetSource('sounds/powerup.mp3'),
        volume: 0.6,
      );
    } catch (e) {
      try {
        await _powerUpPlayer.play(
          UrlSource('https://assets.mixkit.co/active_storage/sfx/2019/2019-preview.mp3'),
          volume: 0.6,
        );
      } catch (_) {}
    }
  }

  Future<void> playGameOver() async {
    try {
      await _gameOverPlayer.stop();
      await _gameOverPlayer.play(
        AssetSource('sounds/gameover.mp3'),
        volume: 0.7,
      );
    } catch (e) {
      try {
        await _gameOverPlayer.play(
          UrlSource('https://assets.mixkit.co/active_storage/sfx/470/470-preview.mp3'),
          volume: 0.7,
        );
      } catch (_) {}
    }
  }

  void dispose() {
    _eatPlayer.dispose();
    _powerUpPlayer.dispose();
    _gameOverPlayer.dispose();
  }
}

class GameHaptics {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
}
