import 'dart:async';
import 'dart:math';

enum Direction { up, down, left, right }

enum GameState { playing, paused, gameOver }

class SnakeGame {
  static const int gridSize = 20;
  static const int totalCells = gridSize * gridSize;
  static const int initialSpeed = 150; // milliseconds
  static const int minSpeed = 80;

  List<int> snake = [];
  int foodPosition = 0;
  Direction direction = Direction.right;
  Direction? _pendingDirection;
  GameState state = GameState.paused;
  int score = 0;

  final Random _random = Random();
  Timer? _gameTimer;
  final Function(GameState) onStateChanged;
  final Function() onUpdate;

  SnakeGame({
    required this.onStateChanged,
    required this.onUpdate,
  });

  void startGame() {
    _resetGame();
    state = GameState.playing;
    onStateChanged(state);
    _startGameLoop();
  }

  void _resetGame() {
    // Start snake in the middle of the grid
    final startPos = (gridSize * (gridSize ~/ 2)) + (gridSize ~/ 2);
    snake = [startPos, startPos - 1, startPos - 2];
    direction = Direction.right;
    _pendingDirection = null;
    score = 0;
    _spawnFood();
  }

  void _spawnFood() {
    final availableCells = <int>[];
    for (int i = 0; i < totalCells; i++) {
      if (!snake.contains(i)) {
        availableCells.add(i);
      }
    }
    if (availableCells.isNotEmpty) {
      foodPosition = availableCells[_random.nextInt(availableCells.length)];
    }
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    // Speed increases as score increases
    final speed = (initialSpeed - (score ~/ 5) * 5).clamp(minSpeed, initialSpeed);
    _gameTimer = Timer.periodic(Duration(milliseconds: speed), (_) {
      if (state == GameState.playing) {
        _tick();
      }
    });
  }

  void _tick() {
    // Apply pending direction
    if (_pendingDirection != null) {
      direction = _pendingDirection!;
      _pendingDirection = null;
    }

    // Calculate new head position
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
        // Check if at left edge
        if (head % gridSize == 0) {
          _gameOver();
          return;
        }
        newHead = head - 1;
        break;
      case Direction.right:
        // Check if at right edge
        if (head % gridSize == gridSize - 1) {
          _gameOver();
          return;
        }
        newHead = head + 1;
        break;
    }

    // Check wall collision (top/bottom)
    if (newHead < 0 || newHead >= totalCells) {
      _gameOver();
      return;
    }

    // Check self collision
    if (snake.contains(newHead)) {
      _gameOver();
      return;
    }

    // Move snake
    snake.insert(0, newHead);

    // Check if food eaten
    if (newHead == foodPosition) {
      score += 10;
      _spawnFood();
      // Restart loop to apply new speed
      _startGameLoop();
    } else {
      // Remove tail
      snake.removeLast();
    }

    onUpdate();
  }

  void changeDirection(Direction newDirection) {
    if (state != GameState.playing) return;

    // Prevent 180-degree turns
    if (direction == Direction.up && newDirection == Direction.down) return;
    if (direction == Direction.down && newDirection == Direction.up) return;
    if (direction == Direction.left && newDirection == Direction.right) return;
    if (direction == Direction.right && newDirection == Direction.left) return;

    _pendingDirection = newDirection;
  }

  void _gameOver() {
    _gameTimer?.cancel();
    state = GameState.gameOver;
    onStateChanged(state);
    onUpdate();
  }

  void restart() {
    startGame();
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
  }
}
