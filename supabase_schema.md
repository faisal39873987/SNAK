# Supabase Database Schema

Run the following SQL in your Supabase project's SQL editor to set up the database.

```sql
-- Players table
CREATE TABLE IF NOT EXISTS players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT NOT NULL DEFAULT 'Player',
  high_score INTEGER NOT NULL DEFAULT 0,
  high_score_survival INTEGER NOT NULL DEFAULT 0,
  coins INTEGER NOT NULL DEFAULT 0,
  games_played INTEGER NOT NULL DEFAULT 0,
  total_score INTEGER NOT NULL DEFAULT 0,
  equipped_skin TEXT NOT NULL DEFAULT 'default',
  unlocked_skins TEXT[] NOT NULL DEFAULT ARRAY['default'],
  is_vip BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Leaderboard table
CREATE TABLE IF NOT EXISTS leaderboard (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES players(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  score INTEGER NOT NULL,
  game_mode TEXT NOT NULL DEFAULT 'classic',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Challenges table
CREATE TABLE IF NOT EXISTS challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  type TEXT NOT NULL,
  target_value INTEGER NOT NULL,
  reward_coins INTEGER NOT NULL DEFAULT 20,
  date DATE NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS leaderboard_score_idx ON leaderboard(score DESC);
CREATE INDEX IF NOT EXISTS leaderboard_created_at_idx ON leaderboard(created_at DESC);
CREATE INDEX IF NOT EXISTS challenges_date_idx ON challenges(date);

-- Row Level Security
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;

-- Everyone can read the leaderboard
CREATE POLICY "leaderboard_read_all" ON leaderboard
  FOR SELECT USING (true);

-- Authenticated users can insert to leaderboard
CREATE POLICY "leaderboard_insert" ON leaderboard
  FOR INSERT WITH CHECK (true);

-- Players can read their own profile
CREATE POLICY "players_read_own" ON players
  FOR SELECT USING (true);

-- Players can upsert their own profile
CREATE POLICY "players_upsert" ON players
  FOR ALL USING (true);
```

## Configuration

1. Create a project at https://supabase.com
2. Run the SQL above in the SQL editor
3. Copy your project URL and anon key
4. Set them as environment variables when building:

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Or edit `lib/main.dart` to set them directly for development.
