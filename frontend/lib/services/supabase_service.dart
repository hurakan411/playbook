import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  // Supabaseクライアント
  SupabaseClient? _client;
  String? _userId;
  bool _isInitialized = false;
  
  // モック環境用のフォールバック
  final List<Map<String, dynamic>> _mockLogs = [];
  
  SupabaseClient? get client => _client;
  String? get userId => _userId;
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    try {
      if (SupabaseConfig.useMockMode) {
        // モック環境
        print('Using mock mode - no actual Supabase connection');
        await _initializeUserId();
        _isInitialized = true;
        print('Mock Supabase service initialized with user ID: $_userId');
      } else {
        // 実際のSupabaseに接続
        print('Connecting to Supabase: ${SupabaseConfig.supabaseUrl}');
        
        await Supabase.initialize(
          url: SupabaseConfig.supabaseUrl,
          anonKey: SupabaseConfig.supabaseAnonKey,
          debug: false, // 本番環境ではfalseに設定
        );
        
        _client = Supabase.instance.client;
        await _initializeUserId();
        _isInitialized = true;
        
        print('Supabase service initialized successfully');
        print('User ID: $_userId');
        
        // 接続テスト
        await _testConnection();
      }
    } catch (e) {
      print('Supabase service initialization failed: $e');
      print('Falling back to mock mode...');
      
      // フォールバックとしてモックモードで初期化
      await _initializeUserId();
      _isInitialized = true;
      
      throw e;
    }
  }
  
  Future<void> _testConnection() async {
    try {
      if (_client != null) {
        // 簡単な接続テスト
        final response = await _client!.from(SupabaseConfig.usersTable).select('id').limit(1);
        print('Supabase connection test successful');
      }
    } catch (e) {
      print('Supabase connection test failed: $e');
    }
  }
  
  Future<void> _initializeUserId() async {
    if (SupabaseConfig.useMockMode) {
      // モック環境：簡易的なID生成
      if (_userId == null) {
        _userId = _generateUniqueId();
        await _registerUser();
      }
    } else {
      // 実際の環境：SharedPreferencesを使用
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id');
      
      if (_userId == null) {
        // 新しいユーザーIDを生成
        _userId = const Uuid().v4();
        await prefs.setString('user_id', _userId!);
        await _registerUser();
        print('New user registered with ID: $_userId');
      } else {
        // 既存ユーザーの最終アクティブ時刻を更新
        await updateLastActive();
        print('Existing user loaded: $_userId');
      }
    }
  }
  
  String _generateUniqueId() {
    // UUIDパッケージを使用してユニークIDを生成
    return 'user_${const Uuid().v4()}';
  }
  
  Future<void> _registerUser() async {
    if (_userId == null) return;
    
    try {
      if (SupabaseConfig.useMockMode) {
        // モック環境での新規ユーザー登録
        print('Mock: Registering new user with ID: $_userId');
        await logAction('user_registered', {
          'registration_time': DateTime.now().toIso8601String(),
          'platform': 'flutter_app',
        });
      } else {
        // 実際のSupabaseにユーザー登録
        await _client!.from(SupabaseConfig.usersTable).insert({
          'id': _userId,
          'created_at': DateTime.now().toIso8601String(),
          'last_active': DateTime.now().toIso8601String(),
          'plan': 'free',
          'monthly_usage': 0,
          'settings': {},
        });
        
        // 登録をログに記録
        await logAction('user_registered', {
          'registration_time': DateTime.now().toIso8601String(),
          'platform': 'flutter_app',
        });
        
        print('User registered in Supabase: $_userId');
      }
    } catch (e) {
      print('Error registering user: $e');
    }
  }
  
  // ログ記録メソッド
  Future<void> logAction(String action, Map<String, dynamic>? metadata) async {
    if (_userId == null) return;
    
    try {
      final logEntry = {
        'user_id': _userId,
        'action': action,
        'metadata': metadata ?? {},
        'created_at': DateTime.now().toIso8601String(),
      };
      
      if (SupabaseConfig.useMockMode) {
        // モック環境：メモリに保存
        final mockEntry = {
          'id': _generateLogId(),
          ...logEntry,
        };
        _mockLogs.add(mockEntry);
        print('Mock Log: [$action] User: $_userId, Data: $metadata');
      } else {
        // 実際のSupabaseにログを送信
        await _client!.from(SupabaseConfig.userLogsTable).insert(logEntry);
        print('Supabase Log: [$action] User: $_userId');
      }
      
    } catch (e) {
      print('Error logging action: $e');
      // フォールバック：エラーが発生してもモックログに記録
      if (!SupabaseConfig.useMockMode) {
        final mockEntry = {
          'id': _generateLogId(),
          'user_id': _userId,
          'action': action,
          'metadata': metadata ?? {},
          'created_at': DateTime.now().toIso8601String(),
        };
        _mockLogs.add(mockEntry);
      }
    }
  }
  
  String _generateLogId() {
    return 'log_${const Uuid().v4()}';
  }
  
  // ユーザーアクティビティ更新
  Future<void> updateLastActive() async {
    if (_userId == null) return;
    
    try {
      await logAction('last_active_updated', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last active: $e');
    }
  }
  
  // 月間使用量を更新
  Future<void> updateMonthlyUsage(int usage) async {
    if (_userId == null) return;
    
    try {
      await logAction('monthly_usage_updated', {
        'usage_count': usage,
        'month': DateTime.now().month,
        'year': DateTime.now().year,
      });
    } catch (e) {
      print('Error updating monthly usage: $e');
    }
  }
  
  // ユーザープランを更新
  Future<void> updateUserPlan(String plan) async {
    if (_userId == null) return;
    
    try {
      await logAction('plan_updated', {
        'new_plan': plan,
        'previous_plan': 'free', // デフォルト
      });
    } catch (e) {
      print('Error updating user plan: $e');
    }
  }
  
  // モック環境用：ログの取得
  List<Map<String, dynamic>> getMockLogs() {
    return List.from(_mockLogs);
  }
  
  // モック環境用：統計情報の取得
  Map<String, dynamic> getStats() {
    final actionCounts = <String, int>{};
    for (final log in _mockLogs) {
      final action = log['action'] as String;
      actionCounts[action] = (actionCounts[action] ?? 0) + 1;
    }
    
    return {
      'user_id': _userId,
      'total_logs': _mockLogs.length,
      'action_counts': actionCounts,
      'first_log': _mockLogs.isNotEmpty ? _mockLogs.first['created_at'] : null,
      'last_log': _mockLogs.isNotEmpty ? _mockLogs.last['created_at'] : null,
    };
  }
}