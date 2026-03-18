enum ChallengeType { scoreGoal, foodCount, surviveTime, usesPowerup }

class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  final int currentValue;
  final int rewardCoins;
  final bool isCompleted;
  final DateTime date;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.rewardCoins,
    this.isCompleted = false,
    required this.date,
  });

  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.scoreGoal,
      ),
      targetValue: json['target_value'] as int,
      currentValue: json['current_value'] as int? ?? 0,
      rewardCoins: json['reward_coins'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  ChallengeModel copyWith({
    int? currentValue,
    bool? isCompleted,
  }) {
    return ChallengeModel(
      id: id,
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      rewardCoins: rewardCoins,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date,
    );
  }

  /// Fallback daily challenges generated locally when offline
  static List<ChallengeModel> get defaultChallenges {
    final today = DateTime.now();
    return [
      ChallengeModel(
        id: 'local_1',
        title: 'Score Hunter',
        description: 'Reach a score of 100 in Classic mode',
        type: ChallengeType.scoreGoal,
        targetValue: 100,
        rewardCoins: 50,
        date: today,
      ),
      ChallengeModel(
        id: 'local_2',
        title: 'Hungry Snake',
        description: 'Eat 20 food items in one game',
        type: ChallengeType.foodCount,
        targetValue: 20,
        rewardCoins: 30,
        date: today,
      ),
      ChallengeModel(
        id: 'local_3',
        title: 'Survivor',
        description: 'Survive for 60 seconds in Survival mode',
        type: ChallengeType.surviveTime,
        targetValue: 60,
        rewardCoins: 40,
        date: today,
      ),
    ];
  }
}
