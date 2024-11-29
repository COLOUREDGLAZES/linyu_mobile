import 'package:dio/dio.dart';
import 'package:linyu_mobile/api/Http.dart';

class MsgApi {
  final Dio _dio = Http().dio;

  static final MsgApi _instance = MsgApi._internal();

  MsgApi._internal();

  factory MsgApi() {
    return _instance;
  }

  Future<Map<String, dynamic>> record(
      String targetId, int index, int num) async {
    final response = await _dio.post('/v1/api/message/record',
        data: {'targetId': targetId, 'index': index, 'num': num});
    return response.data;
  }

  Future<Map<String, dynamic>> send(dynamic msg) async {
    final response = await _dio.post('/v1/api/message/send', data: msg);
    return response.data;
  }
}