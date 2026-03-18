import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/nokia_controls.dart';

void main() {
  runApp(const SnakeApp());
}

class SnakeApp extends StatelessWidget {
  const SnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0a0e27),
      ),
      home: const GameScreen(),
    );
  }
}

enum Direction { up, down, left, right }

enum Difficulty { easy, normal, hard, insane }

// Statistics tracker
class GameStats {
  int totalGames = 0;
  int bestScore = 0;
  int bestCombo = 0;
  int bestLevel = 0;
  int totalScore = 0;
  DateTime lastPlayDate = DateTime.now();

  void recordGame(int score, int combo, int level) {
    totalGames++;
    if (score > bestScore) bestScore = score;
    if (combo > bestCombo) bestCombo = combo;
    if (level > bestLevel) bestLevel = level;
    totalScore += score;
    lastPlayDate = DateTime.now();
  }

  double get averageScore => totalGames > 0 ? totalScore / totalGames : 0;
}

// Particle effect for food collection
class ParticleEffect {
  final int gridIndex;
  late DateTime createdAt;

  ParticleEffect(this.gridIndex) {
    createdAt = DateTime.now();
  }

  bool get isAlive => DateTime.now().difference(createdAt).inMilliseconds < 400;
}

// Floating score text
class FloatingScore {
  final int gridIndex;
  final int score;
  late DateTime createdAt;

  FloatingScore(this.gridIndex, this.score) {
    createdAt = DateTime.now();
  }

  bool get isAlive =>
      DateTime.now().difference(createdAt).inMilliseconds < 1000;

  double get opacity =>
      (1.0 - (DateTime.now().difference(createdAt).inMilliseconds / 1000))
          .clamp(0.0, 1.0);
}

// Achievement notification
class Achievement {
  final String title;
  final String icon;
  late DateTime createdAt;

  Achievement(this.title, this.icon) {
    createdAt = DateTime.now();
  }

  bool get isAlive =>
      DateTime.now().difference(createdAt).inMilliseconds < 2500;

  double get opacity {
    final elapsed = DateTime.now().difference(createdAt).inMilliseconds;
    if (elapsed < 300) return (elapsed / 300).clamp(0.0, 1.0);
    if (elapsed > 2200) return ((2500 - elapsed) / 300).clamp(0.0, 1.0);
    return 1.0;
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const int gridSize = 20;
  static const int totalCells = gridSize * gridSize;

  // Game state
  int score = 0;
  int highScore = 0;
  int combo = 0;
  int maxComboThisGame = 0;
  bool showStartScreen = true;
  bool isPaused = false;
  Difficulty difficulty = Difficulty.normal;
  String difficultyName = 'NORMAL';
  late GameStats gameStats;

  late List<int> snake;
  Direction direction = Direction.right;
  Direction? nextDirection;
  late int foodPosition;
  Timer? _timer;
  bool isGameOver = false;

  // Visual effects
  List<ParticleEffect> particles = [];
  List<FloatingScore> floatingScores = [];
  List<Achievement> achievements = [];
  late AnimationController _pulseController;
  double shakeOffset = 0;

  late Offset _startDrag;
  late FocusNode _focusNode;
  late AudioPlayer _bgMusicPlayer;
  late AudioPlayer _sfxPlayer;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _bgMusicPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    gameStats = GameStats();
    _loadHighScore();
    _playBackgroundMusic();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
      gameStats.bestScore = highScore;
      gameStats.totalGames = prefs.getInt('totalGames') ?? 0;
      gameStats.bestCombo = prefs.getInt('bestCombo') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);
    await prefs.setInt('totalGames', gameStats.totalGames);
    await prefs.setInt('bestCombo', gameStats.bestCombo);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    _bgMusicPlayer.dispose();
    _sfxPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _playBackgroundMusic() async {
    try {
      await _bgMusicPlayer.setVolume(0.25);
      await _bgMusicPlayer.play(
        UrlSource(
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        ),
      );
      await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('Could not play background music: $e');
    }
  }

  void _playSoundEffect(String soundType) async {
    try {
      String url;
      if (soundType == 'eat') {
        url =
            'https://assets.mixkit.co/active_storage/sfx/2003/2003-preview.mp3';
      } else if (soundType == 'gameover') {
        url = 'https://assets.mixkit.co/active_storage/sfx/471/471-preview.mp3';
      } else if (soundType == 'combo') {
        url =
            'https://assets.mixkit.co/active_storage/sfx/2015/2015-preview.mp3';
      } else {
        return;
      }
      await _sfxPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Could not play sound: $e');
    }
  }

  void _resetGame() {
    snake = [210, 209, 208];
    direction = Direction.right;
    nextDirection = null;
    score = 0;
    combo = 0;
    maxComboThisGame = 0;
    isGameOver = false;
    isPaused = false;
    particles.clear();
    floatingScores.clear();
    _spawnFood();
  }

  void _selectDifficulty(Difficulty selectedDifficulty) {
    setState(() {
      difficulty = selectedDifficulty;
      switch (selectedDifficulty) {
        case Difficulty.easy:
          difficultyName = 'EASY';
          break;
        case Difficulty.normal:
          difficultyName = 'NORMAL';
          break;
        case Difficulty.hard:
          difficultyName = 'HARD';
          break;
        case Difficulty.insane:
          difficultyName = 'INSANE';
          break;
      }
      showStartScreen = false;
      _resetGame();
    });
    _startLoop();
  }

  void _startLoop() {
    _timer?.cancel();
    int baseDuration = 200;
    switch (difficulty) {
      case Difficulty.easy:
        baseDuration = 250;
        break;
      case Difficulty.normal:
        baseDuration = 200;
        break;
      case Difficulty.hard:
        baseDuration = 150;
        break;
      case Difficulty.insane:
        baseDuration = 100;
        break;
    }

    final speed = baseDuration - (score ~/ 50) * 10;
    final duration = Duration(milliseconds: speed.clamp(50, baseDuration));
    _timer = Timer.periodic(duration, (_) {
      if (!mounted || isGameOver || isPaused) return;
      _tick();
    });
  }

  void _spawnFood() {
    // Generate random food position not on snake
    int newFood;
    do {
      newFood =
          (DateTime.now().millisecondsSinceEpoch + score).toUnsigned(32) %
          totalCells;
    } while (snake.contains(newFood));
    foodPosition = newFood;
  }

  void _tick() {
    if (nextDirection != null) {
      if (!_isOpposite(direction, nextDirection!)) {
        direction = nextDirection!;
      }
      nextDirection = null;
    }

    final head = snake.first;
    final next = _nextHead(head);

    if (next == null) {
      setState(() => isGameOver = true);
      _timer?.cancel();
      _triggerScreenShake();
      _playSoundEffect('gameover');
      gameStats.recordGame(score, maxComboThisGame, (score ~/ 50) + 1);
      if (score > highScore) {
        highScore = score;
      }
      _saveHighScore();
      return;
    }

    if (snake.contains(next)) {
      setState(() => isGameOver = true);
      _timer?.cancel();
      _triggerScreenShake();
      _playSoundEffect('gameover');
      gameStats.recordGame(score, maxComboThisGame, (score ~/ 50) + 1);
      if (score > highScore) {
        highScore = score;
      }
      _saveHighScore();
      return;
    }

    setState(() {
      snake.insert(0, next);

      if (next == foodPosition) {
        combo++;
        if (combo > maxComboThisGame) {
          maxComboThisGame = combo;
        }
        int points = 10 + (combo * 5);
        score += points;

        particles.add(ParticleEffect(foodPosition));
        floatingScores.add(FloatingScore(foodPosition, points));

        _playSoundEffect('eat');
        _checkAchievements();
        if (combo % 5 == 0) {
          _playSoundEffect('combo');
        }

        _pulseController.forward(from: 0);
        _spawnFood();
        _startLoop();
      } else {
        combo = 0;
        snake.removeLast();
      }

      particles.removeWhere((p) => !p.isAlive);
      floatingScores.removeWhere((f) => !f.isAlive);
    });
  }

  void _checkAchievements() {
    if (combo == 5) {
      _addAchievement('🔥', 'COMBO x5!');
      _playSoundEffect('combo');
    } else if (combo == 10) {
      _addAchievement('⚡', 'COMBO x10!');
      _playSoundEffect('combo');
    } else if (combo == 25) {
      _addAchievement('🌟', 'MEGA COMBO!');
      _playSoundEffect('combo');
    }

    int currentLevel = (score ~/ 50) + 1;
    if (currentLevel > gameStats.bestLevel && score % 50 == 0) {
      _addAchievement('📈', 'LVL $currentLevel!');
    }
  }

  void _addAchievement(String icon, String title) {
    setState(() {
      achievements.add(Achievement(title, icon));
      achievements.removeWhere((a) => !a.isAlive);
    });
  }

  void _triggerScreenShake() {
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: i * 20), () {
        if (mounted) {
          setState(() {
            shakeOffset = (i % 2 == 0) ? 4.0 : -4.0;
          });
        }
      });
    }
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) {
        setState(() => shakeOffset = 0);
      }
    });
  }

  bool _isOpposite(Direction d1, Direction d2) {
    return (d1 == Direction.up && d2 == Direction.down) ||
        (d1 == Direction.down && d2 == Direction.up) ||
        (d1 == Direction.left && d2 == Direction.right) ||
        (d1 == Direction.right && d2 == Direction.left);
  }

  int? _nextHead(int head) {
    final row = head ~/ gridSize;
    final col = head % gridSize;

    switch (direction) {
      case Direction.right:
        if (col + 1 >= gridSize) return null;
        return head + 1;
      case Direction.left:
        if (col - 1 < 0) return null;
        return head - 1;
      case Direction.down:
        if (row + 1 >= gridSize) return null;
        return head + gridSize;
      case Direction.up:
        if (row - 1 < 0) return null;
        return head - gridSize;
    }
  }

  void _handleRestart() {
    if (!isGameOver) return;
    int currentLevel = (score ~/ 50) + 1;
    gameStats.recordGame(score, combo, currentLevel);
    if (score > highScore) {
      highScore = score;
    }
    setState(() {
      showStartScreen = true;
      isGameOver = false;
    });
  }

  void _togglePause() {
    setState(() => isPaused = !isPaused);
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final distance = 50.0;

    if (velocity.dx.abs() < distance && velocity.dy.abs() < distance) {
      return; // Ignore small movements
    }

    if (velocity.dx.abs() > velocity.dy.abs()) {
      // Horizontal swipe
      if (velocity.dx > 0) {
        nextDirection = Direction.right;
      } else {
        nextDirection = Direction.left;
      }
    } else {
      // Vertical swipe
      if (velocity.dy > 0) {
        nextDirection = Direction.down;
      } else {
        nextDirection = Direction.up;
      }
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.space)) {
      _togglePause();
      return;
    }
    if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) ||
        event.isKeyPressed(LogicalKeyboardKey.keyD)) {
      nextDirection = Direction.right;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) ||
        event.isKeyPressed(LogicalKeyboardKey.keyA)) {
      nextDirection = Direction.left;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
        event.isKeyPressed(LogicalKeyboardKey.keyS)) {
      nextDirection = Direction.down;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) ||
        event.isKeyPressed(LogicalKeyboardKey.keyW)) {
      nextDirection = Direction.up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xff0a0e27),
              const Color(0xff1a1f3a),
              const Color(0xff0f1621),
            ],
          ),
        ),
        child: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _handleKeyEvent,
          child: SafeArea(
            child: showStartScreen
                ? _buildDifficultyScreen(context)
                : Stack(
                    children: [
                      _buildGameScreen(context),
                      // Achievement notifications
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: achievements.map((ach) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Opacity(
                                opacity: ach.opacity,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.withOpacity(0.9),
                                        Colors.pink.withOpacity(0.7),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.yellow,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        ach.icon,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ach.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyScreen(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.cyan, Colors.purple, Colors.pink],
              ).createShader(bounds),
              child: const Text(
                'SNAKE PRO',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'SELECT DIFFICULTY',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 2,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 40),
            _buildDifficultyButton(
              'EASY',
              'Slow & Chill',
              Colors.green,
              () => _selectDifficulty(Difficulty.easy),
            ),
            const SizedBox(height: 16),
            _buildDifficultyButton(
              'NORMAL',
              'Balanced Challenge',
              Colors.cyan,
              () => _selectDifficulty(Difficulty.normal),
            ),
            const SizedBox(height: 16),
            _buildDifficultyButton(
              'HARD',
              'Fast & Intense',
              Colors.orange,
              () => _selectDifficulty(Difficulty.hard),
            ),
            const SizedBox(height: 16),
            _buildDifficultyButton(
              'INSANE',
              'Extreme Speed',
              Colors.red,
              () => _selectDifficulty(Difficulty.insane),
            ),
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyan, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '🏆 BEST SCORE',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$highScore',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          ),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Enhanced HUD
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.cyan, Colors.blue],
                        ).createShader(bounds),
                        child: Text(
                          'SCORE: $score',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (combo > 1)
                        Text(
                          '🔥 COMBO x$combo',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.pink, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'LVL ${(score ~/ 50) + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        difficultyName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _togglePause,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isPaused
                                ? Colors.yellow.withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: isPaused ? Colors.yellow : Colors.white24,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPaused ? Icons.play_arrow : Icons.pause,
                            color: isPaused ? Colors.yellow : Colors.white38,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: isGameOver ? _handleRestart : null,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isGameOver
                                ? Colors.red.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: isGameOver ? Colors.red : Colors.white24,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: isGameOver ? Colors.red : Colors.white38,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Level Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (score % 50) / 50,
                  minHeight: 4,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(Colors.cyan, Colors.pink, (score % 50) / 50)!,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Game Board with Nokia Controls
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // حساب الحجم المناسب للوحة اللعب
                    final availableSize = constraints.biggest;
                    final boardSize =
                        (availableSize.width < availableSize.height
                            ? availableSize.width
                            : availableSize.height) -
                        20;
                    final constrainedSize = boardSize.clamp(200.0, 400.0);

                    return Center(
                      child: Transform.translate(
                        offset: Offset(shakeOffset, 0),
                        child: GestureDetector(
                          onPanStart: (details) =>
                              _startDrag = details.globalPosition,
                          onPanEnd: (details) => _handleSwipe(details),
                          child: Container(
                            width: constrainedSize,
                            height: constrainedSize,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1419),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.cyan.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyan.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: gridSize,
                                      ),
                                  itemCount: totalCells,
                                  itemBuilder: (_, index) {
                                    final isSnake = snake.contains(index);
                                    final isHead =
                                        snake.isNotEmpty &&
                                        index == snake.first;
                                    final isFood = index == foodPosition;
                                    final hasParticle = particles.any(
                                      (p) => p.gridIndex == index,
                                    );

                                    return Container(
                                      margin: const EdgeInsets.all(0.5),
                                      decoration: BoxDecoration(
                                        color: isSnake
                                            ? isHead
                                                  ? const Color(0xFF00FF6A)
                                                  : const Color(0xFF00DD55)
                                            : isFood
                                            ? const Color(0xFFFF6B6B)
                                            : const Color(0xFF0F1419),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: isHead
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF00FF6A,
                                                  ).withOpacity(0.6),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : isFood && hasParticle
                                            ? [
                                                BoxShadow(
                                                  color: Colors.red.withOpacity(
                                                    0.8,
                                                  ),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : [],
                                      ),
                                    );
                                  },
                                ),

                                // Floating scores
                                ...floatingScores.map((score) {
                                  final row = score.gridIndex ~/ gridSize;
                                  final col = score.gridIndex % gridSize;
                                  final cellSize =
                                      (constrainedSize - 12) / gridSize;
                                  return Positioned(
                                    left: col * cellSize + cellSize / 2,
                                    top: row * cellSize + cellSize / 2,
                                    child: Transform.translate(
                                      offset: Offset(0, -score.opacity * 40),
                                      child: Text(
                                        '+${score.score}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow.withOpacity(
                                            score.opacity,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                // Pause overlay
                                if (isPaused)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.pause_circle_filled,
                                              size: 48,
                                              color: Colors.yellow,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'PAUSED',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                // Game Over Overlay
                                if (isGameOver)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ShaderMask(
                                                shaderCallback: (bounds) =>
                                                    LinearGradient(
                                                      colors: [
                                                        Colors.red,
                                                        Colors.orange,
                                                      ],
                                                    ).createShader(bounds),
                                                child: const Text(
                                                  'GAME OVER',
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              // Stats Box
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.cyan,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  children: [
                                                    _buildStatRow(
                                                      '📊 Score',
                                                      '$score',
                                                    ),
                                                    const SizedBox(height: 12),
                                                    _buildStatRow(
                                                      '🔥 Best Combo',
                                                      '${gameStats.bestCombo}',
                                                    ),
                                                    const SizedBox(height: 12),
                                                    _buildStatRow(
                                                      '📈 Level',
                                                      '${(score ~/ 50) + 1}',
                                                    ),
                                                    const SizedBox(height: 12),
                                                    _buildStatRow(
                                                      '🏆 Best Score',
                                                      '${gameStats.bestScore}',
                                                    ),
                                                    const SizedBox(height: 12),
                                                    _buildStatRow(
                                                      '🎮 Total Games',
                                                      '${gameStats.totalGames}',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              GestureDetector(
                                                onTap: _handleRestart,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 48,
                                                        vertical: 14,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.cyan,
                                                        Colors.blue,
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.cyan
                                                            .withOpacity(0.5),
                                                        blurRadius: 20,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Text(
                                                    'PLAY AGAIN',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              NokiaControls(
                onUp: () {
                  setState(() {
                    if (direction != Direction.down) {
                      nextDirection = Direction.up;
                    }
                  });
                },
                onDown: () {
                  setState(() {
                    if (direction != Direction.up) {
                      nextDirection = Direction.down;
                    }
                  });
                },
                onLeft: () {
                  setState(() {
                    if (direction != Direction.right) {
                      nextDirection = Direction.left;
                    }
                  });
                },
                onRight: () {
                  setState(() {
                    if (direction != Direction.left) {
                      nextDirection = Direction.right;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
