import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/snake_game.dart';
import '../widgets/game_board.dart';
import '../services/game_audio.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late SnakeGame _game;
  bool _showStartScreen = true;
  final GameAudio _audio = GameAudio();
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _audio.init();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    _game = SnakeGame(
      onStateChanged: _handleStateChange,
      onUpdate: _handleUpdate,
      onEvent: _handleGameEvent,
    );
  }

  void _handleGameEvent(String event) {
    switch (event) {
      case 'eat':
        _audio.playEat();
        HapticFeedback.lightImpact();
        break;
      case 'powerup':
        _audio.playPowerUp();
        HapticFeedback.mediumImpact();
        break;
      case 'gameover':
        _audio.playGameOver();
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0);
        break;
      case 'shield_break':
        HapticFeedback.mediumImpact();
        break;
    }
  }

  void _handleStateChange(GameState state) {
    if (mounted) setState(() {});
  }

  void _handleUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _game.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startGame() {
    HapticFeedback.selectionClick();
    setState(() => _showStartScreen = false);
    _game.startGame();
  }

  void _handleSwipe(DragEndDetails details) {
    if (_game.state != GameState.playing) return;

    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx.abs();
    final dy = velocity.dy.abs();

    if (dx > dy) {
      _game.changeDirection(velocity.dx > 0 ? Direction.right : Direction.left);
    } else {
      _game.changeDirection(velocity.dy > 0 ? Direction.down : Direction.up);
    }
    HapticFeedback.selectionClick();
  }

  void _handleTap(TapUpDetails details, Size screenSize) {
    if (_game.state != GameState.playing) return;

    final tapPosition = details.globalPosition;
    final dx = tapPosition.dx - screenSize.width / 2;
    final dy = tapPosition.dy - screenSize.height / 2;

    if (dx.abs() > dy.abs()) {
      _game.changeDirection(dx > 0 ? Direction.right : Direction.left);
    } else {
      _game.changeDirection(dy > 0 ? Direction.down : Direction.up);
    }
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _shakeAnimation.value * (_shakeController.value > 0.5 ? -1 : 1),
                0,
              ),
              child: _showStartScreen
                  ? _buildStartScreen()
                  : _game.state == GameState.gameOver
                      ? _buildGameOverScreen()
                      : _buildGameScreen(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'SNAKE',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00d9ff),
              letterSpacing: 8,
              shadows: [Shadow(color: Color(0xFF00d9ff), blurRadius: 20)],
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
          const SizedBox(height: 40),
          _buildPowerUpLegend(),
          const SizedBox(height: 40),
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
          const Text(
            'Swipe or tap to control',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          const Text(
            'POWER-UPS',
            style: TextStyle(fontSize: 12, color: Color(0xFF666666), letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPowerUpInfo('⚡', 'Speed', const Color(0xFFFFD700)),
              _buildPowerUpInfo('🛡️', 'Shield', const Color(0xFF00FF88)),
              _buildPowerUpInfo('🧲', 'Magnet', const Color(0xFFFF6B6B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpInfo(String icon, String name, Color color) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(name, style: TextStyle(fontSize: 10, color: color, letterSpacing: 1)),
      ],
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_game.state == GameState.playing) {
                        _game.pause();
                        _showPauseDialog();
                      }
                    },
                    icon: const Icon(Icons.pause_rounded, color: Color(0xFF666666), size: 28),
                  ),
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
                  const SizedBox(width: 48),
                ],
              ),
            ),
            _buildActivePowerUps(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GameBoard(game: _game, size: boardSize),
            ),
            const Spacer(flex: 2),
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

  Widget _buildActivePowerUps() {
    final activePowerUps = _game.activePowerUps.where((p) => p.isActive).toList();
    if (activePowerUps.isEmpty) return const SizedBox(height: 40);

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: activePowerUps.map((powerUp) {
          String icon;
          Color color;
          switch (powerUp.type) {
            case PowerUpType.speedBoost:
              icon = '⚡';
              color = const Color(0xFFFFD700);
              break;
            case PowerUpType.shield:
              icon = '🛡️';
              color = const Color(0xFF00FF88);
              break;
            case PowerUpType.magnet:
              icon = '🧲';
              color = const Color(0xFFFF6B6B);
              break;
          }
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                SizedBox(
                  width: 30,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: powerUp.remainingPercent,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDirectionHint(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF333333), size: 24),
        Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF333333), letterSpacing: 1)),
      ],
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'PAUSED',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF00d9ff), letterSpacing: 4),
        ),
        content: Text(
          'Score: ${_game.score}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _showStartScreen = true);
                  _game.dispose();
                  _game = SnakeGame(
                    onStateChanged: _handleStateChange,
                    onUpdate: _handleUpdate,
                    onEvent: _handleGameEvent,
                  );
                },
                child: const Text('QUIT', style: TextStyle(color: Color(0xFFe94560))),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _game.resume();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00d9ff)),
                child: const Text('RESUME', style: TextStyle(color: Colors.black)),
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
              shadows: [Shadow(color: Color(0xFFe94560), blurRadius: 20)],
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
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
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
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showStartScreen = true);
              _game.dispose();
              _game = SnakeGame(
                onStateChanged: _handleStateChange,
                onUpdate: _handleUpdate,
                onEvent: _handleGameEvent,
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
                style: TextStyle(fontSize: 16, color: Color(0xFF666666), letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
