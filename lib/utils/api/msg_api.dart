import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:linyu_mobile/utils/config/network/http.dart';

class MsgApi {
  final Dio _dio = Http().dio;

  static final MsgApi _instance = MsgApi._internal();

  MsgApi._internal();

  factory MsgApi() => _instance;

  Future<Map<String, dynamic>> record(
      String targetId, int index, int num) async {
    try {
      final response = await _dio.post('/v1/api/message/record', data: {
        'targetId': targetId,
        'index': index,
        'num': num,
      });
      return response.data ?? {}; // 增加空值处理
    } on DioException catch (e) {
      // 适当的错误处理机制
      if (kDebugMode) print('请求失败: ${e.message}');
      return {'error': e.message}; // 返回错误信息
    } catch (e) {
      if (kDebugMode) print('发生未知错误: $e');

      return {'error': '发生未知错误'};
    }
  }

  Future<Map<String, dynamic>> send(dynamic msg) async {
    if (msg == null) return {'error': '消息不能为空'};
    try {
      final response = await _dio.post('/v1/api/message/send', data: msg);
      return response.data ?? {}; // 加入空值处理
    } on DioException catch (e) {
      if (kDebugMode) print('请求失败: ${e.message}');
      // 错误处理
      return {'error': e.message}; // 返回错误信息
    } catch (e) {
      if (kDebugMode) print('发生未知错误: $e');
      // 错误处理
      return {'error': '发生未知错误'};
    }
  }

  Future<Map<String, dynamic>> getMedia(String msgId) async {
    if (msgId.isEmpty) return {'error': 'msgId 不能为空'};
    try {
      final response = await _dio
          .get('/v1/api/message/get/media', queryParameters: {'msgId': msgId});
      return response.data ?? {}; // 增加空值处理
    } on DioException catch (e) {
      if (kDebugMode) print('请求失败: ${e.message}');
      // 错误处理
      return {'error': e.message}; // 返回错误信息
    } catch (e) {
      if (kDebugMode) print('发生未知错误: $e');
      // 错误处理
      return {'error': '发生未知错误'};
    }
  }

  Future<Map<String, dynamic>> sendMedia(FormData formData) async {
    if ((formData.fields as List).isEmpty) return {'error': 'formData 不能为空'};
    try {
      final response =
          await _dio.post('/v1/api/message/send/file/form', data: formData);
      return response.data ?? {}; // 增加空值处理
    } on DioException catch (e) {
      if (kDebugMode) print('请求失败: ${e.message}');
      // 错误处理
      return {'error': e.message}; // 返回错误信息
    } catch (e) {
      if (kDebugMode) print('发生未知错误: $e');
      // 错误处理
      return {'error': '发生未知错误'};
    }
  }

  Future<Map<String, dynamic>> retract(String msgId, String? targetId) async {
    if (msgId.isEmpty) return {'error': 'msgId 不能为空'};
    try {
      final response = await _dio.post('/v1/api/message/retraction',
          data: {'msgId': msgId, 'targetId': targetId});
      return response.data ?? {}; // 增加空值处理
    } on DioException catch (e) {
      if (kDebugMode) print('请求失败: ${e.message}');
      // 错误处理
      return {'error': e.message}; // 返回错误信息
    } catch (e) {
      if (kDebugMode) print('发生未知错误: $e');
      // 错误处理
      return {'error': '发生未知错误'};
    }
  }

  Future<Map<String, dynamic>> reEdit(String msgId) async {
    if (msgId.isEmpty) return {'error': 'msgId 不能为空'};
    try {
      final response =
          await _dio.post('/v1/api/message/reedit', data: {'msgId': msgId});
      return response.data ?? {}; // 增加空值处理
    } on DioException catch (e) {
      if (kDebugMode) print('请求失败: ${e.message}');

      return {'error': e.message}; // 返回错误信息
    } catch (e) {
      if (kDebugMode) print('发生未知错误: $e');

      return {'error': '发生未知错误'};
    }
  }

  Future<Map<String, dynamic>> voiceToText(String msgId) async {
    if (msgId.isEmpty) return {'error': 'msgId 不能为空'};
    try {
      final response = await _dio.get('/v1/api/message/voice/to/text',
          queryParameters: {'msgId': msgId});
      return response.data ?? {}; // 增加空值处理
    } on DioException catch (e) {
      if (kDebugMode) print('请求失败: ${e.message}');

      return {'error': e.message}; // 返回错误信息
    } catch (e) {
      if (kDebugMode) print('发生未知错误: $e');

      return {'error': '发生未知错误'};
    }
  }
}
