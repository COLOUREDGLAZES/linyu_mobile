import 'package:dio/dio.dart';
import 'package:linyu_mobile/api/http.dart';

class MsgApi {
  final Dio _dio = Http().dio;

  static final MsgApi _instance = MsgApi._internal();

  MsgApi._internal();

  factory MsgApi() {
    return _instance;
  }

 Future<Map<String, dynamic>> record(String targetId, int index, int num) async {
  try {
    final response = await _dio.post('/v1/api/message/record', data: {
      'targetId': targetId,
      'index': index,
      'num': num,
    });
    return response.data ?? {}; // 增加空值处理
  } on DioException catch (e) {
    // 适当的错误处理机制
    print('请求失败: ${e.message}');
    return {'error': e.message}; // 返回错误信息
  } catch (e) {
    print('发生未知错误: $e');
    return {'error': '发生未知错误'};
  }
}


  Future<Map<String, dynamic>> send(dynamic msg) async {
    final response = await _dio.post('/v1/api/message/send', data: msg);
    return response.data;
  }

  Future<Map<String, dynamic>> getMedia(String msgId) async {
    final response = await _dio
        .get('/v1/api/message/get/media', queryParameters: {'msgId': msgId});
    return response.data;
  }

  Future<Map<String, dynamic>> sendMedia(FormData formData) async {
    final response =
        await _dio.post('/v1/api/message/send/file/form', data: formData);
    return response.data;
  }

  Future<Map<String, dynamic>> retract(String msgId,String? targetId) async {
    final response =
        await _dio.post('/v1/api/message/retraction/new', data: {
          'msgId': msgId,
          'targetId':targetId
        });
    return response.data;
  }

  Future<Map<String, dynamic>> reEdit(String msgId) async {
    final response =
        await _dio.post('/v1/api/message/reedit', data: {'msgId': msgId});
    return response.data;
  }
}
