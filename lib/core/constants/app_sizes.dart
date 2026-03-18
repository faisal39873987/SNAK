class AppSizes {
  AppSizes._();

  // Game grid
  static const int gridColumns = 20;
  static const int gridRows = 30;
  static const double cellSize = 16.0;

  // Game speeds (ms between ticks)
  static const int speedSlow = 300;
  static const int speedNormal = 200;
  static const int speedFast = 130;
  static const int speedVeryFast = 80;
  static const int speedMax = 50;

  // Power-up durations (ms)
  static const int powerupDuration = 5000;
  static const int shieldDuration = 7000;
  static const int freezeDuration = 3000;
  static const int magnetDuration = 6000;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;
  static const double radiusXL = 32.0;

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXL = 48.0;

  // Font sizes
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;
  static const double fontDisplay = 32.0;
  static const double fontHero = 48.0;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 1000);

  // Survival mode speed progression
  static const int survivalSpeedStep = 1000; // score points per speed increase
  static const int survivalMaxLevel = 10;

  // Starting snake length
  static const int initialSnakeLength = 3;

  // Food score values
  static const int foodScoreNormal = 10;
  static const int foodScoreSpecial = 50;

  // Coins
  static const int coinsPerNormalFood = 1;
  static const int coinsPerSpecialFood = 5;
  static const int coinsPerGameComplete = 20;
}
