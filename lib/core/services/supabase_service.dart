import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;

  Future<void> init({required String url, required String anonKey}) async {
    if (_initialized) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  SupabaseClient get client => Supabase.instance.client;

  bool get isInitialized => _initialized;

  // ── Leaderboard ──────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('leaderboard')
          .select('id, username, score, game_mode, created_at')
          .order('score', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard({
    int limit = 50,
  }) async {
    try {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final response = await client
          .from('leaderboard')
          .select('id, username, score, game_mode, created_at')
          .gte('created_at', weekAgo.toIso8601String())
          .order('score', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      return [];
    }
  }

  Future<void> submitScore({
    required String userId,
    required String username,
    required int score,
    required String gameMode,
  }) async {
    try {
      await client.from('leaderboard').insert({
        'user_id': userId,
        'username': username,
        'score': score,
        'game_mode': gameMode,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Fail silently – offline play is supported
    }
  }

  // ── Player profile ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getPlayerProfile(String userId) async {
    try {
      final response = await client
          .from('players')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertPlayerProfile(Map<String, dynamic> data) async {
    try {
      await client.from('players').upsert(data);
    } catch (_) {}
  }

  // ── Daily challenges ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDailyChallenges() async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final response = await client
          .from('challenges')
          .select()
          .eq('date', dateStr)
          .order('order_index');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (_) {
      return [];
    }
  }
}
