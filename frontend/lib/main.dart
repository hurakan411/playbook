// ignore_for_file: unused_element
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api/story_api.dart';
import 'models/story.dart' hide UserPlan, MonthlyUsage;
import 'api/generation_api.dart';
import 'config/supabase_config.dart';
import 'models/user_plan.dart';
import 'pages/terms_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/license_page.dart' as license;
import 'services/supabase_service.dart';
import 'services/purchase_service.dart';

// レスポンシブデザイン用のヘルパー関数
class ResponsiveUtils {
  // デバイスタイプの判定
  static bool isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 768;
  }
  
  static bool isDesktop(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 1024;
  }
  
  static bool isPhone(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 768;
  }
  
  // 画面サイズに基づくスケールファクター
  static double getScaleFactor(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final diagonal = sqrt(width * width + height * height);
    
    // 対角線サイズに基づいてスケールファクターを計算
    if (diagonal >= 1366) return 1.6; // iPad Pro 12.9"
    if (diagonal >= 1180) return 1.4; // iPad Pro 11"
    if (diagonal >= 1024) return 1.3; // iPad Air/mini
    if (diagonal >= 926) return 1.1;  // iPhone Pro Max
    return 1.0; // 標準サイズ
  }
  
  // フォントサイズのレスポンシブ対応
  static double scaledFontSize(BuildContext context, double baseSize) {
    final scale = getScaleFactor(context);
    return baseSize * scale;
  }
  
  // アイコンやボタンサイズのレスポンシブ対応
  static double scaledSize(BuildContext context, double baseSize) {
    final scale = getScaleFactor(context);
    return baseSize * scale;
  }
  
  // パディングのレスポンシブ対応
  static EdgeInsets scaledPadding(BuildContext context, EdgeInsets basePadding) {
    final scale = getScaleFactor(context);
    return EdgeInsets.fromLTRB(
      basePadding.left * scale,
      basePadding.top * scale,
      basePadding.right * scale,
      basePadding.bottom * scale,
    );
  }
  
  // マージンのレスポンシブ対応
  static EdgeInsets scaledMargin(BuildContext context, EdgeInsets baseMargin) {
    final scale = getScaleFactor(context);
    return EdgeInsets.fromLTRB(
      baseMargin.left * scale,
      baseMargin.top * scale,
      baseMargin.right * scale,
      baseMargin.bottom * scale,
    );
  }
  
  // BorderRadiusのレスポンシブ対応
  static BorderRadius scaledBorderRadius(BuildContext context, BorderRadius baseRadius) {
    final scale = getScaleFactor(context);
    return BorderRadius.circular(baseRadius.topLeft.x * scale);
  }
  
  // SizedBoxのレスポンシブ対応
  static SizedBox scaledSizedBox(BuildContext context, {double? width, double? height}) {
    final scale = getScaleFactor(context);
    return SizedBox(
      width: width != null ? width * scale : null,
      height: height != null ? height * scale : null,
    );
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 画面を縦向きのみに固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
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
      // タブレット(iPad)では文字・アイコン・AppBarの高さなどを包括的に拡大
      builder: (context, child) {
        final theme = Theme.of(context);
        final factor = ResponsiveUtils.getScaleFactor(context); // 1.0 (phone) ~ 1.6 (large iPad)

        // 文字を拡大
        final scaledTextTheme = theme.textTheme.apply(fontSizeFactor: factor);
        final scaledPrimaryTextTheme = theme.primaryTextTheme.apply(fontSizeFactor: factor);

        // アイコンサイズ・AppBarの高さを拡大
        final baseIconSize = theme.iconTheme.size ?? 24;
        final scaledIconTheme = theme.iconTheme.copyWith(size: baseIconSize * factor);
        final scaledPrimaryIconTheme = theme.primaryIconTheme.copyWith(size: (theme.primaryIconTheme.size ?? baseIconSize) * factor);
    final scaledAppBarTheme = theme.appBarTheme.copyWith(
          toolbarHeight: (theme.appBarTheme.toolbarHeight ?? kToolbarHeight) * factor,
          titleTextStyle: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge)?.copyWith(
      fontSize: (theme.textTheme.titleLarge?.fontSize ?? 22) * factor,
      color: theme.colorScheme.primary,
          ),
          actionsIconTheme: (theme.appBarTheme.actionsIconTheme ?? theme.iconTheme).copyWith(
            size: (theme.appBarTheme.actionsIconTheme?.size ?? baseIconSize) * factor,
          ),
          iconTheme: (theme.appBarTheme.iconTheme ?? theme.iconTheme).copyWith(
            size: (theme.appBarTheme.iconTheme?.size ?? baseIconSize) * factor,
          ),
        );

        // IconButtonのデフォルトも拡大
        final baseIconButtonStyle = theme.iconButtonTheme.style ?? const ButtonStyle();
        final scaledIconButtonTheme = IconButtonThemeData(
          style: baseIconButtonStyle.copyWith(
            iconSize: MaterialStateProperty.all<double>(
              (baseIconButtonStyle.iconSize?.resolve({}) ?? baseIconSize) * factor,
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.all(8 * factor),
            ),
          ),
        );

        return Theme(
          data: theme.copyWith(
            textTheme: scaledTextTheme,
            primaryTextTheme: scaledPrimaryTextTheme,
            iconTheme: scaledIconTheme,
            primaryIconTheme: scaledPrimaryIconTheme,
            appBarTheme: scaledAppBarTheme,
            iconButtonTheme: scaledIconButtonTheme,
          ),
          child: child!,
        );
      },
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
                    (!ResponsiveUtils.isTablet(context) && MediaQuery.of(context).orientation == Orientation.landscape)
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: ResponsiveUtils.scaledSize(context, 120),
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                SizedBox(height: ResponsiveUtils.scaledSize(context, 32)),
                                Text(
                                  'つづきのえほん',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtils.scaledFontSize(context, 32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: ResponsiveUtils.scaledSize(context, 16)),
                                Text(
                                  '絵本の続きをあなたの手で',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: ResponsiveUtils.scaledFontSize(context, 18),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: ResponsiveUtils.scaledSize(context, 10)),
                                Container(
                                  padding: ResponsiveUtils.scaledPadding(context, const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: ResponsiveUtils.scaledBorderRadius(context, BorderRadius.circular(24)),
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
                                        size: ResponsiveUtils.scaledSize(context, 20),
                                      ),
                                      SizedBox(width: ResponsiveUtils.scaledSize(context, 8)),
                                      Text(
                                        '画面をタップして始める',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: ResponsiveUtils.scaledFontSize(context, 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: ResponsiveUtils.scaledSize(context, 120),
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                SizedBox(height: ResponsiveUtils.scaledSize(context, 32)),
                                Text(
                                  'つづきのえほん',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtils.scaledFontSize(context, 32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: ResponsiveUtils.scaledSize(context, 16)),
                                Text(
                                  '絵本の続きをあなたの手で',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: ResponsiveUtils.scaledFontSize(context, 18),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: ResponsiveUtils.scaledSize(context, 80)),
                                Container(
                                  padding: ResponsiveUtils.scaledPadding(context, const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: ResponsiveUtils.scaledBorderRadius(context, BorderRadius.circular(24)),
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
                                        size: ResponsiveUtils.scaledSize(context, 20),
                                      ),
                                      SizedBox(width: ResponsiveUtils.scaledSize(context, 8)),
                                      Text(
                                        '画面をタップして始める',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: ResponsiveUtils.scaledFontSize(context, 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    // 下部で左右に動くBOOK WALKINGアニメーション
                    Positioned(
                      bottom: ResponsiveUtils.scaledSize(context, 50),
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
                                width: ResponsiveUtils.scaledSize(context, 100),
                                height: ResponsiveUtils.scaledSize(context, 100),
                                child: Lottie.asset(
                                  'assets/animations/BOOK WALKING.json',
                                  repeat: true,
                                  animate: true,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // フォールバック：本のアイコンが左右に動く
                                    return Icon(
                                      Icons.menu_book,
                                      size: ResponsiveUtils.scaledSize(context, 60),
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
  final genApi = GenerationApi();
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
  ];
  
  static const List<String> _hasStoriesMessages = [
    'あなたの想像力で素敵な物語を\n作ってみましょう！',
    '新しい絵本を作ってみませんか？\n右下のボタンから始められます！',
    '個人情報は入力しないでくださいね！',
    'どんな冒険の物語にしますか？\nワクワクする絵本を作りましょう！',
    'プランをアップグレードして\n色々な絵柄を楽しみましょう！',
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
                  fontSize: ResponsiveUtils.scaledFontSize(context, 14),
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
              size: ResponsiveUtils.scaledSize(context, 24),
            ),
            const SizedBox(width: 8),
            Text('${_currentPlan.displayName}の制限', 
                style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今月の絵本作成回数が上限に達しました。',
                style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
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
                      fontSize: ResponsiveUtils.scaledFontSize(context, 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('月間制限：${_currentPlan.monthlyLimitDisplay}',
                      style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 14))),
                  Text('今月作成済み：${_monthlyUsage.storiesCreated}冊',
                      style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 14))),
                  if (remaining == 0)
                    Text(
                      '残り回数：0回',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.scaledFontSize(context, 14),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('より多くの絵本を作成するには、プランのアップグレードをご検討ください。',
                style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('閉じる', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
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
                              style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16)),
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
    final heroC = TextEditingController();
    final availableStyles = _currentPlan.availableStyles;
    String selectedStyle = availableStyles.first;
    
    // プランに応じたページ数選択肢を生成
    List<int> getAvailablePages() {
      const minPages = 4; // 最小ページ数
      final maxPages = _currentPlan.maxPages;
      return List.generate(maxPages - minPages + 1, (index) => minPages + index);
    }
    
    final availablePages = getAvailablePages();
    int selectedPages = availablePages.contains(_currentPlan.maxPages) 
        ? _currentPlan.maxPages 
        : availablePages.last; // デフォルトは最大ページ数
    const styleSamples = <String, String>{
      '水彩': 'assets/Images/suisai.png',
      '切り絵': 'assets/Images/kirie.png',
      '線画': 'assets/Images/senga.png',
      'クレヨン': 'assets/Images/kureyon.png',
      '写実': 'assets/Images/syazitu.png',
      'ポップアート': 'assets/Images/popart.png',
      'ゆるキャラ': 'assets/Images/yurukyara.png',
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
                left: ResponsiveUtils.isTablet(ctx) ? 32 : 16,
                right: ResponsiveUtils.isTablet(ctx) ? 32 : 16,
                top: ResponsiveUtils.isTablet(ctx) ? 32 : 16,
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
                                                fontSize: ResponsiveUtils.isTablet(ctx) ? 32 : null,
                                              ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            icon: Icon(Icons.casino_outlined, 
                                              size: ResponsiveUtils.isTablet(ctx) ? 32 : 24),
                                            label: Text('ランダム生成',
                                              style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null)),
                                            style: TextButton.styleFrom(
                                              padding: ResponsiveUtils.isTablet(ctx) 
                                                ? EdgeInsets.symmetric(horizontal: 24, vertical: 16) 
                                                : null,
                                            ),
                                            onPressed: () {
                                              final rng = Random();
                                              const sampleTitles = [
                                                'ぼくがロボットになった日',
                                                'おばあちゃんの魔法のレシピ',
                                                '空をとんだカメ',
                                                '消えた月のひみつ',
                                                '雨の日のプレゼント',
                                                'ねむれない夜のぼうけん',
                                                'おしゃべりな時計台',
                                                '森で出会ったふしぎな友だち',
                                                '星を数える少女',
                                                'まほうのスニーカー',
                                                'おかしな動物たちのパーティー',
                                                '夢の中の図書館',
                                                '小さな勇者と大きなドラゴン',
                                                'おひさまの涙',
                                                '風に乗った手紙',
                                                '消えたおもちゃの謎',
                                                '虹色のバスに乗って',
                                                '夜空のダンス',
                                                'ふしぎな絵本屋さん',
                                                '月曜日が消えた！',
                                              ];
                                              const sampleHeros = [
                                                'ゆうた', 'さくら', 'はると', 'りん', 'そら',
                                                'みゆ', 'けんた', 'あかり', 'たいち', 'ひなた',
                                                'れい', 'まこと', 'しおん', 'ゆき', 'かい',
                                                'まい', 'しん', 'あおい', 'ひろ', 'みなみ',
                                              ];
                                              setModalState(() {
                                                titleC.text = sampleTitles[rng.nextInt(sampleTitles.length)];
                                                selectedPages = availablePages[rng.nextInt(availablePages.length)];
                                                selectedStyle = availableStyles[rng.nextInt(availableStyles.length)];
                                                heroC.text = sampleHeros[rng.nextInt(sampleHeros.length)];
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveUtils.isTablet(ctx) ? 16 : 8),
                                        TextFormField(
                                          controller: titleC,
                                          decoration: InputDecoration(
                                            labelText: '絵本タイトル',
                                            labelStyle: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null,
                                          ),
                                          validator: (v) => (v == null || v.trim().isEmpty) ? 'タイトルを入力してください' : null,
                                        ),
                                        SizedBox(height: ResponsiveUtils.isTablet(ctx) ? 16 : 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<int>(
                                                value: selectedPages,
                                                decoration: InputDecoration(
                                                  labelText: 'ページ数',
                                                  labelStyle: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null),
                                                  border: const OutlineInputBorder(),
                                                  isDense: true,
                                                ),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                                                ),
                                                items: availablePages.map((pages) => DropdownMenuItem<int>(
                                                  value: pages,
                                                  child: Text('${pages}ページ',
                                                    style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null)),
                                                )).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    selectedPages = value;
                                                  }
                                                },
                                                validator: (value) {
                                                  if (value == null) return 'ページ数を選択してください';
                                                  return null;
                                                },
                                              ),
                                            ),
                                            SizedBox(width: ResponsiveUtils.isTablet(ctx) ? 24 : 12),
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: selectedStyle,
                                                decoration: InputDecoration(
                                                  labelText: '画風',
                                                  labelStyle: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null),
                                                  border: const OutlineInputBorder(),
                                                  isDense: true,
                                                ),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                                                ),
                                                items: availableStyles
                                                    .map(
                                                      (s) => DropdownMenuItem<String>(
                                                        value: s,
                                                        child: Text(s, 
                                                          style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null)),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (v) => setModalState(() => selectedStyle = v ?? selectedStyle),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: ResponsiveUtils.isTablet(ctx) ? 16 : 8),
                                        TextFormField(
                                          controller: heroC,
                                          decoration: InputDecoration(
                                            labelText: '主人公の名前',
                                            labelStyle: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null,
                                          ),
                                          validator: (v) => (v == null || v.trim().isEmpty) ? '主人公の名前を入力してください' : null,
                                        ),
                                        SizedBox(height: ResponsiveUtils.isTablet(ctx) ? 24 : 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.of(ctx).pop(),
                                                style: OutlinedButton.styleFrom(
                                                  padding: ResponsiveUtils.isTablet(ctx) 
                                                    ? EdgeInsets.symmetric(vertical: 20) 
                                                    : null,
                                                ),
                                                child: Text('キャンセル',
                                                  style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null)),
                                              ),
                                            ),
                                            SizedBox(width: ResponsiveUtils.isTablet(ctx) ? 24 : 12),
                                            Expanded(
                                              child: FilledButton.icon(
                                                icon: Icon(Icons.auto_stories,
                                                  size: ResponsiveUtils.isTablet(ctx) ? 32 : 24),
                                                label: Text('作成',
                                                  style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null)),
                                                style: FilledButton.styleFrom(
                                                  foregroundColor: Colors.black87,
                                                  padding: ResponsiveUtils.isTablet(ctx) 
                                                    ? EdgeInsets.symmetric(vertical: 20) 
                                                    : null,
                                                ),
                                                onPressed: () async {
                                                  if (!(formKey.currentState?.validate() ?? false)) return;
                                                  Navigator.of(context).pop();
                                                  final count = selectedPages;
                                                  final title = titleC.text.trim();
                                                  final hero = heroC.text.trim();

                                                  // モックモード判定（StoryApi の _useMock または SupabaseConfig）
                                                  final useMock = SupabaseConfig.useMockMode;
                                                  if (useMock) {
                                                    // 既存のモック挙動を維持
                                                    final id = DateTime.now().millisecondsSinceEpoch.toString();
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
                                                    final story = Story(id: id, title: title, pages: pages, currentPages: 1);
                                                    await api.createStory(story);
                                                    _incrementUsage();
                                                    if (!mounted) return;
                                                    await Navigator.of(this.context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => StoryDetailPage(story: story, showOnlyFirstPage: true),
                                                      ),
                                                    );
                                                    await _refresh();
                                                    return;
                                                  }

                                                  // 実サーバー呼び出し：ローディング表示
                                                  showDialog(
                                                    context: ctx,
                                                    barrierDismissible: false,
                                                    builder: (_) => Center(
                                                      child: Container(
                                                        width: 200,
                                                        height: 200,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(20),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.1),
                                                              blurRadius: 10,
                                                              spreadRadius: 2,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            const Spacer(),
                                                            SizedBox(
                                                              width: 120,
                                                              height: 120,
                                                              child: Lottie.asset(
                                                                'assets/animations/Book Loader.json',
                                                                repeat: true,
                                                                animate: true,
                                                                fit: BoxFit.contain,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return const CircularProgressIndicator();
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(height: 32),
                                                            const Text(
                                                              '絵本を生成中...',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w500,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );

                                                  try {
                                                    final resp = await genApi.generateFirstPage(
                                                      storyTitle: title,
                                                      totalPages: count,
                                                      artStyle: selectedStyle,
                                                      mainCharacterName: hero,
                                                      userId: SupabaseService.instance.userId ?? '',
                                                    );
                                                    print('API レスポンス受信 (landscape): $resp');
                                                    print('story_id フィールド確認: ${resp['story_id']}');
                                                    print('story_id の型: ${resp['story_id'].runtimeType}');

                    // 期待されるレスポンスに合わせてマッピング
                    final storyId = resp['story_id'] as String?;
                    print('型変換後のstoryId: $storyId');
                    // IDが空の場合のみエラー（形式は問わない）
                    if (storyId == null || storyId.trim().isEmpty) {
                                                      Navigator.of(ctx).pop();
                                                      showDialog(
                                                        context: ctx,
                                                        builder: (_) => AlertDialog(
                                                          title: const Text('エラー'),
                      content: const Text('ストーリーIDの取得に失敗しました。時間をおいて再度お試しください。'),
                                                          actions: [
                                                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('閉じる')),
                                                          ],
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    final pageText = resp['text'] as String? ?? '"$hero"の冒険がはじまる。';
                                                    final imageUrl = resp['image_url'] as String? ?? resp['imageUrl'] as String? ?? '';

                                                    final firstPage = StoryPage(imageUrl: imageUrl, text: pageText);
                                                    final pages = <StoryPage>[firstPage];
                                                    for (int i = 2; i <= count; i++) {
                                                      pages.add(StoryPage(imageUrl: '', text: '$iページ目のテキスト（生成待ち）'));
                                                    }

                                                    final story = Story(id: storyId, title: title, pages: pages, currentPages: 1);

                                                    // 実サーバーではバックエンドで既に作成済みのため、ここでの二重作成は行わない
                                                    _incrementUsage();

                                                    if (!mounted) return;
                                                    Navigator.of(ctx).pop(); // ローディングを閉じる
                                                    await Navigator.of(this.context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => StoryDetailPage(story: story, showOnlyFirstPage: true),
                                                      ),
                                                    );
                                                    await _refresh();
                                                  } catch (e) {
                                                    Navigator.of(ctx).pop(); // ローディングを閉じる
                                                    showDialog(
                                                      context: ctx,
                                                      builder: (_) => AlertDialog(
                                                        title: const Text('生成に失敗しました'),
                                                        content: Text(e.toString()),
                                                        actions: [
                                                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('閉じる')),
                                                        ],
                                                      ),
                                                    );
                                                  }
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
                                            fit: BoxFit.contain,
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
                              icon: Icon(Icons.casino_outlined,
                                size: ResponsiveUtils.isTablet(ctx) ? 32 : 24),
                              label: Text('ランダム生成',
                                style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null)),
                              style: TextButton.styleFrom(
                                padding: ResponsiveUtils.isTablet(ctx) 
                                  ? EdgeInsets.symmetric(horizontal: 24, vertical: 16) 
                                  : null,
                              ),
                              onPressed: () {
                                final rng = Random();
                                const sampleTitles = [
                                  'ぼくがロボットになった日',
                                  'おばあちゃんの魔法のレシピ',
                                  '空をとんだカメ',
                                  '消えた月のひみつ',
                                  '雨の日のプレゼント',
                                  'ねむれない夜のぼうけん',
                                  'おしゃべりな時計台',
                                  '森で出会ったふしぎな友だち',
                                  '星を数える少女',
                                  'まほうのスニーカー',
                                  'おかしな動物たちのパーティー',
                                  '夢の中の図書館',
                                  '小さな勇者と大きなドラゴン',
                                  'おひさまの涙',
                                  '風に乗った手紙',
                                  '消えたおもちゃの謎',
                                  '虹色のバスに乗って',
                                  '夜空のダンス',
                                  'ふしぎな絵本屋さん',
                                  '月曜日が消えた！',
                                ];
                                const sampleHeros = [
                                  'ゆうた', 'さくら', 'はると', 'りん', 'そら',
                                  'みゆ', 'けんた', 'あかり', 'たいち', 'ひなた',
                                  'れい', 'まこと', 'しおん', 'ゆき', 'かい',
                                  'まい', 'しん', 'あおい', 'ひろ', 'みなみ',
                                ];
                                setModalState(() {
                                  titleC.text = sampleTitles[rng.nextInt(sampleTitles.length)];
                                  selectedPages = availablePages[rng.nextInt(availablePages.length)]; // ランダムページ
                                  selectedStyle = availableStyles[rng.nextInt(availableStyles.length)];
                                  heroC.text = sampleHeros[rng.nextInt(sampleHeros.length)];
                                });
                              },
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isTablet(ctx) ? 20 : 12),
                          TextFormField(
                            controller: titleC,
                            decoration: InputDecoration(
                              labelText: '絵本タイトル',
                              labelStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'タイトルを入力してください' : null,
                          ),
                          SizedBox(height: ResponsiveUtils.isTablet(ctx) ? 20 : 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedPages,
                                  decoration: InputDecoration(
                                    labelText: 'ページ数',
                                    labelStyle: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null),
                                    border: const OutlineInputBorder(),
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(ctx).colorScheme.primary,
                                    fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                                  ),
                                  items: availablePages.map((pages) => DropdownMenuItem<int>(
                                    value: pages,
                                    child: Text('${pages}ページ',
                                      style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null)),
                                  )).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectedPages = value;
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null) return 'ページ数を選択してください';
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: ResponsiveUtils.isTablet(ctx) ? 24 : 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedStyle,
                                  decoration: InputDecoration(
                                    labelText: '画風',
                                    labelStyle: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null),
                                    border: const OutlineInputBorder(),
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(ctx).colorScheme.primary,
                                    fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                                  ),
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
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                                                ),
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
                                    fit: BoxFit.contain,
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
                          SizedBox(height: ResponsiveUtils.isTablet(ctx) ? 20 : 12),
                          TextFormField(
                            controller: heroC,
                            decoration: InputDecoration(
                              labelText: '主人公の名前',
                              labelStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: ResponsiveUtils.isTablet(ctx) ? 20 : null,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? '主人公の名前を入力してください' : null,
                          ),
                          SizedBox(height: ResponsiveUtils.isTablet(ctx) ? 24 : 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: ResponsiveUtils.isTablet(ctx) 
                                      ? EdgeInsets.symmetric(vertical: 20) 
                                      : null,
                                  ),
                                  child: Text('キャンセル',
                                    style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null)),
                                ),
                              ),
                              SizedBox(width: ResponsiveUtils.isTablet(ctx) ? 24 : 12),
                              Expanded(
                                child: FilledButton.icon(
                                  icon: Icon(Icons.auto_stories,
                                    size: ResponsiveUtils.isTablet(ctx) ? 32 : 24),
                                  label: Text('作成',
                                    style: TextStyle(fontSize: ResponsiveUtils.isTablet(ctx) ? 22 : null)),
                                  style: FilledButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                    padding: ResponsiveUtils.isTablet(ctx) 
                                      ? EdgeInsets.symmetric(vertical: 20) 
                                      : null,
                                  ),
                                  onPressed: () async {
                                    if (!(formKey.currentState?.validate() ?? false)) return;
                                    Navigator.of(ctx).pop();

                                    final count = selectedPages;
                                    final title = titleC.text.trim();
                                    final hero = heroC.text.trim();

                                    final useMock = SupabaseConfig.useMockMode;
                                    if (useMock) {
                                      final id = DateTime.now().millisecondsSinceEpoch.toString();
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

                                      final story = Story(id: id, title: title, pages: pages, currentPages: 1);
                                      await api.createStory(story);
                                      _incrementUsage();
                                      if (!mounted) return;
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => StoryDetailPage(story: story, showOnlyFirstPage: true),
                                        ),
                                      );
                                      await _refresh();
                                      return;
                                    }

                                    // 実サーバー呼び出し
                                    late BuildContext dialogContext;
                                    showDialog(
                                      context: ctx,
                                      barrierDismissible: false,
                                      builder: (dctx) {
                                        dialogContext = dctx;
                                        return Center(
                                          child: Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                const Spacer(),
                                                SizedBox(
                                                  width: 120,
                                                  height: 120,
                                                  child: Lottie.asset(
                                                    'assets/animations/Book Loader.json',
                                                    repeat: true,
                                                    animate: true,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return const CircularProgressIndicator();
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 32),
                                                const Text(
                                                  '絵本を生成中...',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    try {
                                      print('絵本生成開始: title=$title, count=$count, style=$selectedStyle, hero=$hero');
                                      final resp = await genApi.generateFirstPage(
                                        storyTitle: title,
                                        totalPages: count,
                                        artStyle: selectedStyle,
                                        mainCharacterName: hero,
                                        userId: SupabaseService.instance.userId ?? '',
                                      );
                                      print('API レスポンス受信: $resp');
                                      print('story_id フィールド確認: ${resp['story_id']}');
                                      print('story_id の型: ${resp['story_id'].runtimeType}');

              final storyId = resp['story_id'] as String?;
              print('型変換後のstoryId: $storyId');
              if (storyId == null || storyId.trim().isEmpty) {
                                        if (Navigator.canPop(dialogContext)) {
                                          Navigator.of(dialogContext).pop();
                                        }
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('エラー'),
                content: const Text('ストーリーIDの取得に失敗しました。時間をおいて再度お試しください。'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('閉じる')),
                                            ],
                                          ),
                                        );
                                        return;
                                      }
                                      final pageText = resp['text'] as String? ?? '"$hero"の冒険がはじまる。';
                                      final imageUrl = resp['image_url'] as String? ?? resp['imageUrl'] as String? ?? '';

                                      final firstPage = StoryPage(imageUrl: imageUrl, text: pageText);
                                      final pages = <StoryPage>[firstPage];
                                      for (int i = 2; i <= count; i++) {
                                        pages.add(StoryPage(imageUrl: '', text: '$iページ目のテキスト（生成待ち）'));
                                      }

                                      final story = Story(id: storyId, title: title, pages: pages, currentPages: 1);
                                      // 実サーバーではバックエンドで既に作成済みのため、ここでの二重作成は行わない
                                      _incrementUsage();

                                      // ローディングダイアログを確実に閉じる
                                      if (Navigator.canPop(dialogContext)) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                      
                                      if (!mounted) return;
                                      
                                      print('詳細画面への遷移開始');
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => StoryDetailPage(story: story, showOnlyFirstPage: true),
                                        ),
                                      );

                                      await _refresh();
                                      print('絵本作成処理完了');
                                    } catch (e) {
                                      print('絵本生成エラー: $e');
                                      // ローディングダイアログを確実に閉じる
                                      if (Navigator.canPop(dialogContext)) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                      
                                      if (!mounted) return;
                                      
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('生成に失敗しました'),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('閉じる')),
                                          ],
                                        ),
                                      );
                                    }
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
            ? Text(
                '${_selectedStoryIds.length}冊選択中',
                style: TextStyle(
                  fontSize: ResponsiveUtils.scaledFontSize(context, 18),
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Text(
                '絵本一覧',
                style: TextStyle(
                  fontSize: ResponsiveUtils.scaledFontSize(context, 18),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
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
                    padding: ResponsiveUtils.isTablet(context)
                        ? EdgeInsets.all(10)
                        : EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE74C3C),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: const Color(0xFFE74C3C),
                      size: ResponsiveUtils.isTablet(context) ? 32 : 20,
                    ),
                  ),
                  onPressed: _selectedStoryIds.isNotEmpty ? _showBulkDeleteDialog : null,
                ),
              ]
            : [
                IconButton(
                  tooltip: _useGrid ? 'リスト表示' : 'グリッド表示',
                  icon: Container(
                    padding: ResponsiveUtils.isTablet(context)
                        ? EdgeInsets.all(10)
                        : EdgeInsets.all(6),
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
                      size: ResponsiveUtils.isTablet(context) ? 32 : 18,
                    ),
                  ),
                  onPressed: () => setState(() => _useGrid = !_useGrid),
                ),
                SizedBox(width: ResponsiveUtils.isTablet(context) ? 16 : 8),
                IconButton(
                  tooltip: '選択モード',
                  icon: Container(
                    padding: ResponsiveUtils.isTablet(context)
                        ? EdgeInsets.all(10)
                        : EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF39C12).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF39C12),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.checklist,
                      color: const Color(0xFFF39C12),
                      size: ResponsiveUtils.isTablet(context) ? 32 : 18,
                    ),
                  ),
                  onPressed: () => setState(() => _isSelectionMode = true),
                ),
              ],
      ),
      drawer: Drawer(
        width: ResponsiveUtils.isTablet(context)
            ? min(MediaQuery.of(context).size.width * 0.42, 440)
            : null,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: ResponsiveUtils.isTablet(context)
                  ? ResponsiveUtils.scaledSize(context, 170) // iPadでは280
                  : ResponsiveUtils.scaledSize(context, 220), // iPhoneでは200
              child: DrawerHeader(
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
                    size: ResponsiveUtils.scaledSize(context, 56),
                    color: Colors.white,
                  ),
                  SizedBox(height: ResponsiveUtils.scaledSize(context, 8)),
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
                  SizedBox(height: ResponsiveUtils.scaledSize(context, 6)),
                ],
              ),
            ),
            ),
            ListTile(
              leading: Icon(Icons.home, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text('ホーム', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.add, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text('新しい絵本を作成', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () {
                Navigator.pop(context);
                _openCreateDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text('更新', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () {
                Navigator.pop(context);
                _refresh();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.payment, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text('プラン', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlanPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(_useGrid ? Icons.view_list : Icons.grid_view, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text(_useGrid ? 'リスト表示' : 'グリッド表示', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () {
                Navigator.pop(context);
                setState(() => _useGrid = !_useGrid);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.description, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text('利用規約', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text('プライバシーポリシー', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.copyright, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text('ライセンス', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const license.LicensePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_support, size: ResponsiveUtils.scaledSize(context, 26)),
              title: Text('お問い合わせ', style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16))),
              onTap: () async {
                Navigator.pop(context);
                const url = 'https://docs.google.com/forms/d/e/1FAIpQLScv4f9gdeP6beH3uAepL0k82HO6gbnRp-B16-JvR344ZWk_sg/viewform?usp=header'; // ここに実際のお問い合わせURLを設定
                try {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('URLを開けませんでした')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('エラーが発生しました: $e')),
                    );
                  }
                }
              },
            ),
            // ユーザーIDをライセンスの下に表示（小さく薄い色、アイコンなし）
            ListTile(
              title: Text(
                'ユーザーID: ${SupabaseService.instance.userId ?? "-"}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.withOpacity(0.65),
                  fontSize: ResponsiveUtils.scaledFontSize(context, 12),
                ),
              ),
              onTap: () {
                // タップでドロワーを閉じる
                Navigator.pop(context);
              },
              onLongPress: () async {
                // 長押しでユーザーIDをコピー
                final id = SupabaseService.instance.userId ?? '-';
                await Clipboard.setData(ClipboardData(text: id));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ユーザーIDをコピーしました')),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false, // 底部のSafeAreaを無効にして手動で調整
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
                                  fontSize: ResponsiveUtils.isTablet(context) ? 20 : 13,
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
                                    fontSize: ResponsiveUtils.isTablet(context) ? 16 : 10,
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
                                    fontSize: ResponsiveUtils.isTablet(context) ? 20 : 10,
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
                              // iPhoneでのオーバーフロー対策：底部余白を増加
                              MediaQuery.of(context).orientation == Orientation.landscape 
                                  ? MediaQuery.of(context).padding.bottom + 130  // 横向き時
                                  : MediaQuery.of(context).padding.bottom + 180  // 縦向き時（iPhoneで余白を増やす）
                            ),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isLandscape ? 4 : 2, // 横向き時は4列
                              mainAxisSpacing: isLandscape ? 8 : 12, // 横向き時は間隔を狭く
                              crossAxisSpacing: isLandscape ? 8 : 12, // 横向き時は間隔を狭く
                              childAspectRatio: ResponsiveUtils.isTablet(context)
                                  ? (isLandscape ? 0.85 : 0.9) // iPad用：従来通り
                                  : (isLandscape ? 0.75 : 0.75), // iPhone用：より縦長に
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
                                        flex: 1, // flexを明示的に指定
                                        child: Padding(
                                          padding: EdgeInsets.all(isLandscape ? 6 : 8), // 横向き時はパディングを小さく
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min, // 最小サイズに
                                            children: [
                                              // タイトル部分
                                              Flexible( // Expandedから変更
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
                                                        fontSize: ResponsiveUtils.isTablet(context)
                                                            ? (isLandscape ? 18 : 22) // iPad用サイズ
                                                            : (isLandscape ? 12 : 14), // フォントサイズを調整
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: isLandscape ? 3 : 6), // 間隔を調整
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
                                                          size: ResponsiveUtils.isTablet(context) 
                                                              ? (isLandscape ? 16 : 18)
                                                              : (isLandscape ? 8 : 10),
                                                          color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                              ? Colors.orange.shade700
                                                              : Colors.green.shade700,
                                                        ),
                                                        SizedBox(width: ResponsiveUtils.isTablet(context)
                                                            ? (isLandscape ? 3 : 4)
                                                            : (isLandscape ? 1 : 2)),
                                                        Text(
                                                          s.pages.any((p) => p.text.contains('生成待ち'))
                                                              ? '作成中'
                                                              : '完成',
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                                ? Colors.orange.shade700
                                                                : Colors.green.shade700,
                                                            fontSize: ResponsiveUtils.isTablet(context)
                                                                ? (isLandscape ? 14 : 16)
                                                                : (isLandscape ? 8 : 9),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Icon(
                                                    Icons.book,
                                                    size: ResponsiveUtils.isTablet(context)
                                                        ? (isLandscape ? 18 : 20)
                                                        : (isLandscape ? 10 : 12), // 横向き時はアイコンを小さく
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  SizedBox(width: ResponsiveUtils.isTablet(context)
                                                      ? (isLandscape ? 4 : 6)
                                                      : (isLandscape ? 2 : 4)), // 横向き時は間隔を狭く
                                                  Text(
                                                    '${s.pages.length}ページ',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey.shade600,
                                                      fontSize: ResponsiveUtils.isTablet(context)
                                                          ? (isLandscape ? 16 : 18)
                                                          : (isLandscape ? 10 : 11), // 横向き時はフォントサイズを小さく
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
                                ? MediaQuery.of(context).padding.bottom + 110  // 横向き時はSafeArea + キャラクター分
                                : MediaQuery.of(context).padding.bottom + 180 // 縦向き時（iPhoneで余白を増やす）
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final s = data[i];
                            final isSelected = _selectedStoryIds.contains(s.id);
                            final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                            
                            return Card(
                              margin: ResponsiveUtils.scaledMargin(context, EdgeInsets.symmetric(
                                horizontal: 12, 
                                vertical: isLandscape ? 3 : 6, // 横向き時は縦マージンを小さく
                              )),
                              shape: RoundedRectangleBorder(borderRadius: ResponsiveUtils.scaledBorderRadius(context, BorderRadius.circular(20))),
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
                                  padding: ResponsiveUtils.scaledPadding(context, EdgeInsets.all(isLandscape ? 8 : 16)), // レスポンシブ対応
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // 左側：画像（横向き時はサイズを小さく）
                                      ClipRRect(
                                        borderRadius: ResponsiveUtils.scaledBorderRadius(context, BorderRadius.circular(12)),
                                        child: SizedBox(
                                          width: ResponsiveUtils.scaledSize(context, isLandscape ? 60 : 80),  // レスポンシブ対応
                                          height: ResponsiveUtils.scaledSize(context, isLandscape ? 45 : 60), // レスポンシブ対応
                                          child: Image.network(
                                            s.pages.isNotEmpty ? s.pages[0].imageUrl : 'https://picsum.photos/seed/default/80/60',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.menu_book,
                                                  color: Theme.of(context).colorScheme.primary,
                                                  size: ResponsiveUtils.scaledSize(context, isLandscape ? 24 : 32), // レスポンシブ対応
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: ResponsiveUtils.scaledSize(context, isLandscape ? 12 : 16)), // レスポンシブ対応
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
                                                    fontSize: ResponsiveUtils.scaledFontSize(context, isLandscape ? 14 : 16), // レスポンシブ対応
                                                  ),
                                                  maxLines: isLandscape ? 1 : 2, // 横向き時は1行のみ
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: ResponsiveUtils.scaledSize(context, isLandscape ? 3 : 6)), // レスポンシブ対応
                                            // ステータスタグとページ数情報
                                            Row(
                                              children: [
                                                // ステータスタグ
                                                Container(
                                                  padding: ResponsiveUtils.scaledPadding(context, EdgeInsets.symmetric(
                                                    horizontal: isLandscape ? 4 : 6, 
                                                    vertical: isLandscape ? 1 : 2,
                                                  )),
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
                                                        size: ResponsiveUtils.isTablet(context)
                                                            ? (isLandscape ? 16 : 18)
                                                            : (isLandscape ? 10 : 12),
                                                        color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                            ? Colors.orange.shade700
                                                            : Colors.green.shade700,
                                                      ),
                                                      SizedBox(width: ResponsiveUtils.isTablet(context)
                                                          ? (isLandscape ? 4 : 5)
                                                          : (isLandscape ? 2 : 3)),
                                                      Text(
                                                        s.pages.any((p) => p.text.contains('生成待ち'))
                                                            ? '作成中'
                                                            : '完成',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: s.pages.any((p) => p.text.contains('生成待ち'))
                                                              ? Colors.orange.shade700
                                                              : Colors.green.shade700,
                                                          fontSize: ResponsiveUtils.isTablet(context)
                                                              ? (isLandscape ? 15 : 17)
                                                              : (isLandscape ? 9 : 10),
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
                                                        size: ResponsiveUtils.isTablet(context)
                                                            ? (isLandscape ? 16 : 18)
                                                            : (isLandscape ? 10 : 12),
                                                        color: Theme.of(context).colorScheme.primary,
                                                      ),
                                                      SizedBox(width: ResponsiveUtils.isTablet(context)
                                                          ? (isLandscape ? 4 : 5)
                                                          : (isLandscape ? 2 : 3)),
                                                      Text(
                                                        '${s.pages.length}ページ',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.primary,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: ResponsiveUtils.isTablet(context)
                                                              ? (isLandscape ? 15 : 17)
                                                              : (isLandscape ? 9 : 10),
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
        // 下部のBook.jsonキャラクターと吹き出し（絵本生成ボタンの上に配置）
        Positioned(
          // iPhoneでの底部オーバーフロー対策：位置を上げる
          bottom: ResponsiveUtils.scaledSize(context, 100), // 絵本生成ボタンから十分離す
          left: 0,
          right: 0,
          child: FutureBuilder<List<Story>>(
            future: _future,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              final data = _applyFilter(items);
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.end, // 常に右端に配置
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 吹き出し（左側）
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7, // 画面幅の70%まで（大きく）
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentMessage = _getRandomMessage(data.isNotEmpty);
                        });
                      },
                          child: Container(
                        margin: EdgeInsets.only(bottom: ResponsiveUtils.scaledSize(context, 4)),
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.scaledSize(context, 14),
                          vertical: ResponsiveUtils.scaledSize(context, 10),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14), // 角を統一
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6, // シャドウを統一
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: ResponsiveUtils.scaledSize(context, 4)),
                              child: Text(
                                _currentMessage.isEmpty 
                                    ? _getRandomMessage(data.isNotEmpty)
                                    : _currentMessage,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.3,
                                  fontSize: ResponsiveUtils.scaledFontSize(context, 13),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -ResponsiveUtils.scaledSize(context, 3),
                              right: ResponsiveUtils.scaledSize(context, 8), // 右側にしっぽを配置
                              child: CustomPaint(
                                size: Size(ResponsiveUtils.scaledSize(context, 12), ResponsiveUtils.scaledSize(context, 6)),
                                painter: SpeechBubbleTail(), // 通常のしっぽを使用
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.scaledSize(context, 8)), // 吹き出しとキャラクターの間隔
                  // Book.jsonアニメーション（右端に配置、左右反転）
                  Container(
                    margin: EdgeInsets.only(right: ResponsiveUtils.scaledSize(context, 16)), // 画面端からの余白
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0), // 左右反転
                      child: SizedBox(
                        width: ResponsiveUtils.scaledSize(context, 80),
                        height: ResponsiveUtils.scaledSize(context, 80),
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
                                      size: ResponsiveUtils.scaledSize(context, 40),
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
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ],
      ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: ResponsiveUtils.isTablet(context)
              ? MediaQuery.of(context).padding.bottom + 8
              : MediaQuery.of(context).padding.bottom - 30, // iPhoneの時は余白を増やす
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF39C12),
                const Color(0xFFE74C3C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: ResponsiveUtils.scaledBorderRadius(context, BorderRadius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF39C12).withValues(alpha: 0.4),
                blurRadius: ResponsiveUtils.scaledSize(context, 12),
                offset: Offset(0, ResponsiveUtils.scaledSize(context, 4)),
              ),
            ],
          ),
          child: SizedBox(
            width: (!ResponsiveUtils.isTablet(context) && MediaQuery.of(context).orientation == Orientation.landscape)
                ? 120
                : ResponsiveUtils.scaledSize(context, 180),
            height: ResponsiveUtils.isTablet(context) 
                ? 80 
                : (!ResponsiveUtils.isTablet(context) && MediaQuery.of(context).orientation == Orientation.landscape)
                    ? 56   // iPhone横向き時は少し小さく
                    : null,
            child: FloatingActionButton.extended(
              onPressed: canCreateStory() ? _openCreateDialog : () {
                _showPlanLimitDialog();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: SizedBox(
                width: ResponsiveUtils.isTablet(context) 
                    ? 72 
                    : (!ResponsiveUtils.isTablet(context) && MediaQuery.of(context).orientation == Orientation.landscape)
                        ? 24  // iPhone横向き時は小さく
                        : 32,
                height: ResponsiveUtils.isTablet(context) 
                    ? 72 
                    : (!ResponsiveUtils.isTablet(context) && MediaQuery.of(context).orientation == Orientation.landscape)
                        ? 24  // iPhone横向き時は小さく
                        : 32,
                child: Lottie.asset(
                  'assets/animations/Paint Brush.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // アニメーションファイルが見つからない場合のフォールバック
                    return Icon(
                      Icons.brush,
                      color: Colors.white,
                      size: ResponsiveUtils.isTablet(context) 
                          ? 48 
                          : (!ResponsiveUtils.isTablet(context) && MediaQuery.of(context).orientation == Orientation.landscape)
                              ? 18  // iPhone横向き時は小さく
                              : 24,
                    );
                  },
                ),
              ),
              label: Text(
                '絵本作成',
                style: GoogleFonts.mPlusRounded1c(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.isTablet(context) 
                      ? 28 
                      : (!ResponsiveUtils.isTablet(context) && MediaQuery.of(context).orientation == Orientation.landscape)
                          ? 14  // iPhone横向き時は小さく
                          : 16,
                ),
              ),
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
  late int _currentPageForInput;
  // 完了済みの最終ページ（0-based）。current_pages が null の場合は全ページ閲覧可とみなす
  int get _lastCompletedIndex {
    final pagesLen = widget.story.pages.length;
    final cp = _currentPageForInput; // 1-based（そのページまで移動可）
    final n = cp - 1; // 1-based -> 0-based
    if (n < 0) return 0;
    if (n >= pagesLen) return pagesLen - 1;
    return n;
  }

  @override
  void initState() {
    super.initState();
    // 入力対象ページ（1-based）
    _currentPageForInput = (widget.story.currentPages != null && widget.story.currentPages! > 0)
        ? widget.story.currentPages!
        : 1;
    _currentPageForInput = _currentPageForInput.clamp(1, widget.story.pages.length);
    // showOnlyFirstPageの場合は最初のページ（インデックス0）から開始
    // 続きから作成の場合は、最初の生成待ちページから開始
    if (widget.showOnlyFirstPage) {
      // current_pages が指定されていればそのページから開始（1-based -> 0-based）
      if (_currentPageForInput > 0) {
        final idx = _currentPageForInput - 1;
        _currentIndex = idx.clamp(0, widget.story.pages.length - 1);
      } else {
        // フォールバック: 最初の生成待ちの1つ前
        final pages = widget.story.pages;
        _currentIndex = 0;
        for (int i = 0; i < pages.length; i++) {
          if (pages[i].text.contains('生成待ち')) {
            _currentIndex = i > 0 ? i - 1 : 0;
            break;
          }
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
                                  // 前/次 ナビゲーション（作成中でも前ページに戻って見られる）
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _currentIndex > 0
                                            ? () => setState(() => _currentIndex -= 1)
                                            : null,
                                        icon: const Icon(Icons.chevron_left),
                                        tooltip: '前のページ',
                                      ),
                                      Text(
                                        '${_currentIndex + 1} / ${widget.story.pages.length}',
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                      IconButton(
                                        onPressed: _currentIndex < _lastCompletedIndex
                                            ? () => setState(() => _currentIndex += 1)
                                            : null,
                                        icon: const Icon(Icons.chevron_right),
                                        tooltip: '次のページ',
                                      ),
                                    ],
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
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: (_currentIndex == 0 || widget.story.pages[_currentIndex].text.contains('生成待ち'))
                                                  ? Colors.grey.shade600
                                                  : Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                      // 入力フォーム: 現在ページ(1-based) が入力対象ページ と一致 かつ 最終ページ以外
                      if ((_currentIndex + 1) == _currentPageForInput &&
                        _currentIndex < widget.story.pages.length - 1)
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
                    // 完成ボタン: 最終ページインデックス かつ プレースホルダー が残り かつ 入力対象ページが最終ページ番号 の場合
                    if (_currentIndex == widget.story.pages.length - 1 &&
                      widget.story.pages[_currentIndex].text.contains('生成待ち') &&
                      (_currentIndex + 1) == _currentPageForInput)
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
                        // 縦向き：スクロール可能レイアウト
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 前/次 ナビゲーション（作成中でも前ページに戻って見られる）
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _currentIndex > 0
                                        ? () => setState(() => _currentIndex -= 1)
                                        : null,
                                    icon: const Icon(Icons.chevron_left),
                                    tooltip: '前のページ',
                                  ),
                                  Text(
                                    '${_currentIndex + 1} / ${widget.story.pages.length}',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  IconButton(
                                    onPressed: _currentIndex < _lastCompletedIndex
                                        ? () => setState(() => _currentIndex += 1)
                                        : null,
                                    icon: const Icon(Icons.chevron_right),
                                    tooltip: '次のページ',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // 画像表示
                              AspectRatio(
                                aspectRatio: 4 / 3,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  widget.story.pages[_currentIndex].text,
                                  style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if ((_currentIndex + 1) == _currentPageForInput &&
                                  _currentIndex < widget.story.pages.length - 1) ...[
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
                              // 最後のページで「完成」ボタンを表示
                              if (hasPlaceholder && _currentIndex == widget.story.pages.length - 1) ...[
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
                              // 絵本完成後のボタン表示
                              if (!hasPlaceholder && _showPreviewAfterFinish) ...[
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
                              // 画面下部に余白を追加（セーフエリア対応）
                              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                            ],
                          ),
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
                                  onPressed: _currentIndex < _lastCompletedIndex
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
                      itemCount: _lastCompletedIndex + 1,
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
                                                          style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16)),
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
                                                      style: TextStyle(fontSize: ResponsiveUtils.scaledFontSize(context, 16)),
                                                      textAlign: TextAlign.center,
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
    final storyId = widget.story.id;
    final userId = SupabaseService.instance.userId ?? '';
    final nextPageNumber = _currentIndex + 2; // 1-based 次ページ

    // storyIdの有無のみチェック（形式はバックエンドで検証）
    if (storyId.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('ストーリーIDが未取得です'),
          content: const Text('絵本一覧に戻ってから再度お試しください。'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('閉じる')),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.asset(
                  'assets/animations/Book Loader.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircularProgressIndicator();
                  },
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '次のページを生成中...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    GenerationApi genApi = GenerationApi();
    genApi.generateNextPage(
      storyId: storyId,
      pageNumber: nextPageNumber,
      userInput: v,
      userId: userId,
    ).then((resp) async {
      final imageUrl = resp['image_url'] as String? ?? resp['imageUrl'] as String? ?? '';
      final text = resp['text'] as String? ?? v; // サーバー生成テキスト、なければ入力

      setState(() {
        final pages = widget.story.pages;
        final targetIndex = nextPageNumber - 1;
        if (targetIndex < pages.length && pages[targetIndex].text.contains('生成待ち')) {
          pages[targetIndex] = StoryPage(imageUrl: imageUrl, text: text);
          _currentIndex = targetIndex;
        }
        // 入力対象ページを次に進める
        _currentPageForInput = nextPageNumber.clamp(1, widget.story.pages.length);
        final hasRemainingPlaceholder = pages.any((p) => p.text.contains('生成待ち'));
        if (!hasRemainingPlaceholder) {
          _showPreviewAfterFinish = true;
        }
        _nextController.clear();
      });

      // DB更新（current_pageも更新）
      final updated = Story(
        id: widget.story.id,
        title: widget.story.title,
        pages: widget.story.pages,
        totalPages: widget.story.totalPages,
        isCompletedFromDb: widget.story.isCompletedFromDb,
        currentPages: _currentPageForInput,
      );
      await StoryApi().updateStory(updated);
      if (mounted) Navigator.of(context).pop();
    }).catchError((e) {
      if (mounted) Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('ページ生成に失敗しました'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('閉じる')),
          ],
        ),
      );
    });
  }
}

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    try {
      final userId = SupabaseService.instance.userId ?? 'anonymous';
      await _purchaseService.initialize(userId);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize purchase service: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プラン', style: TextStyle(
          fontSize: ResponsiveUtils.isTablet(context) ? 26 : null,
        )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            // 横向き：3つのプランを横並びで表示
            return Padding(
              padding: EdgeInsets.all(ResponsiveUtils.isTablet(context) ? 24 : 12),
              child: Column(
                children: [
                  // タイトル部分
                  Text(
                    '絵本生成プラン',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.isTablet(context) ? 32 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveUtils.isTablet(context) ? 8 : 2),
                  Text(
                    'あなたに最適なプランをお選びください',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: ResponsiveUtils.isTablet(context) ? 22 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveUtils.isTablet(context) ? 16 : 8),
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
                              '月1回まで',
                              '最大4ページ',
                              '基本画風',
                              '最大3冊保存',
                            ],
                            isPopular: false,
                            buttonText: '現在のプラン',
                            onTap: null,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.isTablet(context) ? 12 : 6),
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
                        SizedBox(width: ResponsiveUtils.isTablet(context) ? 12 : 6),
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
              padding: EdgeInsets.all(ResponsiveUtils.isTablet(context) ? 24 : 12),
              child: Column(
                children: [
                  // タイトル部分
                  Text(
                    '絵本生成プラン',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.isTablet(context) ? 36 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveUtils.isTablet(context) ? 8 : 2),
                  Text(
                    'あなたに最適なプランをお選びください',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: ResponsiveUtils.isTablet(context) ? 24 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveUtils.isTablet(context) ? 16 : 8),
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
                              '絵本作成：月1回まで',
                              'ページ数：最大4ページ',
                              '画風：基本2画風のみ',
                              '保存：最大3冊まで',
                            ],
                            isPopular: false,
                            buttonText: '現在のプラン',
                            onTap: null,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.isTablet(context) ? 12 : 6),
                        Expanded(
                          child: _buildCompactPlanCard(
                            context,
                            title: 'ベーシックプラン',
                            price: '¥780',
                            period: '/月',
                            features: [
                              '絵本作成：月5回まで',
                              'ページ数：最大6ページ',
                              '画風：基本2画風＋追加2画風',
                              '保存：最大15冊まで',
                            ],
                            isPopular: true,
                            buttonText: 'プラン選択',
                            onTap: () => _showSubscriptionDialog(context, 'ベーシックプラン'),
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.isTablet(context) ? 12 : 6),
                        Expanded(
                          child: _buildCompactPlanCard(
                            context,
                            title: 'プレミアムプラン',
                            price: '¥1,680',
                            period: '/月',
                            features: [
                              '絵本作成：月10回まで',
                              'ページ数：最大8ページ',
                              '画風：基本2画風＋追加4画風',
                              '保存：無制限',
                            ],
                            isPopular: false,
                            buttonText: 'プラン選択',
                            onTap: () => _showSubscriptionDialog(context, 'プレミアムプラン'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 購入復元ボタン
                  Center(
                    child: TextButton(
                      onPressed: _restorePurchases,
                      child: const Text(
                        '購入履歴を復元',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
                    fontSize: ResponsiveUtils.isTablet(context) ? 16 : 10,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.isTablet(context) ? 12 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.isTablet(context) ? 22 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.isTablet(context) ? 4 : 2),
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
                        fontSize: ResponsiveUtils.isTablet(context) ? 26 : null,
                      ),
                    ),
                    if (period.isNotEmpty)
                      Text(
                        period,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: ResponsiveUtils.isTablet(context) ? 18 : null,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.isTablet(context) ? 8 : 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: features.map((feature) => Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveUtils.isTablet(context) ? 4 : 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: ResponsiveUtils.isTablet(context) ? 20 : 14,
                          ),
                          SizedBox(width: ResponsiveUtils.isTablet(context) ? 6 : 4),
                          Expanded(
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: ResponsiveUtils.isTablet(context) ? 17 : 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.isTablet(context) ? 8 : 4),
                SizedBox(
                  height: ResponsiveUtils.isTablet(context) ? 50 : 32,
                  child: onTap != null
                      ? FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: isPopular 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.isTablet(context) ? 12 : 6),
                          ),
                          child: Text(
                            buttonText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.isTablet(context) ? 18 : 11,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.isTablet(context) ? 12 : 6),
                          ),
                          child: Text(
                            buttonText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: ResponsiveUtils.isTablet(context) ? 18 : 11,
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

  Future<void> _showSubscriptionDialog(BuildContext context, String planName) async {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('課金サービスを初期化中です...')),
      );
      return;
    }

    if (_errorMessage != null) {
      // ログにもエラー内容を出力
      debugPrint('購入サービス初期化エラー: $_errorMessage');
      print('購入サービス初期化エラー: $_errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $_errorMessage')),
      );
      return;
    }

    // プロダクトIDのマッピング
    String? productId;
    if (planName == 'ベーシックプラン') {
      productId = PurchaseService.basicPlanId;
    } else if (planName == 'プレミアムプラン') {
      productId = PurchaseService.premiumPlanId;
    }

    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無効なプランです')),
      );
      return;
    }

    final product = _purchaseService.getProduct(productId);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロダクトが見つかりません')),
      );
      return;
    }

    // 購入確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$planName を購入'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('プラン: $planName'),
            Text('価格: ${product.price}'),
            const SizedBox(height: 16),
            const Text('購入しますか？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('購入'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processPurchase(productId, planName);
    }
  }

  Future<void> _processPurchase(String productId, String planName) async {
    try {
      // ローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('購入処理中...'),
            ],
          ),
        ),
      );

      final success = await _purchaseService.startPurchase(productId);
      
      if (mounted) {
        Navigator.pop(context); // ローディングダイアログを閉じる
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$planName の購入処理を開始しました')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('購入処理に失敗しました')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // ローディングダイアログを閉じる
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  void _restorePurchases() async {
    try {
      await _purchaseService.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購入復元を試行しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('購入復元に失敗しました: $e')),
        );
      }
    }
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