import '../models/story.dart';
import '../services/supabase_service.dart';
import '../config/supabase_config.dart';

class StoryApi {

  Future<void> updateStory(Story story) async {
    final supabase = SupabaseService.instance;
    if (_useMock || SupabaseConfig.useMockMode) {
      // モック: 既存ストーリーを上書き
      final idx = _mockStories.indexWhere((s) => s.id == story.id);
      if (idx >= 0) {
        _mockStories[idx] = story;
      }
      return;
    }
    try {
      await supabase.logAction('update_story', {
        'story_id': story.id,
        'title': story.title,
        'pages_count': story.pages.length,
        'source': 'supabase',
      });
      final storyData = story.toJson();
      storyData['user_id'] = supabase.userId;
      await supabase.client!
          .from(SupabaseConfig.storiesTable)
          .update(storyData)
          .eq('id', story.id)
          .eq('user_id', supabase.userId!);
    } catch (e) {
      print('Error updating story in Supabase: $e');
    }
  }
  StoryApi({String? baseUrl, bool useMock = false})
      : baseUrl = baseUrl ?? 'http://127.0.0.1:8000/api/v1',
        _useMock = useMock;

  final String baseUrl;
  final bool _useMock;

  // モックデータ
  static final List<Story> _mockStories = [];

  /// If [useFilter] is false, skip the user_id filter (debug only).
  Future<List<Story>> listStories({bool useFilter = true}) async {
    final supabase = SupabaseService.instance;
    
    if (_useMock || SupabaseConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));

      // ログ記録（モック環境）
      try {
        await supabase.logAction('list_stories', {
          'mock_mode': true,
          'stories_count': _mockStories.length,
        });
      } catch (e) {
        print('Error logging action: $e');
      }

      // 初回のみサンプルデータを追加
      if (_mockStories.isEmpty) {
        _mockStories.addAll([
          Story(
            id: '1',
            title: 'はじめての絵本',
            pages: [
              StoryPage(
                imageUrl: 'https://picsum.photos/seed/sample1/800/500',
                text: 'むかしむかし、ある森に小さなウサギが住んでいました。',
              ),
              StoryPage(
                imageUrl: 'https://picsum.photos/seed/sample2/800/500',
                text: 'ウサギは毎日、森の中を散歩するのが大好きでした。',
              ),
            ],
          ),
        ]);
      }

      return List.from(_mockStories);
    }
    
    try {
      // 実際のSupabaseから取得
      await supabase.logAction('list_stories', {
        'source': 'supabase',
      });
      
  final query = supabase.client!
    .from(SupabaseConfig.storiesTable)
    .select('*, pages(*)');
  final response = await (useFilter
    ? query.eq('user_id', supabase.userId!).order('created_at', ascending: false)
    : query.order('created_at', ascending: false));

      // Debugging: print user id and raw response so developer can inspect what's returned
      try {
        print('StoryApi.listStories: userId=${supabase.userId}');
        print('StoryApi.listStories: rawResponse type=${response.runtimeType}');
        print('StoryApi.listStories: rawResponse=$response');
      } catch (e) {
        // ignore logging errors
      }

      try {
        final list = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        return list.map((json) => Story.fromJson(json)).toList();
      } catch (e) {
        print('StoryApi.listStories: failed to parse response: $e');
        return [];
      }
      
    } catch (e) {
      print('Error fetching stories from Supabase: $e');
      // フォールバック：モックデータを返す
      return List.from(_mockStories);
    }
  }

  Future<Story> createStory(Story story) async {
    final supabase = SupabaseService.instance;
    
    if (_useMock || SupabaseConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      
      // ストーリー作成をログ記録
      try {
        await supabase.logAction('create_story', {
          'story_id': story.id,
          'title': story.title,
          'pages_count': story.pages.length,
          'mock_mode': true,
        });
      } catch (e) {
        print('Error logging action: $e');
      }
      
      _mockStories.add(story);
      return story;
    }
    
    try {
      // 実際のSupabaseに保存
      await supabase.logAction('create_story', {
        'story_id': story.id,
        'title': story.title,
        'pages_count': story.pages.length,
        'source': 'supabase',
      });
      
      final storyData = story.toJson();
      storyData['user_id'] = supabase.userId;
      
      final response = await supabase.client!
          .from(SupabaseConfig.storiesTable)
          .insert(storyData)
          .select()
          .single();
      
      return Story.fromJson(response);
      
    } catch (e) {
      print('Error creating story in Supabase: $e');
      // フォールバック：モックストレージに追加
      _mockStories.add(story);
      return story;
    }
  }

  Future<void> deleteStory(String id) async {
    final supabase = SupabaseService.instance;
    
    if (_useMock || SupabaseConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      
      // 削除をログ記録
      try {
        await supabase.logAction('delete_story', {
          'story_id': id,
          'mock_mode': true,
        });
      } catch (e) {
        print('Error logging action: $e');
      }
      
      _mockStories.removeWhere((story) => story.id == id);
      return;
    }
    
    try {
      // 実際のSupabaseから削除
      await supabase.logAction('delete_story', {
        'story_id': id,
        'source': 'supabase',
      });
      
      await supabase.client!
          .from(SupabaseConfig.storiesTable)
          .delete()
          .eq('id', id)
          .eq('user_id', supabase.userId!);
      
    } catch (e) {
      print('Error deleting story from Supabase: $e');
      // フォールバック：モックストレージから削除
      _mockStories.removeWhere((story) => story.id == id);
    }
  }
}
