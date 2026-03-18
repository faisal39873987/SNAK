import 'dart:async';
import 'dart:math';

enum Direction { up, down, left, right }

enum GameState { playing, paused, gameOver }

enum PowerUpType { speedBoost, shield, magnet }

class PowerUp {
  final PowerUpType type;
  final int position;
  final DateTime spawnTime;

  PowerUp({
    required this.type,
    required this.position,
  }) : spawnTime = DateTime.now();

  bool get isExpired => DateTime.now().difference(spawnTime).inSeconds > 10;
}

class ActivePowerUp {
  final PowerUpType type;
  final DateTime activatedAt;
  final int durationSeconds;

  ActivePowerUp({
    required this.type,
    required this.durationSeconds,
  }) : activatedAt = DateTime.now();

  bool get isActive => 
    DateTime.now().difference(activatedAt).inSeconds < durationSeconds;
  
  double get remainingPercent {
    final elapsed = DateTime.now().difference(activatedAt).inMilliseconds;
    final total = durationSeconds * 1000;
    return (1.0 - elapsed / total).clamp(0.0, 1.0);
  }
}

class SnakeGame {
  static const int gridSize = 20;
  static const int totalCells = gridSize * gridSize;
  static const int initialSpeed = 150;
  static const int minSpeed = 70;
  static const int boostSpeed = 50;

  List<int> snake = [];
  int foodPosition = 0;
  Direction direction = Direction.right;
  Direction? _pendingDirection;
  GameState state = GameState.paused;
  int score = 0;
  
  PowerUp? currentPowerUp;
  List<ActivePowerUp> activePowerUps = [];
  bool hasShield = false;
  
  bool foodEatenEffect = false;
  bool powerUpCollectedEffect = false;
  int? lastEatenPosition;

  final Random _random = Random();
  Timer? _gameTimer;
  Timer? _powerUpSpawnTimer;
  final Function(GameState) onStateChanged;
  final Function() onUpdate;
  final Function(String)? onEvent;

  SnakeGame({
    required this.onStateChanged,
    required this.onUpdate,
    this.onEvent,
  });

  void startGame() {
    _resetGame();
    state = GameState.playing;
    onStateChanged(state);
    _startGameLoop();
    _startPowerUpSpawner();
  }

  void _resetGame() {
    final startPos = (gridSize * (gridSize ~/ 2)) + (gridSize ~/ 2);
    snake = [startPos, startPos - 1, startPos - 2];
    direction = Direction.right;
    _pendingDirection = null;
    score = 0;
    currentPowerUp = null;
    activePowerUps.clear();
    hasShield = false;
    foodEatenEffect = false;
    powerUpCollectedEffect = false;
    _spawnFood();
  }

  void _spawnFood() {
    final availableCells = <int>[];
    for (int i = 0; i < totalCells; i++) {
      if (!snake.contains(i) && 
          (currentPowerUp == null || currentPowerUp!.position != i)) {
        availableCells.add(i);
      }
    }
    if (availableCells.isNotEmpty) {
      foodPosition = availableCells[_random.nextInt(availableCells.length)];
    }
  }

  void _spawnPowerUp() {
    if (currentPowerUp != null) return;
    if (_random.nextDouble() > 0.2) return;

    final availableCells = <int>[];
    for (int i = 0; i < totalCells; i++) {
      if (!snake.contains(i) && foodPosition != i) {
        availableCells.add(i);
      }
    }
    
    if (availableCells.isNotEmpty) {
      final types = PowerUpType.values;
      currentPowerUp = PowerUp(
        type: types[_random.nextInt(types.length)],
        position: availableCells[_random.nextInt(availableCells.length)],
      );
    }
  }

  void _startPowerUpSpawner() {
    _powerUpSpawnTimer?.cancel();
    _powerUpSpawnTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state == GameState.playing) {
        if (currentPowerUp?.isExpired == true) {
          currentPowerUp = null;
        }
        activePowerUps.removeWhere((p) => !p.isActive);
        _spawnPowerUp();
        onUpdate();
      }
    });
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    int speed = (initialSpeed - (score ~/ 5) * 3).clamp(minSpeed, initialSpeed);
    
    if (_hasPowerUp(PowerUpType.speedBoost)) {
      speed = boostSpeed;
    }
    
    _gameTimer = Timer.periodic(Duration(milliseconds: speed), (_) {
      if (state == GameState.playing) {
        _tick();
      }
    });
  }

  bool _hasPowerUp(PowerUpType type) {
    return activePowerUps.any((p) => p.type == type && p.isActive);
  }

  ActivePowerUp? getActivePowerUp(PowerUpType type) {
    try {
      return activePowerUps.firstWhere((p) => p.type == type && p.isActive);
    } catch (_) {
      return null;
    }
  }

  void _activatePowerUp(PowerUpType type) {
    activePowerUps.removeWhere((p) => p.type == type);
    
    int duration;
    switch (type) {
      case PowerUpType.speedBoost:
        duration = 5;
        break;
      case PowerUpType.shield:
        duration = 8;
        hasShield = true;
        break;
      case PowerUpType.magnet:
        duration = 6;
        break;
    }
    
    activePowerUps.add(ActivePowerUp(type: type, durationSeconds: duration));
    
    if (type == PowerUpType.speedBoost) {
      _startGameLoop();
    }
  }

  void _tick() {
    foodEatenEffect = false;
    powerUpCollectedEffect = false;
    
    final hadShieldPowerUp = _hasPowerUp(PowerUpType.shield);
    activePowerUps.removeWhere((p) => !p.isActive);
    
    if (hadShieldPowerUp && !_hasPowerUp(PowerUpType.shield)) {
      hasShield = false;
    }
    
    if (_pendingDirection != null) {
      direction = _pendingDirection!;
      _pendingDirection = null;
    }

    final head = snake.first;
    int newHead;

    switch (direction) {
      case Direction.up:
        newHead = head - gridSize;
        break;
      case Direction.down:
        newHead = head + gridSize;
        break;
      case Direction.left:
        if (head % gridSize == 0) {
          if (!_handleCollision()) return;
        }
        newHead = head - 1;
        break;
      case Direction.right:
        if (head % gridSize == gridSize - 1) {
          if (!_handleCollision()) return;
        }
        newHead = head + 1;
        break;
    }

    if (newHead < 0 || newHead >= totalCells) {
      if (!_handleCollision()) return;
    }

    if (snake.contains(newHead)) {
      if (!_handleCollision()) return;
    }

    if (_hasPowerUp(PowerUpType.magnet)) {
      _applyMagnetEffect(newHead);
    }

    snake.insert(0, newHead);

    if (newHead == foodPosition) {
      score += 10;
      foodEatenEffect = true;
      lastEatenPosition = foodPosition;
      onEvent?.call('eat');
      _spawnFood();
      _startGameLoop();
    } else {
      snake.removeLast();
    }

    if (currentPowerUp != null && newHead == currentPowerUp!.position) {
      _activatePowerUp(currentPowerUp!.type);
      powerUpCollectedEffect = true;
      onEvent?.call('powerup');
      currentPowerUp = null;
      _startGameLoop();
    }

    onUpdate();
  }

  void _applyMagnetEffect(int headPosition) {
    final headRow = headPosition ~/ gridSize;
    final headCol = headPosition % gridSize;
    final foodRow = foodPosition ~/ gridSize;
    final foodCol = foodPosition % gridSize;
    
    final distance = (headRow - foodRow).abs() + (headCol - foodCol).abs();
    
    if (distance <= 5 && distance > 1) {
      int newFoodRow = foodRow;
      int newFoodCol = foodCol;
      
      if (foodRow < headRow) {
        newFoodRow++;
      } else if (foodRow > headRow) {
        newFoodRow--;
      }
      
      if (foodCol < headCol) {
        newFoodCol++;
      } else if (foodCol > headCol) {
        newFoodCol--;
      }
      
      final newFoodPos = newFoodRow * gridSize + newFoodCol;
      if (!snake.contains(newFoodPos)) {
        foodPosition = newFoodPos;
      }
    }
  }

  bool _handleCollision() {
    if (hasShield) {
      hasShield = false;
      activePowerUps.removeWhere((p) => p.type == PowerUpType.shield);
      onEvent?.call('shield_break');
      return true;
    }
    _gameOver();
    return false;
  }

  void changeDirection(Direction newDirection) {
    if (state != GameState.playing) return;

    if (direction == Direction.up && newDirection == Direction.down) return;
    if (direction == Direction.down && newDirection == Direction.up) return;
    if (direction == Direction.left && newDirection == Direction.right) return;
    if (direction == Direction.right && newDirection == Direction.left) return;

    _pendingDirection = newDirection;
  }

  void _gameOver() {
    _gameTimer?.cancel();
    _powerUpSpawnTimer?.cancel();
    state = GameState.gameOver;
    onEvent?.call('gameover');
    onStateChanged(state);
    onUpdate();
  }

  void restart() {
    startGame();
  }

  /// Continue game after death (used with coins)
  void continueGame() {
    if (state != GameState.gameOver) return;
    
    // Respawn snake at center, keep score
    final startPos = (gridSize * (gridSize ~/ 2)) + (gridSize ~/ 2);
    snake = [startPos, startPos - 1, startPos - 2];
    direction = Direction.right;
    _pendingDirection = null;
    currentPowerUp = null;
    activePowerUps.clear();
    hasShield = false;
    foodEatenEffect = false;
    powerUpCollectedEffect = false;
    _spawnFood();
    
    state = GameState.playing;
    onStateChanged(state);
    _startGameLoop();
    _startPowerUpSpawner();
  }
  
  /// Activate a purchased power-up
  void activatePurchasedPowerUp(PowerUpType type) {
    _activatePowerUp(type);
    onUpdate();
  }

  void pause() {
    if (state == GameState.playing) {
      state = GameState.paused;
      onStateChanged(state);
    }
  }

  void resume() {
    if (state == GameState.paused) {
      state = GameState.playing;
      onStateChanged(state);
    }
  }

  void dispose() {
    _gameTimer?.cancel();
    _powerUpSpawnTimer?.cancel();
  }
}
