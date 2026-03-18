import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/skin_model.dart';
import 'food.dart';
import 'powerup.dart';
import 'snake.dart';

enum GameMode { classic, survival, arena }

enum GameStatus { idle, running, paused, gameOver }

class GameEngine extends ChangeNotifier {
  final GameMode mode;
  final SnakeSkin skin;

  late Snake _snake;
  late Food _food;
  Powerup? _spawnedPowerup;

  final List<ActivePowerup> _activePowerups = [];
  int _score = 0;
  int _foodEaten = 0;
  int _level = 1;
  int _elapsedSeconds = 0;
  GameStatus _status = GameStatus.idle;
  Timer? _gameTimer;
  Timer? _secondTimer;
  Timer? _powerupSpawnTimer;
  int _tickMs = AppSizes.speedNormal;
  bool _shieldActive = false;
  bool _freezeActive = false;
  bool _magnetActive = false;
  bool _speedActive = false;

  int get score => _score;
  int get foodEaten => _foodEaten;
  int get level => _level;
  int get elapsedSeconds => _elapsedSeconds;
  GameStatus get status => _status;
  Snake get snake => _snake;
  Food get food => _food;
  Powerup? get spawnedPowerup => _spawnedPowerup;
  List<ActivePowerup> get activePowerups => List.unmodifiable(_activePowerups);
  bool get shieldActive => _shieldActive;
  bool get magnetActive => _magnetActive;

  GameEngine({required this.mode, required this.skin}) {
    _reset();
  }

  void _reset() {
    _snake = Snake.initial();
    _food = Food.spawn(occupied: _snake.body);
    _spawnedPowerup = null;
    _activePowerups.clear();
    _score = 0;
    _foodEaten = 0;
    _level = 1;
    _elapsedSeconds = 0;
    _status = GameStatus.idle;
    _shieldActive = false;
    _freezeActive = false;
    _magnetActive = false;
    _speedActive = false;
    _tickMs = _baseTickMs;
  }

  int get _baseTickMs {
    switch (mode) {
      case GameMode.classic:
        return AppSizes.speedNormal;
      case GameMode.survival:
        return AppSizes.speedFast;
      case GameMode.arena:
        return AppSizes.speedNormal;
    }
  }

  // ── Controls ──────────────────────────────────────────────────────────────

  void changeDirection(Direction dir) {
    if (_status == GameStatus.running) {
      _snake.changeDirection(dir);
    }
  }

  void start() {
    if (_status == GameStatus.running) return;
    _status = GameStatus.running;
    _startTimers();
    notifyListeners();
  }

  void pause() {
    if (_status != GameStatus.running) return;
    _status = GameStatus.paused;
    _stopTimers();
    notifyListeners();
  }

  void resume() {
    if (_status != GameStatus.paused) return;
    _status = GameStatus.running;
    _startTimers();
    notifyListeners();
  }

  void restart() {
    _stopTimers();
    _reset();
    notifyListeners();
    start();
  }

  void revive() {
    // Revive after watching a rewarded ad – remove the last few segments
    if (_status != GameStatus.gameOver) return;
    final body = _snake.body.toList();
    // Keep only the head + 2 segments
    final newBody = body.take(3).toList();
    _snake = Snake(
      initialBody: newBody,
      initialDirection: _snake.direction,
    );
    _status = GameStatus.running;
    _startTimers();
    notifyListeners();
  }

  // ── Timers ────────────────────────────────────────────────────────────────

  void _startTimers() {
    _gameTimer = Timer.periodic(Duration(milliseconds: _tickMs), (_) => _tick());
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
    _schedulePowerupSpawn();
  }

  void _stopTimers() {
    _gameTimer?.cancel();
    _secondTimer?.cancel();
    _powerupSpawnTimer?.cancel();
  }

  void _schedulePowerupSpawn() {
    final delaySeconds = 10 + Random().nextInt(10); // 10-20s
    _powerupSpawnTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_status == GameStatus.running && _spawnedPowerup == null) {
        _spawnedPowerup = Powerup.spawn(
          occupied: [
            ..._snake.body,
            _food.position,
          ],
        );
        notifyListeners();
      }
    });
  }

  // ── Main tick ─────────────────────────────────────────────────────────────

  void _tick() {
    if (_status != GameStatus.running) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Expire powerups
    _activePowerups.removeWhere((p) {
      if (p.isExpired(now)) {
        _applyPowerupExpiry(p.type);
        return true;
      }
      return false;
    });

    // Magnet: move food towards snake head
    if (_magnetActive) {
      _attractFood();
    }

    // Move snake
    final willGrow = _snake.shouldGrow;
    _snake.move(grow: willGrow);

    // Check wall collision
    if (_snake.isOutOfBounds(AppSizes.gridColumns, AppSizes.gridRows)) {
      if (!_shieldActive) {
        _triggerGameOver();
        return;
      } else {
        _wrapSnake();
      }
    }

    // Check self collision
    if (_snake.collidesWithSelf()) {
      if (!_shieldActive) {
        _triggerGameOver();
        return;
      }
    }

    // Check food collision
    if (_snake.head == _food.position) {
      _eatFood();
    }

    // Check powerup collision
    if (_spawnedPowerup != null && _snake.head == _spawnedPowerup!.position) {
      _collectPowerup(_spawnedPowerup!, now);
    }

    // Survival: speed up over time
    if (mode == GameMode.survival) {
      _updateSurvivalSpeed();
    }

    notifyListeners();
  }

  void _eatFood() {
    _score += _food.value;
    _foodEaten++;
    _snake.queueGrow();

    final occupied = [..._snake.body];
    if (_spawnedPowerup != null) occupied.add(_spawnedPowerup!.position);
    _food = Food.spawn(occupied: occupied);

    if (mode == GameMode.classic) {
      _level = (_score ~/ 100) + 1;
    }
  }

  void _collectPowerup(Powerup powerup, int nowMs) {
    _activePowerups.add(ActivePowerup(
      type: powerup.type,
      startMs: nowMs,
      durationMs: powerup.durationMs,
    ));
    _applyPowerupActivation(powerup.type);
    _spawnedPowerup = null;
    _schedulePowerupSpawn();
  }

  void _applyPowerupActivation(PowerupType type) {
    switch (type) {
      case PowerupType.speedBoost:
        _speedActive = true;
        _restartGameTimer(AppSizes.speedVeryFast);
      case PowerupType.shield:
        _shieldActive = true;
      case PowerupType.freeze:
        _freezeActive = true;
        _restartGameTimer(AppSizes.speedSlow);
      case PowerupType.magnet:
        _magnetActive = true;
    }
  }

  void _applyPowerupExpiry(PowerupType type) {
    switch (type) {
      case PowerupType.speedBoost:
        _speedActive = false;
        _restartGameTimer(_baseTickMs);
      case PowerupType.shield:
        _shieldActive = false;
      case PowerupType.freeze:
        _freezeActive = false;
        _restartGameTimer(_baseTickMs);
      case PowerupType.magnet:
        _magnetActive = false;
    }
  }

  void _restartGameTimer(int newTickMs) {
    _tickMs = newTickMs;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: _tickMs),
      (_) => _tick(),
    );
  }

  void _updateSurvivalSpeed() {
    final newLevel = (_elapsedSeconds ~/ 10) + 1; // level up every 10 seconds
    if (newLevel != _level) {
      _level = newLevel.clamp(1, AppSizes.survivalMaxLevel);
      if (!_speedActive && !_freezeActive) {
        final newSpeed = (AppSizes.speedFast -
                (_level - 1) *
                    ((AppSizes.speedFast - AppSizes.speedMax) ~/
                        AppSizes.survivalMaxLevel))
            .clamp(AppSizes.speedMax, AppSizes.speedFast);
        _restartGameTimer(newSpeed);
      }
    }
  }

  void _triggerGameOver() {
    _status = GameStatus.gameOver;
    _stopTimers();
    notifyListeners();
  }

  /// Wrap snake around walls (shield behaviour)
  void _wrapSnake() {
    // This is handled by moving the snake – we correct the head position
    // by wrapping it. Since Snake doesn't expose position mutation,
    // we recreate it with wrapped head.
    final body = _snake.body.toList();
    final wrappedHead = GridPosition(
      (body.first.x + AppSizes.gridColumns) % AppSizes.gridColumns,
      (body.first.y + AppSizes.gridRows) % AppSizes.gridRows,
    );
    final newBody = [wrappedHead, ...body.skip(1)];
    _snake = Snake(
      initialBody: newBody,
      initialDirection: _snake.direction,
    );
  }

  void _attractFood() {
    // Move food one step closer to snake head
    final head = _snake.head;
    final fp = _food.position;
    int nx = fp.x, ny = fp.y;
    if (fp.x < head.x) nx++;
    if (fp.x > head.x) nx--;
    if (fp.y < head.y) ny++;
    if (fp.y > head.y) ny--;
    // Only move food if it doesn't overlap snake body
    final newPos = GridPosition(nx, ny);
    if (!_snake.body.contains(newPos)) {
      _food = Food(
        position: newPos,
        type: _food.type,
        value: _food.value,
      );
    }
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}
