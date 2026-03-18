import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/snake_game.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnakeGame _game;
  bool _showStartScreen = true;

  @override
  void initState() {
    super.initState();
    _game = SnakeGame(
      onStateChanged: _handleStateChange,
      onUpdate: _handleUpdate,
    );
  }

  void _handleStateChange(GameState state) {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showStartScreen = false;
    });
    _game.startGame();
  }

  void _handleSwipe(DragEndDetails details) {
    if (_game.state != GameState.playing) return;

    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx.abs();
    final dy = velocity.dy.abs();

    if (dx > dy) {
      // Horizontal swipe
      if (velocity.dx > 0) {
        _game.changeDirection(Direction.right);
      } else {
        _game.changeDirection(Direction.left);
      }
    } else {
      // Vertical swipe
      if (velocity.dy > 0) {
        _game.changeDirection(Direction.down);
      } else {
        _game.changeDirection(Direction.up);
      }
    }
  }

  void _handleTap(TapUpDetails details, Size screenSize) {
    if (_game.state != GameState.playing) return;

    final tapPosition = details.globalPosition;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;

    final dx = tapPosition.dx - centerX;
    final dy = tapPosition.dy - centerY;

    if (dx.abs() > dy.abs()) {
      // Horizontal tap
      if (dx > 0) {
        _game.changeDirection(Direction.right);
      } else {
        _game.changeDirection(Direction.left);
      }
    } else {
      // Vertical tap
      if (dy > 0) {
        _game.changeDirection(Direction.down);
      } else {
        _game.changeDirection(Direction.up);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lock to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: _showStartScreen
            ? _buildStartScreen()
            : _game.state == GameState.gameOver
                ? _buildGameOverScreen()
                : _buildGameScreen(),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Game title
          const Text(
            'SNAKE',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00d9ff),
              letterSpacing: 8,
              shadows: [
                Shadow(
                  color: Color(0xFF00d9ff),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'GAME',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Color(0xFF666666),
              letterSpacing: 12,
            ),
          ),
          const SizedBox(height: 80),
          // Play button
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00d9ff), Color(0xFF0077b6)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00d9ff).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                'PLAY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Instructions
          const Text(
            'Swipe or tap to control',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    final screenSize = MediaQuery.of(context).size;
    final boardSize = screenSize.width - 32;

    return GestureDetector(
      onPanEnd: _handleSwipe,
      onTapUp: (details) => _handleTap(details, screenSize),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            // Score bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pause button
                  IconButton(
                    onPressed: () {
                      if (_game.state == GameState.playing) {
                        _game.pause();
                        _showPauseDialog();
                      }
                    },
                    icon: const Icon(
                      Icons.pause_rounded,
                      color: Color(0xFF666666),
                      size: 28,
                    ),
                  ),
                  // Score
                  Column(
                    children: [
                      const Text(
                        'SCORE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF666666),
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '${_game.score}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00d9ff),
                        ),
                      ),
                    ],
                  ),
                  // Empty space for symmetry
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Spacer(),
            // Game board
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GameBoard(
                game: _game,
                size: boardSize,
              ),
            ),
            const Spacer(flex: 2),
            // Direction hint
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDirectionHint(Icons.keyboard_arrow_up, 'UP'),
                  const SizedBox(width: 16),
                  _buildDirectionHint(Icons.keyboard_arrow_down, 'DOWN'),
                  const SizedBox(width: 16),
                  _buildDirectionHint(Icons.keyboard_arrow_left, 'LEFT'),
                  const SizedBox(width: 16),
                  _buildDirectionHint(Icons.keyboard_arrow_right, 'RIGHT'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionHint(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF333333), size: 24),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFF333333),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'PAUSED',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF00d9ff),
            letterSpacing: 4,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${_game.score}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _showStartScreen = true;
                  });
                  _game.dispose();
                  _game = SnakeGame(
                    onStateChanged: _handleStateChange,
                    onUpdate: _handleUpdate,
                  );
                },
                child: const Text(
                  'QUIT',
                  style: TextStyle(color: Color(0xFFe94560)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _game.resume();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00d9ff),
                ),
                child: const Text(
                  'RESUME',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'GAME OVER',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFFe94560),
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Color(0xFFe94560),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'SCORE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Color(0xFF666666),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_game.score}',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00d9ff),
            ),
          ),
          const SizedBox(height: 60),
          // Restart button
          GestureDetector(
            onTap: () {
              _game.restart();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00d9ff), Color(0xFF0077b6)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00d9ff).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                'RESTART',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Home button
          GestureDetector(
            onTap: () {
              setState(() {
                _showStartScreen = true;
              });
              _game.dispose();
              _game = SnakeGame(
                onStateChanged: _handleStateChange,
                onUpdate: _handleUpdate,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF666666)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'HOME',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
