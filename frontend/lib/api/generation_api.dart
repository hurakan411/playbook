import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GenerationApi {
  GenerationApi({String? baseUrl})
      : baseUrl = baseUrl ?? 'http://127.0.0.1:8000/api/v1';

  final String baseUrl;

  /// 次ページ生成
  Future<Map<String, dynamic>> generateNextPage({
    required String storyId,
    // 1-based page number expected by backend (e.g. first page = 1, second page = 2)
    required int pageNumber,
    required String userInput,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/generate/page/next');
    final payload = {
      'story_id': storyId,
      'page_number': pageNumber,
      'user_direction': userInput,
      'user_id': userId,
    };
    final body = jsonEncode(payload);

    // UUIDフォーマット簡易判定
  final uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  final isUuid = uuidPattern.hasMatch(storyId);
  print('[GEN-NEXT] story_id raw : ' + storyId);

    print('[GEN-NEXT] ===== REQUEST =====');
    print('[GEN-NEXT] URL          : $url');
    print('[GEN-NEXT] story_id UUID?: $isUuid');
  print('[GEN-NEXT] page_number  : $pageNumber (1-based for backend)');
    print('[GEN-NEXT] user_id      : $userId');
    print('[GEN-NEXT] user_direction: ${userInput.substring(0, userInput.length.clamp(0, 120))}');

    http.Response resp;
    try {
      resp = await http.post(
        url,
        headers: const {'Content-Type': 'application/json'},
        body: body,
      );
    } on SocketException catch (e) {
      print('[GEN-NEXT][ERROR] SocketException: $e');
      throw Exception('Failed to generate next page: CONNECTION_REFUSED (${e.osError?.message})');
    } catch (e) {
      print('[GEN-NEXT][ERROR] Request send failed: $e');
      throw Exception('Failed to generate next page: REQUEST_FAILED ($e)');
    }

    print('[GEN-NEXT] ===== RESPONSE =====');
    print('[GEN-NEXT] Status : ${resp.statusCode}');
    print('[GEN-NEXT] Body   : ${resp.body}');

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      String classification = 'UNKNOWN';
      String detailText = resp.body;
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map) {
          detailText = decoded['detail']?.toString() ?? resp.body;
        }
        if (resp.statusCode == 404) {
          classification = 'NOT_FOUND (story_id)';
        } else if (detailText.contains('invalid input syntax for type uuid')) {
          classification = 'INVALID_UUID_FORMAT (story_id)';
        } else if (resp.statusCode == 422) {
          classification = 'VALIDATION_ERROR (payload)';
        } else if (detailText.contains('Next page generation failed')) {
          classification = 'BACKEND_PAGE_GEN_EXCEPTION';
        } else if (resp.statusCode >= 500) {
          classification = 'SERVER_ERROR';
        }
      } catch (e) {
        print('[GEN-NEXT][WARN] Error decode failed: $e');
      }
      print('[GEN-NEXT] Classified error: $classification');
      throw Exception('Failed to generate next page [$classification]: ${resp.statusCode} $detailText');
    }

    final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data;
  }

  /// 最初のページ生成
  Future<Map<String, dynamic>> generateFirstPage({
    required String storyTitle,
    required int totalPages,
    required String artStyle,
    required String mainCharacterName,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/generate/page/first');
    final payload = {
      'story_title': storyTitle,
      'total_pages': totalPages,
      'art_style': artStyle,
      'main_character_name': mainCharacterName,
      'user_id': userId,
    };
    print('[GEN-FIRST] URL : $url');
    print('[GEN-FIRST] Payload: $payload');

    http.Response resp;
    try {
      resp = await http.post(
        url,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } on SocketException catch (e) {
      throw Exception('Failed to generate first page: CONNECTION_REFUSED (${e.osError?.message})');
    }

    print('[GEN-FIRST] Status : ${resp.statusCode}');
    print('[GEN-FIRST] Body   : ${resp.body}');

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Failed to generate first page: ${resp.statusCode} ${resp.body}');
    }
    final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data;
  }
}
