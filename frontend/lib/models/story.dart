class StoryPage {
  final String imageUrl;
  final String text;

  StoryPage({required this.imageUrl, required this.text});

  factory StoryPage.fromJson(Map<String, dynamic> json) => StoryPage(
        imageUrl: json['imageUrl'] as String,
        text: json['text'] as String,
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

  Story({required this.id, required this.title, required this.pages});

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        title: json['title'] as String,
        pages: (json['pages'] as List<dynamic>)
            .map((e) => StoryPage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'pages': pages.map((p) => p.toJson()).toList(),
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
