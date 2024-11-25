import 'package:dio/dio.dart';
import 'package:linyu_mobile/api/Http.dart';

class ChatGroupApi {
  final Dio _dio = Http(url: baseUrl).dio;

  static final ChatGroupApi _instance = ChatGroupApi._internal();

  ChatGroupApi._internal();

  factory ChatGroupApi() {
    return _instance;
  }

  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/chat-group/list');
    return response.data;
  }
}
