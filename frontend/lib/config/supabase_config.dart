class SupabaseConfig {
  // TODO: Supabaseダッシュボードから取得した値に置き換えてください
  // Settings > API から取得できます
  static const String supabaseUrl = 'https://qoekabfukkdfnkdcnlbk.supabase.co';
  static const String supabaseAnonKey = 'sb_secret_reyzMNhK0Wf8vN3xjAMIdw_XbP4A_aO'; // your-anon-key
  
  // 開発・本番の切り替え
  static const bool useMockMode = false; // falseで実際のSupabaseを使用
  
  // PostgreSQLテーブル名
  static const String usersTable = 'users';
  static const String userLogsTable = 'user_logs';
  static const String storiesTable = 'stories';
}

/*
=== Supabase プロジェクト設定手順 ===

1. https://supabase.com でプロジェクト作成
2. Settings > API から以下を取得:
   - Project URL → supabaseUrl
   - anon public → supabaseAnonKey
3. SQL Editor で以下のテーブルを作成:

-- ユーザーテーブル
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'basic', 'premium')),
  monthly_usage INTEGER DEFAULT 0,
  settings JSONB DEFAULT '{}'
);

-- ユーザーログテーブル
CREATE TABLE IF NOT EXISTS user_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 絵本テーブル
CREATE TABLE IF NOT EXISTS stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  pages JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  status TEXT DEFAULT 'completed' CHECK (status IN ('creating', 'completed', 'paused'))
);

4. Row Level Security を有効化:
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;

-- 全ユーザーがアクセス可能なポリシー（開発用）
CREATE POLICY "Enable all access for all users" ON users FOR ALL USING (true);
CREATE POLICY "Enable all access for user_logs" ON user_logs FOR ALL USING (true);
CREATE POLICY "Enable all access for stories" ON stories FOR ALL USING (true);

*/