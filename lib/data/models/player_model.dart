class PlayerModel {
  final String id;
  final String username;
  final int highScore;
  final int highScoreSurvival;
  final int coins;
  final int gamesPlayed;
  final int totalScore;
  final String equippedSkin;
  final List<String> unlockedSkins;
  final bool isVip;
  final DateTime? createdAt;

  const PlayerModel({
    required this.id,
    required this.username,
    this.highScore = 0,
    this.highScoreSurvival = 0,
    this.coins = 0,
    this.gamesPlayed = 0,
    this.totalScore = 0,
    this.equippedSkin = 'default',
    this.unlockedSkins = const ['default'],
    this.isVip = false,
    this.createdAt,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Player',
      highScore: json['high_score'] as int? ?? 0,
      highScoreSurvival: json['high_score_survival'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      gamesPlayed: json['games_played'] as int? ?? 0,
      totalScore: json['total_score'] as int? ?? 0,
      equippedSkin: json['equipped_skin'] as String? ?? 'default',
      unlockedSkins: json['unlocked_skins'] != null
          ? List<String>.from(json['unlocked_skins'] as List)
          : ['default'],
      isVip: json['is_vip'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'high_score': highScore,
        'high_score_survival': highScoreSurvival,
        'coins': coins,
        'games_played': gamesPlayed,
        'total_score': totalScore,
        'equipped_skin': equippedSkin,
        'unlocked_skins': unlockedSkins,
        'is_vip': isVip,
      };

  PlayerModel copyWith({
    String? id,
    String? username,
    int? highScore,
    int? highScoreSurvival,
    int? coins,
    int? gamesPlayed,
    int? totalScore,
    String? equippedSkin,
    List<String>? unlockedSkins,
    bool? isVip,
    DateTime? createdAt,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      username: username ?? this.username,
      highScore: highScore ?? this.highScore,
      highScoreSurvival: highScoreSurvival ?? this.highScoreSurvival,
      coins: coins ?? this.coins,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      totalScore: totalScore ?? this.totalScore,
      equippedSkin: equippedSkin ?? this.equippedSkin,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      isVip: isVip ?? this.isVip,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
