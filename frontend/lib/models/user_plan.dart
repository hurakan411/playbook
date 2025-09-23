import '../services/supabase_service.dart';

// ユーザープランとUsage管理クラス
class UserPlan {
  final String name;
  final String displayName;
  final int monthlyLimit; // -1 は無制限
  final int maxPages;
  final List<String> availableStyles;
  
  const UserPlan({
    required this.name,
    required this.displayName,
    required this.monthlyLimit,
    required this.maxPages,
    required this.availableStyles,
  });
  
  String get monthlyLimitDisplay => monthlyLimit == -1 ? '無制限' : '$monthlyLimit回';
  
  static const free = UserPlan(
    name: 'free',
    displayName: 'フリープラン',
    monthlyLimit: 1,
    maxPages: 4,
    availableStyles: ['水彩', '切り絵'],
  );
  
  static const basic = UserPlan(
    name: 'basic',
    displayName: 'ベーシックプラン',
    monthlyLimit: 10,
    maxPages: 6,
    availableStyles: ['水彩', '切り絵', '線画', "クレヨン"],
  );
  
  static const premium = UserPlan(
    name: 'premium',
    displayName: 'プレミアムプラン',
    monthlyLimit: -1,
    maxPages: 10,
    availableStyles: ['水彩', '切り絵', '線画', "クレヨン", "写実", "ポップアート", "ゆるキャラ"],
  );
  
  // Supabaseからユーザープランを取得
  static Future<UserPlan> getCurrentPlan() async {
    try {
      final supabase = SupabaseService.instance;
      await supabase.logAction('plan_requested', {});
      
      // 実際の実装ではSupabaseから取得
      // final response = await supabase.client
      //     .from('users')
      //     .select('plan')
      //     .eq('id', supabase.userId!)
      //     .single();
      
      // モック環境では常にfreeプランを返す
      return free;
      
    } catch (e) {
      print('Error fetching user plan: $e');
      return free;
    }
  }
  
  // プランを更新
  static Future<void> updatePlan(String planName) async {
    try {
      final supabase = SupabaseService.instance;
      await supabase.updateUserPlan(planName);
      
    } catch (e) {
      print('Error updating plan: $e');
    }
  }
}

class MonthlyUsage {
  int storiesCreated;
  final int year;
  final int month;
  
  MonthlyUsage({
    required this.storiesCreated,
    required this.year,
    required this.month,
  });
  
  factory MonthlyUsage.current() {
    final now = DateTime.now();
    return MonthlyUsage(
      storiesCreated: 0,
      year: now.year,
      month: now.month,
    );
  }
  
  bool isCurrent() {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}