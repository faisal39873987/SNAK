class ScoreModel {
  final String id;
  final String userId;
  final String username;
  final int score;
  final String gameMode;
  final DateTime createdAt;
  final int? rank;

  const ScoreModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.score,
    required this.gameMode,
    required this.createdAt,
    this.rank,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? 'Anonymous',
      score: json['score'] as int? ?? 0,
      gameMode: json['game_mode'] as String? ?? 'classic',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      rank: json['rank'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'username': username,
        'score': score,
        'game_mode': gameMode,
        'created_at': createdAt.toIso8601String(),
      };

  ScoreModel withRank(int rank) => ScoreModel(
        id: id,
        userId: userId,
        username: username,
        score: score,
        gameMode: gameMode,
        createdAt: createdAt,
        rank: rank,
      );
}
