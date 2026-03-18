import 'package:flutter/foundation.dart';

import '../../core/services/supabase_service.dart';
import '../models/score_model.dart';

enum LeaderboardTab { global, weekly }

class LeaderboardProvider extends ChangeNotifier {
  List<ScoreModel> _globalScores = [];
  List<ScoreModel> _weeklyScores = [];
  LeaderboardTab _selectedTab = LeaderboardTab.global;
  bool _loading = false;
  String? _error;

  List<ScoreModel> get globalScores => _globalScores;
  List<ScoreModel> get weeklyScores => _weeklyScores;
  LeaderboardTab get selectedTab => _selectedTab;
  bool get loading => _loading;
  String? get error => _error;

  List<ScoreModel> get currentScores =>
      _selectedTab == LeaderboardTab.global ? _globalScores : _weeklyScores;

  void selectTab(LeaderboardTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
    fetch();
  }

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = _selectedTab == LeaderboardTab.global
          ? await SupabaseService.instance.getGlobalLeaderboard()
          : await SupabaseService.instance.getWeeklyLeaderboard();

      final scores = data
          .asMap()
          .entries
          .map((e) => ScoreModel.fromJson(e.value).withRank(e.key + 1))
          .toList();

      if (_selectedTab == LeaderboardTab.global) {
        _globalScores = scores;
      } else {
        _weeklyScores = scores;
      }
    } catch (e) {
      _error = 'Could not load leaderboard.';
    }

    _loading = false;
    notifyListeners();
  }
}
