import 'dart:convert';

class StoryPage {
  final String imageUrl;
  final String text;

  StoryPage({required this.imageUrl, required this.text});

  factory StoryPage.fromJson(Map<String, dynamic> json) => StoryPage(
  imageUrl: (json['imageUrl'] ?? json['image_url'] ?? json['image'] ?? '') as String,
  text: (json['text'] ?? json['body'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'text': text,
      };
}

class Story {
  final String id;
  final String title;
  final List<StoryPage> pages;
  final int? totalPages; // データベースから取得する予定ページ数
  final bool? isCompletedFromDb; // データベースのis_completedフィールド
  final int? currentPages; // stories.current_pages: 次の入力を受け付ける現在のページ番号(1-based)

  Story({
    required this.id, 
    required this.title, 
    required this.pages,
    this.totalPages,
    this.isCompletedFromDb,
  this.currentPages,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    final pages = _parsePages(json['pages']);
    final totalPages = json['total_pages'] as int?;
    
    // totalPagesが設定されており、実際のページ数より多い場合は、
    // 不足分を「生成待ち」ページとして補完
    final finalPages = <StoryPage>[];
    finalPages.addAll(pages);
    
    if (totalPages != null && pages.length < totalPages) {
      for (int i = pages.length + 1; i <= totalPages; i++) {
        finalPages.add(StoryPage(
          imageUrl: '',
          text: '${i}ページ目のテキスト（生成待ち）',
        ));
      }
    }
    
    return Story(
      id: json['id'] as String,
      title: json['title'] as String,
      pages: finalPages,
      totalPages: totalPages,
      isCompletedFromDb: json['is_completed'] as bool?,
  currentPages: (json['current_page'] ?? json['current_pages']) as int?,
    );
  }

  static List<StoryPage> _parsePages(dynamic pagesField) {
    try {
      if (pagesField == null) return [];
      // Supabase join: pages is a List<Map<String, dynamic>>
      if (pagesField is List) {
        // すべてMapならそのままStoryPage化
        if (pagesField.isNotEmpty && pagesField.first is Map) {
          return pagesField.map((e) => StoryPage.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }
      }
      // If pagesField is a JSON string
      if (pagesField is String) {
        final decoded = jsonDecode(pagesField) as List<dynamic>;
        return decoded.map((e) => StoryPage.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
      return [];
    } catch (e) {
      // Fallback: empty list on parse errors
      print('Story._parsePages: failed to parse pages: $e');
      return [];
    }
  }

  // 絵本が完成しているかどうかを判定
  bool get isCompleted {
    // 1. データベースのis_completedフィールドがtrueなら完成
    if (isCompletedFromDb == true) return true;
    
    // 2. total_pagesが設定されている場合、実際のページ数と比較
    if (totalPages != null) {
      // 全ページが生成済みで、かつ全ページに画像とテキストがある場合に完成
      return pages.length >= totalPages! && 
             pages.every((page) => 
               page.imageUrl.isNotEmpty && 
               page.text.isNotEmpty && 
               !page.text.contains('生成待ち')
             );
    }
    
    // 3. フォールバック: 従来のロジック
    return pages.isNotEmpty && pages.every((page) => 
      page.imageUrl.isNotEmpty && 
      page.text.isNotEmpty && 
      !page.text.contains('生成待ち')
    );
  }

  // 完成済みページ数を取得
  int get completedPagesCount {
    return pages.where((page) => 
      page.imageUrl.isNotEmpty && 
      page.text.isNotEmpty && 
      !page.text.contains('生成待ち')
    ).length;
  }

  // 進行状況の割合（0.0 〜 1.0）
  double get completionProgress {
    if (totalPages != null && totalPages! > 0) {
      return completedPagesCount / totalPages!;
    }
    if (pages.isEmpty) return 0.0;
    return completedPagesCount / pages.length;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'pages': pages.map((p) => p.toJson()).toList(),
        'total_pages': totalPages,
        'is_completed': isCompletedFromDb,
  'current_page': currentPages,
      };
}

// プラン情報を管理するクラス
enum PlanType { free, basic, premium }

class UserPlan {
  final PlanType type;
  final int monthlyLimit;
  final int maxPages;
  final List<String> availableStyles;
  final int maxStories;
  final bool hasPdfExport;
  final bool hasHighRes;

  const UserPlan({
    required this.type,
    required this.monthlyLimit,
    required this.maxPages,
    required this.availableStyles,
    required this.maxStories,
    required this.hasPdfExport,
    required this.hasHighRes,
  });

  static const UserPlan free = UserPlan(
    type: PlanType.free,
    monthlyLimit: 3,
    maxPages: 4,
    availableStyles: ['水彩', '絵本風'],
    maxStories: 5,
    hasPdfExport: false,
    hasHighRes: false,
  );

  static const UserPlan basic = UserPlan(
    type: PlanType.basic,
    monthlyLimit: 10,
    maxPages: 6,
    availableStyles: ['水彩', 'アニメ', '油彩', '絵本風', '手描き', 'ドット絵'],
    maxStories: 20,
    hasPdfExport: true,
    hasHighRes: false,
  );

  static const UserPlan premium = UserPlan(
    type: PlanType.premium,
    monthlyLimit: -1, // -1は無制限を意味
    maxPages: 10,
    availableStyles: ['水彩', 'アニメ', '油彩', '絵本風', '手描き', 'ドット絵', 'プレミアム水彩', 'プレミアム油彩'],
    maxStories: -1, // -1は無制限を意味
    hasPdfExport: true,
    hasHighRes: true,
  );

  String get displayName {
    switch (type) {
      case PlanType.free:
        return 'フリープラン';
      case PlanType.basic:
        return 'ベーシックプラン';
      case PlanType.premium:
        return 'プレミアムプラン';
    }
  }

  String get monthlyLimitDisplay {
    return monthlyLimit == -1 ? '無制限' : '月${monthlyLimit}回まで';
  }

  String get maxPagesDisplay {
    return '最大${maxPages}ページ';
  }

  String get maxStoriesDisplay {
    return maxStories == -1 ? '無制限保存' : '最大${maxStories}冊まで';
  }
}

// 月間使用量を追跡するクラス
class MonthlyUsage {
  final int year;
  final int month;
  int storiesCreated;

  MonthlyUsage({
    required this.year,
    required this.month,
    this.storiesCreated = 0,
  });

  factory MonthlyUsage.fromJson(Map<String, dynamic> json) {
    return MonthlyUsage(
      year: json['year'],
      month: json['month'],
      storiesCreated: json['storiesCreated'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'storiesCreated': storiesCreated,
    };
  }

  static MonthlyUsage current() {
    final now = DateTime.now();
    return MonthlyUsage(year: now.year, month: now.month);
  }

  bool isCurrent() {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}
