import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'api/story_api.dart';
import 'models/story.dart' hide UserPlan, MonthlyUsage;
import 'models/user_plan.dart';
import 'pages/terms_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/license_page.dart' as license;
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabaseを初期化（エラーが発生してもアプリは継続）
  try {
    await SupabaseService.instance.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Supabase initialization failed: $e');
    // 初期化に失敗してもアプリは続行
  }
  
  runApp(const EhonApp());
}

class EhonApp extends StatelessWidget {
  const EhonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF7C83FD));
    final scheme = base.colorScheme.copyWith(
      primary: const Color(0xFFE74C3C), // クレヨンレッド
      secondary: const Color(0xFFF39C12), // クレヨンオレンジ
      surface: const Color(0xFFFFF8E1), // クリーム色の紙風
      tertiary: const Color(0xFF3498DB), // クレヨンブルー
      primaryContainer: const Color(0xFFFFE5E5), // 薄いピンク
      secondaryContainer: const Color(0xFFFFF3E0), // 薄いオレンジ
    );
    final radius = 20.0; // より丸みを帯びた形に

    return MaterialApp(
      title: 'つづきのえほん',
      theme: base.copyWith(
        colorScheme: scheme,
        textTheme: GoogleFonts.mPlusRounded1cTextTheme(base.textTheme).copyWith(
          titleLarge: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.w800),
          titleMedium: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.w700),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.primary,
          centerTitle: false,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
          ),
        ),
        cardTheme: CardThemeData(
          color: scheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
          filled: true,
          fillColor: scheme.surface,
          isDense: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            backgroundColor: scheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          labelStyle: TextStyle(color: scheme.primary),
          backgroundColor: scheme.primary.withValues(alpha: 0.08),
        ),
      ),
      home: const TitlePage(),
    );
  }
}

class TitlePage extends StatefulWidget {
  const TitlePage({super.key});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> with TickerProviderStateMixin {
  late AnimationController _walkingController;
  late Animation<double> _walkingAnimation;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    
    // 背景アニメーション用のコントローラー
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3), // 20秒でゆっくり再生
      vsync: this,
    );
    
    // 左右に動くアニメーションの設定（より遅く、往復する）
    _walkingController = AnimationController(
      duration: const Duration(seconds: 12), // 12秒でゆっくり動く
      vsync: this,
    );
    
    // アニメーションの初期設定（画面幅は後で設定）
    _walkingAnimation = Tween<double>(
      begin: -200.0, // 左端から開始
      end: 600.0, // 初期値（後でdidChangeDependenciesで更新）
    ).animate(CurvedAnimation(
      parent: _walkingController,
      curve: Curves.easeInOut, // より滑らかなカーブ
    ));
    
    // 往復アニメーションを実行
    _walkingController.repeat(reverse: true); // reverse: trueで往復
    
    // 背景アニメーションを開始（1回のみ）
    _backgroundController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 画面サイズが取得できるようになったらアニメーションの範囲を更新
    final screenWidth = MediaQuery.of(context).size.width;
    _walkingAnimation = Tween<double>(
      begin: -100.0, // 左端少し外から開始
      end: screenWidth - 50, // 右端少し手前まで（アニメーションサイズ分調整）
    ).animate(CurvedAnimation(
      parent: _walkingController,
      curve: Curves.easeInOut, // 端で滑らかに方向転換
    ));
  }

  @override
  void dispose() {
    _walkingController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StoryListPage()),
        );
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Background Animation
              Positioned.fill(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return OverflowBox(
                      maxWidth: orientation == Orientation.landscape 
                          ? MediaQuery.of(context).size.width * 1.3 // 横向き時は30%拡大
                          : MediaQuery.of(context).size.width,
                      maxHeight: orientation == Orientation.landscape 
                          ? MediaQuery.of(context).size.height * 1.3 // 横向き時は30%拡大
                          : MediaQuery.of(context).size.height,
                      child: Lottie.asset(
                        'assets/animations/Android App Background.json',
                        fit: BoxFit.cover, // 常にカバー表示
                        repeat: false, // 1回のみ再生
                        controller: _backgroundController, // カスタムコントローラーで速度制御
                        alignment: Alignment.center, // 中央に配置
                        onLoaded: (composition) {
                          _backgroundController.forward(); // アニメーション開始
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // フォールバック：元のグラデーション背景
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              // Content overlay
              SafeArea(
                child: Stack(
                  children: [
                    // メインコンテンツ - 中央に配置
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 120,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'つづきのえほん',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '絵本の続きをあなたの手で',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 80),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '画面をタップして始める',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 下部で左右に動くBOOK WALKINGアニメーション
                    Positioned(
                      bottom: 50,
                      child: AnimatedBuilder(
                        animation: _walkingAnimation,
                        builder: (context, child) {
                          // アニメーションの進行方向を判定（左向きか右向きか）
                          final isMovingRight = _walkingController.status == AnimationStatus.forward;
                          
                          return Transform.translate(
                            offset: Offset(_walkingAnimation.value, 0),
                            child: Transform.scale(
                              scaleX: isMovingRight ? 1.0 : -1.0, // 左向きの時は水平反転
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: Lottie.asset(
                                  'assets/animations/BOOK WALKING.json',
                                  repeat: true,
                                  animate: true,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // フォールバック：本のアイコンが左右に動く
                                    return Icon(
                                      Icons.menu_book,
                                      size: 60,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryListPage extends StatefulWidget {
  const StoryListPage({super.key});

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> with TickerProviderStateMixin {
  final api = StoryApi();
  late Future<List<Story>> _future;
  // Added: grid/list toggle and search query
  bool _useGrid = false;
  String _query = '';
  // Added: selection mode for bulk delete
  bool _isSelectionMode = false;
  Set<String> _selectedStoryIds = <String>{};
  
  // Added: random speech messages
  final Random _random = Random();
  String _currentMessage = '';
  
  // Added: BOOK WALKING animation controller
  late AnimationController _walkingController;
  
  // プラン管理
  UserPlan _currentPlan = UserPlan.free;
  MonthlyUsage _monthlyUsage = MonthlyUsage.current();
  
  // セリフのリスト
  static const List<String> _emptyMessages = [
    '新しい絵本を作ってみませんか？\n右下のボタンから始められます！',
    'あなたの想像力で素敵な物語を\n作ってみましょう！',
    '最初の一冊を作成して\n絵本コレクションを始めましょう！',
    'どんな冒険の物語にしますか？\nワクワクする絵本を作りましょう！',
    'キャラクターと一緒に\n新しい世界を探検しませんか？',
  ];
  
  static const List<String> _hasStoriesMessages = [
    '素敵な絵本がたくさんですね！\n新しい物語も作ってみましょう！',
    'コレクションが充実していますね！\n次はどんなお話にしますか？',
    '読み返すのも楽しいですが、\n新作も作ってみませんか？',
    'たくさんの冒険が詰まっていますね！\n新しい冒険も始めましょう！',
    '素晴らしいライブラリですね！\n創作意欲が湧いてきます！',
    '絵本作家さんですね！\n次の傑作をお待ちしています！',
  ];

  // Added: simple filter by title
  List<Story> _applyFilter(List<Story> src) {
    if (_query.trim().isEmpty) return src;
    final q = _query.toLowerCase();
    return src.where((s) => s.title.toLowerCase().contains(q)).toList();
  }
  
  // Added: get random message based on story count
  String _getRandomMessage(bool hasStories) {
    final messages = hasStories ? _hasStoriesMessages : _emptyMessages;
    return messages[_random.nextInt(messages.length)];
  }
  
  // Added: build speech bubble widget
  Widget _buildSpeechBubble(BuildContext context, List<Story> data) {
    return GestureDetector(
      onTap: () {
        // 吹き出しをタップするとメッセージが変わる
        setState(() {
          _currentMessage = _getRandomMessage(data.isNotEmpty);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _currentMessage.isEmpty 
                    ? _getRandomMessage(data.isNotEmpty)
                    : _currentMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
            // 吹き出しの尻尾（左側に配置）
            Positioned(
              bottom: -8,
              left: 20,
              child: CustomPaint(
                size: const Size(16, 8),
                painter: SpeechBubbleTail(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _future = api.listStories();
    // 初期メッセージを設定
    _currentMessage = _getRandomMessage(false);
    
    // BOOK WALKING animation setup
    _walkingController = AnimationController(
      duration: const Duration(seconds: 8), // 8秒で一往復
      vsync: this,
    );
    
    // アニメーションを繰り返し開始
    _walkingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _walkingController.dispose();
    super.dispose();
  }

  // プラン管理メソッド
  bool canCreateStory() {
    if (_currentPlan.monthlyLimit == -1) return true; // 無制限
    return _monthlyUsage.storiesCreated < _currentPlan.monthlyLimit;
  }
  
  int getRemainingStories() {
    if (_currentPlan.monthlyLimit == -1) return -1; // 無制限
    return (_currentPlan.monthlyLimit - _monthlyUsage.storiesCreated).clamp(0, _currentPlan.monthlyLimit);
  }
  
  void _incrementUsage() {
    if (_monthlyUsage.isCurrent()) {
      setState(() {
        _monthlyUsage.storiesCreated++;
      });
    } else {
      // 月が変わった場合は新しい月の使用量を初期化
      setState(() {
        _monthlyUsage = MonthlyUsage.current();
        _monthlyUsage.storiesCreated = 1;
      });
    }
    _saveUsage();
    
    // Supabaseに使用量を記録
    try {
      SupabaseService.instance.updateMonthlyUsage(_monthlyUsage.storiesCreated);
    } catch (e) {
      print('Error updating monthly usage in Supabase: $e');
    }
  }
  
  Future<void> _saveUsage() async {
    // 本来はSharedPreferencesやデータベースに保存
    // ここでは簡単にローカル変数で管理
  }
  
  Future<void> _loadUsage() async {
    // 本来はSharedPreferencesやデータベースから読み込み
    // ここでは簡単にローカル変数で管理
  }
  
  void _showPlanLimitDialog() {
    final remaining = getRemainingStories();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('${_currentPlan.displayName}の制限'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今月の絵本作成回数が上限に達しました。'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '現在のプラン：${_currentPlan.displayName}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('月間制限：${_currentPlan.monthlyLimitDisplay}'),
                  Text('今月作成済み：${_monthlyUsage.storiesCreated}冊'),
                  if (remaining == 0)
                    Text(
                      '残り回数：0回',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('より多くの絵本を作成するには、プランのアップグレードをご検討ください。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlanPage()),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('プランを見る'),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = api.listStories();
    });
    
    // リフレッシュ後にメッセージも更新
    final items = await _future;
    final data = _applyFilter(items);
    setState(() {
      _currentMessage = _getRandomMessage(data.isNotEmpty);
    });
  }

  Future<void> _showBulkDeleteDialog() async {
    if (_selectedStoryIds.isEmpty) return;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('${_selectedStoryIds.length}冊の絵本を削除'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('選択した${_selectedStoryIds.length}冊の絵本を削除しますか？'),
            const SizedBox(height: 12),
            Text(
              '※この操作は取り消せません',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _bulkDeleteStories();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('${_selectedStoryIds.length}冊削除'),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkDeleteStories() async {
    final selectedIds = List<String>.from(_selectedStoryIds);
    try {
      // 削除処理中のローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('${selectedIds.length}冊を削除中...'),
            ],
          ),
        ),
      );

      // APIで一括削除処理
      for (String storyId in selectedIds) {
        await api.deleteStory(storyId);
      }
      
      if (!mounted) return;
      
      // ローディングダイアログを閉じる
      Navigator.of(context).pop();
      
      // 選択モードを終了
      setState(() {
        _isSelectionMode = false;
        _selectedStoryIds.clear();
      });
      
      // 成功メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('${selectedIds.length}冊の絵本を削除しました'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // リストを更新
      await _refresh();
      
    } catch (e) {
      if (!mounted) return;
      
      // ローディングダイアログを閉じる（エラーの場合）
      Navigator.of(context).pop();
      
      // エラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('削除に失敗しました: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleSelection(String storyId) {
    setState(() {
      if (_selectedStoryIds.contains(storyId)) {
        _selectedStoryIds.remove(storyId);
        if (_selectedStoryIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedStoryIds.add(storyId);
        _isSelectionMode = true;
      }
    });
  }

  void _toggleSelectAll(List<Story> stories) {
    setState(() {
      if (_selectedStoryIds.length == stories.length) {
        // 全選択解除
        _selectedStoryIds.clear();
        _isSelectionMode = false;
      } else {
        // 全選択
        _selectedStoryIds.clear();
        _selectedStoryIds.addAll(stories.map((s) => s.id));
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _showDeleteDialog(Story story) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('絵本を削除'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('以下の絵本を削除しますか？'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.network(
                        story.pages.isNotEmpty ? story.pages[0].imageUrl : 'https://picsum.photos/seed/default/40/40',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CircleAvatar(
                            radius: 20,
                            child: Text(
                              story.title.isNotEmpty ? story.title[0] : '?',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ページ数: ${story.pages.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '削除ボタン（🗑️）またはカードの長押しで削除できます',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '※この操作は取り消せません',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteStory(story);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStory(Story story) async {
    try {
      // 削除処理中のローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('削除中...'),
            ],
          ),
        ),
      );

      // APIで削除処理
      await api.deleteStory(story.id);
      
      if (!mounted) return;
      
      // ローディングダイアログを閉じる
      Navigator.of(context).pop();
      
      // 成功メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('「${story.title}」を削除しました'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // リストを更新
      await _refresh();
      
    } catch (e) {
      if (!mounted) return;
      
      // ローディングダイアログを閉じる（エラーの場合）
      Navigator.of(context).pop();
      
      // エラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('削除に失敗しました: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _openCreateDialog() async {
    // プラン制限チェック
    if (!canCreateStory()) {
      _showPlanLimitDialog();
      return;
    }
    
    final formKey = GlobalKey<FormState>();
    final titleC = TextEditingController();
    final pagesC = TextEditingController(text: _currentPlan.maxPages.toString());
    final heroC = TextEditingController();
    final availableStyles = _currentPlan.availableStyles;
    String selectedStyle = availableStyles.first;
    const styleSamples = <String, String>{
      '水彩': 'assets/Images/watercolor_sample.jpeg',
      'アニメ': 'assets/Images/watercolor_sample.jpeg',
      '油彩': 'assets/Images/watercolor_sample.jpeg',
      '絵本風': 'assets/Images/watercolor_sample.jpeg',
      '手描き': 'assets/Images/watercolor_sample.jpeg',
      'ドット絵': 'assets/Images/watercolor_sample.jpeg',
      'プレミアム水彩': 'assets/Images/watercolor_sample.jpeg',
      'プレミアム油彩': 'assets/Images/watercolor_sample.jpeg',
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Form(
                key: formKey,
                child: OrientationBuilder(
                  builder: (ctx2, orientation) {
                    if (orientation == Orientation.landscape) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 左: 入力群
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          '絵本作成',
                                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                                color: Theme.of(ctx).colorScheme.primary,
                                              ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            icon: const Icon(Icons.casino_outlined),
                                            label: const Text('ランダム生成'),
                                            onPressed: () {
                                              final rng = Random();
                                              const sampleTitles = [
                                                'ふしぎな森のぼうけん',
                                                'ねこのピクニック',
                                                '月のうさぎ',
                                                'ちいさなひとりだち',
                                                'ひみつのドア',
                                              ];
                                              const sampleHeros = ['ゆうた', 'さくら', 'はると', 'りん', 'そら'];
                                              setModalState(() {
                                                titleC.text = sampleTitles[rng.nextInt(sampleTitles.length)];
                                                pagesC.text = (4 + rng.nextInt(3)).toString();
                                                selectedStyle = availableStyles[rng.nextInt(availableStyles.length)];
                                                heroC.text = sampleHeros[rng.nextInt(sampleHeros.length)];
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: titleC,
                                          decoration: const InputDecoration(
                                            labelText: '絵本タイトル',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          validator: (v) => (v == null || v.trim().isEmpty) ? 'タイトルを入力してください' : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: pagesC,
                                                decoration: const InputDecoration(
                                                  labelText: 'ページ数',
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                ),
                                                keyboardType: TextInputType.number,
                                                validator: (v) {
                                                  final t = v?.trim() ?? '';
                                                  if (t.isEmpty) return 'ページ数を入力してください';
                                                  final n = int.tryParse(t);
                                                  if (n == null) return '数値を入力してください';
                                                  if (n < 4 || n > 6) return '4〜6の範囲で入力してください';
                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: selectedStyle,
                                                decoration: const InputDecoration(
                                                  labelText: '画風',
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                ),
                                                style: TextStyle(color: Colors.black),
                                                items: availableStyles
                                                    .map(
                                                      (s) => DropdownMenuItem<String>(
                                                        value: s,
                                                        child: Text(s),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (v) => setModalState(() => selectedStyle = v ?? selectedStyle),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: heroC,
                                          decoration: const InputDecoration(
                                            labelText: '主人公の名前',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          validator: (v) => (v == null || v.trim().isEmpty) ? '主人公の名前を入力してください' : null,
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.of(ctx).pop(),
                                                child: const Text('キャンセル'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: FilledButton.icon(
                                                icon: const Icon(Icons.auto_stories),
                                                label: const Text('作成'),
                                                style: FilledButton.styleFrom(
                                                  foregroundColor: Colors.black87,
                                                ),
                                                onPressed: () async {
                                                  if (!(formKey.currentState?.validate() ?? false)) return;
                                                  Navigator.of(context).pop();
                                                  final id = DateTime.now().millisecondsSinceEpoch.toString();
                                                  final count = int.parse(pagesC.text.trim());
                                                  final title = titleC.text.trim();
                                                  final hero = heroC.text.trim();
                                                  final firstPage = StoryPage(
                                                    imageUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/500',
                                                    text: '"$hero"の冒険がはじまる。',
                                                  );
                                                  final pages = <StoryPage>[firstPage];
                                                  for (int i = 2; i <= count; i++) {
                                                    pages.add(StoryPage(
                                                      imageUrl: 'https://picsum.photos/seed/${id}_$i/800/500',
                                                      text: '$iページ目のテキスト（生成待ち）',
                                                    ));
                                                  }
                                                  final story = Story(id: id, title: title, pages: pages);
                                                  await api.createStory(story);
                                                  
                                                  // 使用量を増加
                                                  _incrementUsage();
                                                  
                                                  if (!mounted) return;
                                                  // 外側のcontextを明示的に使用
                                                  await Navigator.of(this.context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => StoryDetailPage(story: story, showOnlyFirstPage: true),
                                                    ),
                                                  );
                                                  await _refresh();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // 右: プレビューのみ（高さを抑えるため4:3）
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '画風サンプル',
                                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: AspectRatio(
                                          aspectRatio: 4 / 3,
                                          child: Image.asset(
                                            styleSamples[selectedStyle]!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.palette,
                                                color: Theme.of(ctx).colorScheme.primary,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    // portrait: 既存のスクロールレイアウトを維持
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '絵本作成',
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(ctx).colorScheme.primary,
                                ),
                          ),
                          // ランダム生成ボタン
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.casino_outlined),
                              label: const Text('ランダム生成'),
                              onPressed: () {
                                final rng = Random();
                                const sampleTitles = [
                                  'ふしぎな森のぼうけん',
                                  'ねこのピクニック',
                                  '月のうさぎ',
                                  'ちいさなひとりだち',
                                  'ひみつのドア',
                                ];
                                const sampleHeros = ['ゆうた', 'さくら', 'はると', 'りん', 'そら'];
                                setModalState(() {
                                  titleC.text = sampleTitles[rng.nextInt(sampleTitles.length)];
                                  pagesC.text = (4 + rng.nextInt(3)).toString(); // 4-6
                                  selectedStyle = availableStyles[rng.nextInt(availableStyles.length)];
                                  heroC.text = sampleHeros[rng.nextInt(sampleHeros.length)];
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: titleC,
                            decoration: const InputDecoration(
                              labelText: '絵本タイトル',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'タイトルを入力してください' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: pagesC,
                                  decoration: const InputDecoration(
                                    labelText: 'ページ数',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    final t = v?.trim() ?? '';
                                    if (t.isEmpty) return 'ページ数を入力してください';
                                    final n = int.tryParse(t);
                                    if (n == null) return '数値を入力してください';
                                    if (n < 4 || n > 6) return '4〜6の範囲で入力してください';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedStyle,
                                  decoration: const InputDecoration(
                                    labelText: '画風',
                                    border: OutlineInputBorder(),
                                  ),
                                  style: TextStyle(color: Theme.of(ctx).colorScheme.primary),
                                  items: availableStyles
                                      .map(
                                        (s) => DropdownMenuItem<String>(
                                          value: s,
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.asset(
                                                  styleSamples[s]!,
                                                  width: 40,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(
                                                    width: 40,
                                                    height: 30,
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      Icons.palette,
                                                      size: 16,
                                                      color: Theme.of(ctx).colorScheme.primary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                s,
                                                style: TextStyle(color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setModalState(() => selectedStyle = v ?? selectedStyle),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              Text(
                                '画風サンプル',
                                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.asset(
                                    styleSamples[selectedStyle]!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.palette,
                                        color: Theme.of(ctx).colorScheme.primary,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: heroC,
                            decoration: const InputDecoration(
                              labelText: '主人公の名前',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? '主人公の名前を入力してください' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('キャンセル'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  icon: const Icon(Icons.auto_stories),
                                  label: const Text('作成'),
                                  style: FilledButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                  ),
                                  onPressed: () async {
                                    if (!(formKey.currentState?.validate() ?? false)) return;
                                    Navigator.of(ctx).pop();

                                    final id = DateTime.now().millisecondsSinceEpoch.toString();
                                    final count = int.parse(pagesC.text.trim());
                                    final title = titleC.text.trim();
                                    final hero = heroC.text.trim();

                                    // 1ページ目（モック）
                                    final firstPage = StoryPage(
                                      imageUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/500',
                                      text: '"$hero"の冒険がはじまる。',
                                    );
                                    final pages = <StoryPage>[firstPage];
                                    for (int i = 2; i <= count; i++) {
                                      pages.add(
                                        StoryPage(
                                          imageUrl: 'https://picsum.photos/seed/${id}_$i/800/500',
                                          text: '$iページ目のテキスト（生成待ち）',
                                        ),
                                      );
                                    }

                                    final story = Story(id: id, title: title, pages: pages);
                                    await api.createStory(story);
                                    
                                    // 使用量を増加
                                    _incrementUsage();

                                    if (!mounted) return;
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => StoryDetailPage(story: story, showOnlyFirstPage: true),
                                      ),
                                    );

                                    await _refresh();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
               ), // end Form
             ); // end Padding
          }, // end StatefulBuilder builder
        ); // end StatefulBuilder
      }, // end showModalBottomSheet builder
    ); // end showModalBottomSheet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode 
            ? Text('${_selectedStoryIds.length}冊選択中')
            : const Text('絵本一覧'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedStoryIds.clear();
                  });
                },
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  tooltip: '削除',
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE74C3C),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Color(0xFFE74C3C),
                      size: 20,
                    ),
                  ),
                  onPressed: _selectedStoryIds.isNotEmpty ? _showBulkDeleteDialog : null,
                ),
              ]
            : [
                IconButton(
                  tooltip: _useGrid ? 'リスト表示' : 'グリッド表示',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3498DB),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _useGrid ? Icons.view_list : Icons.grid_view,
                      color: const Color(0xFF3498DB),
                      size: 18,
                    ),
                  ),
                  onPressed: () => setState(() => _useGrid = !_useGrid),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: '選択モード',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF39C12).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF39C12),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.checklist,
                      color: Color(0xFFF39C12),
                      size: 18,
                    ),
                  ),
                  onPressed: () => setState(() => _isSelectionMode = true),
                ),
              ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'つづきのえほん',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '絵本の続きをあなたの手で',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('ホーム'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('新しい絵本を作成'),
              onTap: () {
                Navigator.pop(context);
                _openCreateDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('更新'),
              onTap: () {
                Navigator.pop(context);
                _refresh();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('プラン'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlanPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(_useGrid ? Icons.view_list : Icons.grid_view),
              title: Text(_useGrid ? 'リスト表示' : 'グリッド表示'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _useGrid = !_useGrid);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('利用規約'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('プライバシーポリシー'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copyright),
              title: const Text('ライセンス'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const license.LicensePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      // プラン情報表示
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_currentPlan.displayName} • ${getRemainingStories() == -1 ? "無制限" : "残り${getRemainingStories()}回"}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: getRemainingStories() == 0 
                                      ? Colors.red.shade600
                                      : Theme.of(context).colorScheme.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (getRemainingStories() == 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '制限',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            else if (getRemainingStories() != -1 && getRemainingStories() <= 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.yellow.shade700,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '残僅',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.yellow.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 検索バー
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'タイトルで検索',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: FutureBuilder<List<Story>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final items = snapshot.data ?? [];
                        final data = _applyFilter(items);

                        if (data.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.menu_book_outlined,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _query.isEmpty ? 'まだ絵本がありません' : '一致する絵本が見つかりません',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _query.isEmpty
                                        ? '右下の「絵本作成」で追加してみましょう'
                                        : 'キーワードを変えて検索してください',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (_useGrid) {
                          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                              isLandscape ? 8 : 12, 
                              isLandscape ? 4 : 8, 
                              isLandscape ? 8 : 12, 
                              isLandscape 
                                  ? MediaQuery.of(context).padding.bottom + 110  // 横向き時はキャラクター分の余白を増やす
                                  : MediaQuery.of(context).padding.bottom + 160  // 縦向き時のSafeArea考慮
                            ),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isLandscape ? 4 : 2, // 横向き時は4列
                              mainAxisSpacing: isLandscape ? 8 : 12, // 横向き時は間隔を狭く
                              crossAxisSpacing: isLandscape ? 8 : 12, // 横向き時は間隔を狭く
                              childAspectRatio: isLandscape ? 0.85 : 0.9, // 縦の表示領域を狭く
                            ),
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final s = data[i];
                              final isSelected = _selectedStoryIds.contains(s.id);
                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  if (_isSelectionMode) {
                                    _toggleSelection(s.id);
                                  } else {
                                    // 生成待ちのページがある場合は続きから作成モードで開く
                                    final hasPlaceholder = s.pages.any((p) => p.text.contains('生成待ち'));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StoryDetailPage(
                                          story: s, 
                                          showOnlyFirstPage: hasPlaceholder,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onLongPress: () {
                                  if (!_isSelectionMode) {
                                    _toggleSelection(s.id);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? const Color(0xFFE74C3C).withValues(alpha: 0.1)
                                        : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE74C3C)
                                          : const Color(0xFF3498DB).withValues(alpha: 0.3),
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected 
                                            ? const Color(0xFFE74C3C).withValues(alpha: 0.3)
                                            : const Color(0xFF3498DB).withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // 大きな画像表示（絵本の表紙風）
                                      Expanded(
                                        flex: 3,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                              child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: Image.network(
                                                  s.pages.isNotEmpty ? s.pages[0].imageUrl : 'https://picsum.photos/seed/default/300/400',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.menu_book,
                                                            size: isLandscape ? 32 : 48, // 横向き時は小さく
                                                            color: Theme.of(context).colorScheme.primary,
                                                          ),
                                                          SizedBox(height: isLandscape ? 4 : 8), // 横向き時は間隔を狭く
                                                          Text(
                                                            s.title.isNotEmpty ? s.title[0] : '?',
                                                            style: (isLandscape 
                                                                ? Theme.of(context).textTheme.titleMedium 
                                                                : Theme.of(context).textTheme.headlineMedium)?.copyWith(
                                                              color: Theme.of(context).colorScheme.primary,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            // 選択インジケータ
                                            if (_isSelectionMode)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  width: isLandscape ? 20 : 24, // 横向き時は小さく
                                                  height: isLandscape ? 20 : 24, // 横向き時は小さく
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(0xFFE74C3C)
                                                        : Colors.white.withValues(alpha: 0.9),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: const Color(0xFFE74C3C),
                                                      width: 2,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    isSelected ? Icons.check : null,
                                                    size: isLandscape ? 12 : 14, // 横向き時は小さく
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // タイトルとページ数
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(isLandscape ? 6 : 8), // 横向き時はパディングを小さく
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Hero(
                                                  tag: 'story_${s.id}',
                                                  child: Material(
                                                    type: MaterialType.transparency,
                                                    child: Text(
                                                      s.title,
                                                      maxLines: isLandscape ? 1 : 2, // 横向き時は1行のみ
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        height: 1.2,
                                                        fontSize: isLandscape ? 12 : null, // 横向き時はフォントサイズを小さく
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: isLandscape ? 2 : 4), // 横向き時は間隔を狭く
                                              Row(
                                                children: [
                                                  // ステータスタグ
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: isLandscape ? 4 : 6,
                                                      vertical: isLandscape ? 1 : 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                          ? Colors.orange.withValues(alpha: 0.2)
                                                          : Colors.green.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                            ? Colors.orange
                                                            : Colors.green,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          s.pages.any((p) => p.text.contains('生成待ち'))
                                                              ? Icons.pause_circle_outline
                                                              : Icons.check_circle_outline,
                                                          size: isLandscape ? 8 : 10,
                                                          color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                              ? Colors.orange.shade700
                                                              : Colors.green.shade700,
                                                        ),
                                                        SizedBox(width: isLandscape ? 1 : 2),
                                                        Text(
                                                          s.pages.any((p) => p.text.contains('生成待ち'))
                                                              ? '作成中'
                                                              : '完成',
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                                ? Colors.orange.shade700
                                                                : Colors.green.shade700,
                                                            fontSize: isLandscape ? 8 : 9,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Icon(
                                                    Icons.book,
                                                    size: isLandscape ? 10 : 12, // 横向き時はアイコンを小さく
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  SizedBox(width: isLandscape ? 2 : 4), // 横向き時は間隔を狭く
                                                  Text(
                                                    '${s.pages.length}ページ',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey.shade600,
                                                      fontSize: isLandscape ? 10 : 11, // 横向き時はフォントサイズを小さく
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.only(
                            top: 8, 
                            bottom: MediaQuery.of(context).orientation == Orientation.landscape 
                                ? MediaQuery.of(context).padding.bottom + 90  // 横向き時はSafeArea + キャラクター分
                                : MediaQuery.of(context).padding.bottom + 160 // 縦向き時はSafeArea + FAB + キャラクター分
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final s = data[i];
                            final isSelected = _selectedStoryIds.contains(s.id);
                            final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                            
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 12, 
                                vertical: isLandscape ? 3 : 6, // 横向き時は縦マージンを小さく
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              color: isSelected 
                                  ? const Color(0xFFE74C3C).withValues(alpha: 0.1)
                                  : Theme.of(context).colorScheme.surface,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  if (_isSelectionMode) {
                                    _toggleSelection(s.id);
                                  } else {
                                    // 生成待ちのページがある場合は続きから作成モードで開く
                                    final hasPlaceholder = s.pages.any((p) => p.text.contains('生成待ち'));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StoryDetailPage(
                                          story: s, 
                                          showOnlyFirstPage: hasPlaceholder,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onLongPress: () {
                                  if (!_isSelectionMode) {
                                    _toggleSelection(s.id);
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(isLandscape ? 8 : 16), // 横向き時はパディングを小さく
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // 左側：画像（横向き時はサイズを小さく）
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          width: isLandscape ? 60 : 80,  // 横向き時は小さく
                                          height: isLandscape ? 45 : 60, // 横向き時は小さく
                                          child: Image.network(
                                            s.pages.isNotEmpty ? s.pages[0].imageUrl : 'https://picsum.photos/seed/default/80/60',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.menu_book,
                                                  color: Theme.of(context).colorScheme.primary,
                                                  size: isLandscape ? 24 : 32, // 横向き時は小さく
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: isLandscape ? 12 : 16), // 横向き時は間隔を狭く
                                      // 中央：タイトルと詳細情報
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // タイトル
                                            Hero(
                                              tag: 'story_${s.id}',
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Text(
                                                  s.title,
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: isLandscape ? 14 : null, // 横向き時はフォントサイズを小さく
                                                  ),
                                                  maxLines: isLandscape ? 1 : 2, // 横向き時は1行のみ
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: isLandscape ? 3 : 6), // 横向き時は間隔を狭く
                                            // ステータスタグとページ数情報
                                            Row(
                                              children: [
                                                // ステータスタグ
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isLandscape ? 4 : 6, 
                                                    vertical: isLandscape ? 1 : 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                        ? Colors.orange.withValues(alpha: 0.2)
                                                        : Colors.green.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                          ? Colors.orange
                                                          : Colors.green,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        s.pages.any((p) => p.text.contains('生成待ち'))
                                                            ? Icons.pause_circle_outline
                                                            : Icons.check_circle_outline,
                                                        size: isLandscape ? 10 : 12,
                                                        color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                            ? Colors.orange.shade700
                                                            : Colors.green.shade700,
                                                      ),
                                                      SizedBox(width: isLandscape ? 2 : 3),
                                                      Text(
                                                        s.pages.any((p) => p.text.contains('生成待ち'))
                                                            ? '作成中'
                                                            : '完成',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                              ? Colors.orange.shade700
                                                              : Colors.green.shade700,
                                                          fontSize: isLandscape ? 9 : 10,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: isLandscape ? 6 : 8),
                                                // ページ数情報
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isLandscape ? 4 : 6, 
                                                    vertical: isLandscape ? 1 : 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.book,
                                                        size: isLandscape ? 10 : 12,
                                                        color: Theme.of(context).colorScheme.primary,
                                                      ),
                                                      SizedBox(width: isLandscape ? 2 : 3),
                                                      Text(
                                                        '${s.pages.length}ページ',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.primary,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: isLandscape ? 9 : 10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: isLandscape ? 3 : 6), // 横向き時は間隔を狭く
                                            // 1ページ目のテキスト抜粋（横向き時は1行、縦向き時は2行）
                                            Text(
                                              s.pages.isNotEmpty ? s.pages[0].text : '',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey.shade600,
                                                height: 1.3,
                                                fontSize: isLandscape ? 11 : null, // 横向き時はフォントサイズを小さく
                                              ),
                                              maxLines: isLandscape ? 1 : 2, // 横向き時は1行のみ
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 右側：選択インジケータ
                                      if (_isSelectionMode)
                                        Container(
                                          width: isLandscape ? 20 : 24, // 横向き時は小さく
                                          height: isLandscape ? 20 : 24, // 横向き時は小さく
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFFE74C3C)
                                                : Colors.white.withValues(alpha: 0.9),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFE74C3C),
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            isSelected ? Icons.check : null,
                                            size: isLandscape ? 12 : 14, // 横向き時は小さく
                                            color: Colors.white,
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.chevron_right,
                                          color: const Color(0xFF3498DB).withValues(alpha: 0.7),
                                          size: isLandscape ? 16 : 20, // 横向き時は小さく
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
        // 下部のBook.jsonキャラクターと吹き出し
        Positioned(
          bottom: MediaQuery.of(context).orientation == Orientation.landscape 
              ? -10  // 横向き時はさらに下に配置（画面外に）
              : 20, // 縦向き時ももう少し下に配置
          left: 10,
          right: MediaQuery.of(context).orientation == Orientation.landscape 
              ? 200 // 横向き時は絵本作成ボタンの真横に配置するため右側余白を拡大
              : 120, // 縦向き時は従来通り
          child: FutureBuilder<List<Story>>(
            future: _future,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              final data = _applyFilter(items);
              final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Book.jsonアニメーション（左側に配置）
                  SizedBox(
                    width: isLandscape ? 60 : 80, // 横向き時はサイズを小さく
                    height: isLandscape ? 60 : 80, // 横向き時はサイズを小さく
                    child: Lottie.asset(
                      'assets/animations/Book.json',
                      repeat: true,
                      animate: true,
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        print('Book.json loaded successfully');
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // デバッグ情報を出力
                        print('Failed to load Book.json: $error');
                        print('Stack trace: $stackTrace');
                        
                        // より動的なフォールバック：アニメーション風の本アイコン
                        return TweenAnimationBuilder(
                          duration: const Duration(seconds: 2),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * (0.5 + 0.5 * sin(value * 3.14159 * 4))),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.menu_book,
                                  size: isLandscape ? 30 : 40, // 横向き時はアイコンも小さく
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            // アニメーションを繰り返すために状態を更新
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10), // キャラクターと吹き出しの間隔
                  // 吹き出し（右側に配置、横向き時は幅を制限）
                  isLandscape 
                      ? SizedBox(
                          width: 200, // 横向き時は固定幅をさらに狭める
                          child: GestureDetector(
                            onTap: () {
                              // 吹き出しをタップするとメッセージが変わる
                              setState(() {
                                _currentMessage = _getRandomMessage(data.isNotEmpty);
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(8), // 横向き時はパディングを小さく
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12), // 角を少し小さく
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6, // シャドウを小さく
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      _currentMessage.isEmpty 
                                          ? _getRandomMessage(data.isNotEmpty)
                                          : _currentMessage,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith( // 横向き時は小さいフォント
                                        color: Theme.of(context).colorScheme.onSurface,
                                        height: 1.3,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  // 吹き出しの尻尾（左側に配置、小さく）
                                  Positioned(
                                    bottom: -6,
                                    left: 16,
                                    child: CustomPaint(
                                      size: const Size(12, 6), // サイズを小さく
                                      painter: SpeechBubbleTail(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: _buildSpeechBubble(context, data),
                        ),
                ],
              );
            },
          ),
        ),
        ],
      ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF39C12),
              const Color(0xFFE74C3C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF39C12).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: canCreateStory() ? _openCreateDialog : () {
            _showPlanLimitDialog();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: SizedBox(
            width: 32,
            height: 32,
            child: Lottie.asset(
              'assets/animations/Paint Brush.json',
              repeat: true,
              animate: true,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // アニメーションファイルが見つからない場合のフォールバック
                return const Icon(
                  Icons.brush,
                  color: Colors.white,
                  size: 32,
                );
              },
            ),
          ),
          label: Text(
            '絵本作成',
            style: GoogleFonts.mPlusRounded1c(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// Added: Story detail page with Hero title
class StoryDetailPage extends StatefulWidget {
  final Story story;
  final bool showOnlyFirstPage;
  const StoryDetailPage({super.key, required this.story, this.showOnlyFirstPage = false});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

// 完全に新しい_StoryDetailPageStateクラスで構文エラーを解決
class _StoryDetailPageState extends State<StoryDetailPage> with TickerProviderStateMixin {
  late int _currentIndex;
  final TextEditingController _nextController = TextEditingController();
  bool _showPreviewAfterFinish = false;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // showOnlyFirstPageの場合は最初のページ（インデックス0）から開始
    // 続きから作成の場合は、最初の生成待ちページから開始
    if (widget.showOnlyFirstPage) {
      // 生成待ちのページを探して、そのページから開始
      final pages = widget.story.pages;
      _currentIndex = 0;
      for (int i = 0; i < pages.length; i++) {
        if (pages[i].text.contains('生成待ち')) {
          _currentIndex = i > 0 ? i - 1 : 0; // 生成待ちの1つ前のページから開始（0より小さくならないように）
          break;
        }
      }
    } else {
      _currentIndex = 0;
    }
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _nextController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPlaceholder = widget.story.pages.any((p) => p.text.contains('生成待ち'));
    final showSingle = widget.showOnlyFirstPage && (hasPlaceholder || _showPreviewAfterFinish);
    return WillPopScope(
      onWillPop: () async => !hasPlaceholder,
      child: Scaffold(
        appBar: showSingle ? AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Hero(
              tag: 'story_${widget.story.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.story.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) : null,
        body: showSingle
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      if (orientation == Orientation.landscape) {
                        // 横向き：左にテキストとUI、右に画像
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 左側：テキストと入力フィールド
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ページ番号表示
                                  Text(
                                    'ページ ${_currentIndex + 1} / ${widget.story.pages.length}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  // テキスト表示
                                  Expanded(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 500),
                                      transitionBuilder: (child, animation) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.3, 0),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOut,
                                          )),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Center(
                                        key: ValueKey(_currentIndex),
                                        child: SingleChildScrollView(
                                          child: Text(
                                            widget.story.pages[_currentIndex].text,
                                            style: const TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (hasPlaceholder && _currentIndex < widget.story.pages.length - 1)
                                    Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        // 入力フィールドを表示（最後のページ以外で共通）
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _nextController,
                                                decoration: const InputDecoration(
                                                  hintText: '続きを入力...',
                                                  border: OutlineInputBorder(),
                                                ),
                                                maxLines: 3,
                                                minLines: 1,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            FilledButton.icon(
                                              icon: const Icon(Icons.send),
                                              label: const Text('送信'),
                                              onPressed: _onSubmitNext,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // 一時中断ボタン
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('一時中断'),
                                                  content: const Text('作成途中の絵本を保存して一覧画面に戻りますか？\n\n後で「続きから作成」で再開できます。'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('キャンセル'),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                                      },
                                                      style: FilledButton.styleFrom(
                                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                                        foregroundColor: Colors.white,
                                                      ),
                                                      child: const Text('一時中断'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.pause,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            label: Text(
                                              '一時中断',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  // 最後のページで「完成」ボタンを表示
                                  if (hasPlaceholder && _currentIndex == widget.story.pages.length - 1)
                                    Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                                },
                                                icon: Icon(
                                                  Icons.pause,
                                                  size: 16,
                                                  color: Colors.grey.shade500,
                                                ),
                                                label: Text(
                                                  '一時中断',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: FilledButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    _showPreviewAfterFinish = true;
                                                  });
                                                },
                                                icon: const Icon(Icons.check),
                                                label: const Text('完成'),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  // 絵本完成後のボタン表示
                                  if (!hasPlaceholder && _showPreviewAfterFinish)
                                    Column(
                                      children: [
                                        const SizedBox(height: 24),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 48,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '絵本が完成しました！',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              FilledButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    _showPreviewAfterFinish = false;
                                                    _currentIndex = 0; // 1ページ目にリセット
                                                  });
                                                  // PageControllerも1ページ目にアニメーション
                                                  _pageController.animateToPage(
                                                    0,
                                                    duration: const Duration(milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                  );
                                                },
                                                icon: const Icon(Icons.menu_book),
                                                label: const Text('全ページを見る'),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                                  foregroundColor: Colors.white,
                                                  minimumSize: const Size(double.infinity, 48),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 右側：画像
                            Expanded(
                              flex: 1,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.8,
                                      end: 1.0,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    )),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  key: ValueKey('image_$_currentIndex'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.story.pages[_currentIndex].imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // 縦向き：既存のレイアウト
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ページ番号表示
                            Text(
                              'ページ ${_currentIndex + 1} / ${widget.story.pages.length}',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // 画像表示
                            Expanded(
                              flex: 2,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.9,
                                      end: 1.0,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    )),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  key: ValueKey('vertical_image_$_currentIndex'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.story.pages[_currentIndex].imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // テキスト表示
                            Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.story.pages[_currentIndex].text,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            if (hasPlaceholder && _currentIndex < widget.story.pages.length - 1)
                              Column(
                                children: [
                                  const SizedBox(height: 16),
                                  // 入力フィールドを表示（最後のページ以外で共通）
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _nextController,
                                          decoration: const InputDecoration(
                                            hintText: '続きを入力...',
                                            border: OutlineInputBorder(),
                                          ),
                                          maxLines: 3,
                                          minLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton.icon(
                                        icon: const Icon(Icons.send),
                                        label: const Text('送信'),
                                        onPressed: _onSubmitNext,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // 一時中断ボタン
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('一時中断'),
                                            content: const Text('作成途中の絵本を保存して一覧画面に戻りますか？\n\n後で「続きから作成」で再開できます。'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('キャンセル'),
                                              ),
                                              FilledButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                                },
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('一時中断'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.pause,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      label: Text(
                                        '一時中断',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            // 最後のページで「完成」ボタンを表示
                            if (hasPlaceholder && _currentIndex == widget.story.pages.length - 1)
                              Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).popUntil((route) => route.isFirst);
                                          },
                                          icon: Icon(
                                            Icons.pause,
                                            size: 16,
                                            color: Colors.grey.shade500,
                                          ),
                                          label: Text(
                                            '一時中断',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _showPreviewAfterFinish = true;
                                            });
                                          },
                                          icon: const Icon(Icons.check),
                                          label: const Text('完成'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            // 絵本完成後のボタン表示
                            if (!hasPlaceholder && _showPreviewAfterFinish)
                              Column(
                                children: [
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 48,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '絵本が完成しました！',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        FilledButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _showPreviewAfterFinish = false;
                                              _currentIndex = 0; // 1ページ目にリセット
                                            });
                                            // PageControllerも1ページ目にアニメーション
                                            _pageController.animateToPage(
                                              0,
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          icon: const Icon(Icons.menu_book),
                                          label: const Text('全ページを見る'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(double.infinity, 48),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              )
            : SafeArea(
                bottom: false,
                child: Column(
                children: [
                  // ページナビゲーションバー
                  OrientationBuilder(
                    builder: (context, orientation) {
                      return Container(
                        padding: orientation == Orientation.landscape
                            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 2)
                            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: orientation == Orientation.landscape
                                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
                                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(orientation == Orientation.landscape ? 12 : 16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_stories,
                                    size: orientation == Orientation.landscape ? 14 : 18,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  SizedBox(width: orientation == Orientation.landscape ? 4 : 6),
                                  Text(
                                    widget.story.title,
                                    style: (orientation == Orientation.landscape
                                        ? Theme.of(context).textTheme.bodySmall
                                        : Theme.of(context).textTheme.titleMedium)?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: orientation == Orientation.landscape ? 2 : 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: _currentIndex > 0 
                                      ? () {
                                          _pageController.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                  iconSize: orientation == Orientation.landscape ? 18 : 24,
                                  padding: orientation == Orientation.landscape 
                                      ? const EdgeInsets.all(6) 
                                      : null,
                                  constraints: orientation == Orientation.landscape 
                                      ? const BoxConstraints(minWidth: 28, minHeight: 28)
                                      : null,
                                ),
                                Text(
                                  'ページ ${_currentIndex + 1} / ${widget.story.pages.length}',
                                  style: orientation == Orientation.landscape
                                      ? Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)
                                      : Theme.of(context).textTheme.titleSmall,
                                ),
                                IconButton(
                                  onPressed: _currentIndex < widget.story.pages.length - 1 
                                      ? () {
                                          _pageController.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                  iconSize: orientation == Orientation.landscape ? 18 : 24,
                                  padding: orientation == Orientation.landscape 
                                      ? const EdgeInsets.all(6) 
                                      : null,
                                  constraints: orientation == Orientation.landscape 
                                      ? const BoxConstraints(minWidth: 28, minHeight: 28)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.story.pages.length,
                      onPageChanged: (index) => setState(() => _currentIndex = index),
                      pageSnapping: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final page = widget.story.pages[index];
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                            }
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: OrientationBuilder(
                                  builder: (context, orientation) {
                                    return Padding(
                                      padding: orientation == Orientation.landscape
                                          ? const EdgeInsets.all(4)
                                          : const EdgeInsets.all(16),
                                      child: orientation == Orientation.landscape
                                          ? Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                // 左側：テキスト
                                                Expanded(
                                                  flex: 1,
                                                  child: Center(
                                                    child: SingleChildScrollView(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(right: 4),
                                                        child: Text(
                                                          page.text,
                                                          style: const TextStyle(fontSize: 16),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // 右側：画像
                                                Expanded(
                                                  flex: 1,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      page.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: Colors.grey[300],
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.image,
                                                              size: 64,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                // 画像表示
                                                Expanded(
                                                  flex: 2,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.network(
                                                      page.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: Colors.grey[300],
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.image,
                                                              size: 64,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // テキスト表示
                                                Expanded(
                                                  flex: 1,
                                                  child: SingleChildScrollView(
                                                    child: Text(
                                                      page.text,
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        bottomNavigationBar: !showSingle ? OrientationBuilder(
          builder: (context, orientation) {
            return Container(
              padding: orientation == Orientation.landscape 
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                  : const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('絵本一覧に戻る'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(
                      double.infinity, 
                      orientation == Orientation.landscape ? 36 : 48
                    ),
                  ),
                ),
              ),
            );
          },
        ) : null,
      ),
    );
  }

  void _onSubmitNext() {
    final v = _nextController.text.trim();
    if (v.isEmpty) return;
    
    setState(() {
      final pages = widget.story.pages;
      
      if (_currentIndex == 0) {
        // 1ページ目の場合：2ページ目のテキストを更新して移動
        if (pages.length > 1 && pages[1].text.contains('生成待ち')) {
          pages[1] = StoryPage(imageUrl: pages[1].imageUrl, text: v);
          _currentIndex = 1; // 2ページ目に移動
        }
      } else {
        // 2ページ目以降の場合：次のページのテキストを更新
        final nextPageIndex = _currentIndex + 1;
        if (nextPageIndex < pages.length && pages[nextPageIndex].text.contains('生成待ち')) {
          pages[nextPageIndex] = StoryPage(imageUrl: pages[nextPageIndex].imageUrl, text: v);
          _currentIndex = nextPageIndex; // 次のページに移動
        }
        
        // すべてのページが完成したかチェック
        final hasRemainingPlaceholder = pages.any((p) => p.text.contains('生成待ち'));
        if (!hasRemainingPlaceholder) {
          // すべてのページが完成した場合は完成状態にする
          _showPreviewAfterFinish = true;
        }
      }
      
      _nextController.clear();
    });
  }
}

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プラン'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            // 横向き：3つのプランを横並びで表示
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // タイトル部分
                  Text(
                    '絵本生成プラン',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'あなたに最適なプランをお選びください',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // プランを横並びで表示
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCompactPlanCard(
                            context,
                            title: 'フリープラン',
                            price: '無料',
                            period: '',
                            features: [
                              '月3回まで',
                              '最大4ページ',
                              '基本画風',
                              '最大5冊保存',
                            ],
                            isPopular: false,
                            buttonText: '現在のプラン',
                            onTap: null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildCompactPlanCard(
                            context,
                            title: 'ベーシック',
                            price: '¥980',
                            period: '/月',
                            features: [
                              '月10回まで',
                              '最大6ページ',
                              '全画風利用',
                              '20冊保存',
                              'PDF出力',
                            ],
                            isPopular: true,
                            buttonText: 'プラン選択',
                            onTap: () => _showSubscriptionDialog(context, 'ベーシックプラン'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildCompactPlanCard(
                            context,
                            title: 'プレミアム',
                            price: '¥1,980',
                            period: '/月',
                            features: [
                              '無制限',
                              '最大10ページ',
                              'プレミアム画風',
                              '無制限保存',
                              'PDF・高解像度',
                            ],
                            isPopular: false,
                            buttonText: 'プラン選択',
                            onTap: () => _showSubscriptionDialog(context, 'プレミアムプラン'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // 縦向き：3つのプランを縦に配置（コンパクト版）
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // タイトル部分
                  Text(
                    '絵本生成プラン',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'あなたに最適なプランをお選びください',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // プランを縦に配置
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildCompactPlanCard(
                            context,
                            title: 'フリープラン',
                            price: '無料',
                            period: '',
                            features: [
                              '絵本作成：月3回まで',
                              'ページ数：最大4ページ',
                              '画風：基本画風のみ',
                              '保存：最大5冊まで',
                            ],
                            isPopular: false,
                            buttonText: '現在のプラン',
                            onTap: null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: _buildCompactPlanCard(
                            context,
                            title: 'ベーシックプラン',
                            price: '¥980',
                            period: '/月',
                            features: [
                              '絵本作成：月10回まで',
                              'ページ数：最大6ページ',
                              '全画風利用可能',
                              '保存：最大20冊まで',
                              'PDF出力機能',
                            ],
                            isPopular: true,
                            buttonText: 'プラン選択',
                            onTap: () => _showSubscriptionDialog(context, 'ベーシックプラン'),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: _buildCompactPlanCard(
                            context,
                            title: 'プレミアムプラン',
                            price: '¥1,980',
                            period: '/月',
                            features: [
                              '絵本作成：無制限',
                              'ページ数：最大10ページ',
                              '全画風＋プレミアム画風',
                              '保存：無制限',
                              'PDF出力・高解像度画像',
                            ],
                            isPopular: false,
                            buttonText: 'プラン選択',
                            onTap: () => _showSubscriptionDialog(context, 'プレミアムプラン'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCompactPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
    required String buttonText,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'おすすめ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (period.isNotEmpty)
                      Text(
                        period,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 32,
                  child: onTap != null
                      ? FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: isPopular 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: Text(
                            buttonText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: Text(
                            buttonText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context, String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$planName を選択'),
        content: Text('$planName にアップグレードしますか？\n\n課金機能は実装中です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$planName の課金機能は準備中です'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }
}

// 吹き出しの尻尾を描画するカスタムペインター
class SpeechBubbleTail extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}