// lib/services/user_service.dart
import 'package:dio/dio.dart';
import 'package:linyu_mobile/api/http.dart';

class ChatListApi {
  final Dio _dio = Http().dio;

  static final ChatListApi _instance = ChatListApi._internal();

  ChatListApi._internal();

  Future<Map<String, dynamic>> list() async {
    try {
      final response = await _dio.get('/v1/api/chat-list/list');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        // 处理非200的状态码，抛出异常
        throw Exception('获取聊天列表失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      // 捕获并处理网络错误或其他异常
      throw Exception('网络请求失败: $e');
    }
  }

  factory ChatListApi() {
    return _instance;
  }

  Future<Map<String, dynamic>> top(String chatListId, bool isTop) async {
    final response = await _dio.post(
      '/v1/api/chat-list/top',
      data: {'chatListId': chatListId, 'isTop': isTop},
    );
    return response.data;
  }

  // Future<Map<String, dynamic>> create(String userId, String type) async {
  //   final response = await _dio.post('/v1/api/chat-list/create',
  //       data: {'userId': userId, 'type': type});
  //   return response.data;
  // }

  Future<Map<String, dynamic>> delete(String chatListId) async {
    final response = await _dio.post(
      '/v1/api/chat-list/delete',
      data: {'chatListId': chatListId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> read(String targetId) async {
    final response = await _dio.get('/v1/api/chat-list/read/$targetId');
    return response.data;
  }

  Future<Map<String, dynamic>> detail(String targetId, String type) async {
    final response = await _dio.post('/v1/api/chat-list/detail',
        data: {'targetId': targetId, 'type': type});
    return response.data;
  }

  Future<Map<String, dynamic>> create(String userId,
      {String? type = 'user'}) async {
    final response = await _dio.post(
      '/v1/api/chat-list/create',
      data: {
        'userId': userId,
        'type': type,
      },
    );
    return response.data;
  }
}
