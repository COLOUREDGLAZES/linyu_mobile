import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:linyu_mobile/utils/config/network/http.dart';

class ChatGroupApi {
  final Dio _dio = Http().dio;

  static final ChatGroupApi _instance = ChatGroupApi._internal();

  ChatGroupApi._internal();

  factory ChatGroupApi() {
    return _instance;
  }

  Future<Map<String, dynamic>> list() async {
    try {
      final response = await _dio.get('/v1/api/chat-group/list');
      return response.data as Map<String, dynamic>; // 确保类型为Map<String, dynamic>
    } catch (e) {
      // 处理异常
      if (kDebugMode) {
        print('获取聊天组列表失败: $e');
      }
      return {}; // 返回空的Map以示失败
    }
  }

  Future<Map<String, dynamic>> details(String chatGroupId) async {
    if (chatGroupId.isEmpty) {
      // 如果 chatGroupId 为空，返回空的 Map
      return {};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/details', data: {
        'chatGroupId': chatGroupId,
      });
      return response.data
          as Map<String, dynamic>; // 确保类型为 Map<String, dynamic>
    } catch (e) {
      // 处理异常
      if (kDebugMode) {
        print('获取聊天组详情失败: $e');
      }
      return {}; // 返回空的 Map 以示失败
    }
  }

  Future<Map<String, dynamic>> upload(FormData formData) async {
    try {
      final response = await _dio.post(
        '/v1/api/chat-group/upload/portrait/form',
        data: formData,
      );
      return response.data
          as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      if (kDebugMode) {
        print('上传失败: $e');
      }
      return {}; // 返回空的 Map 以示失败
    }
  }

  Future<Map<String, dynamic>> createWithPerson(
      String name, String? notice, List users) async {
    // 检查必需的参数
    if (name.isEmpty || users.isEmpty) {
      return {'error': '名称和用户列表不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/create', data: {
        'name': name,
        'notice': notice,
        'users': users,
      });
      return response.data
          as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      // 处理异常
      if (kDebugMode) {
        print('创建聊天组失败: $e');
      }
      return {'error': '创建聊天组失败'}; // 返回错误信息
    }
  }

  Future<Map<String, dynamic>> update(
      String chatGroupId, String key, dynamic value) async {
    if (chatGroupId.isEmpty || key.isEmpty) {
      return {'error': '聊天组ID和更新键不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/update', data: {
        'groupId': chatGroupId,
        'updateKey': key,
        'updateValue': value,
      });
      return response.data
          as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      if (kDebugMode) {
        print('更新聊天组失败: $e');
      }
      return {'error': '更新聊天组失败'}; // 返回错误信息
    }
  }

  Future<Map<String, dynamic>> updateName(
      String chatGroupId, String name) async {
    // 检查必需的参数
    if (chatGroupId.isEmpty || name.isEmpty) {
      return {'error': '聊天组ID和名称不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/update/name', data: {
        'groupId': chatGroupId,
        'name': name,
      });
      return response.data
          as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      if (kDebugMode) {
        print('更新聊天组名称失败: $e');
      }
      return {'error': '更新聊天组名称失败'}; // 返回错误信息
    }
  }

  Future<Map<String, dynamic>> kickChatGroup(
      String groupId, String userId) async {
    // 检查必需的参数
    if (groupId.isEmpty || userId.isEmpty) {
      return {'error': '聊天组ID和用户ID不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/kick', data: {
        'groupId': groupId,
        'userId': userId,
      });
      return response.data
          as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      if (kDebugMode) {
        print('踢出用户失败: $e');
      }
      return {'error': '踢出用户失败'}; // 返回错误信息
    }
  }

  Future<Map<String, dynamic>> inviteMember(
      String groupId, List<dynamic> ids) async {
    if (groupId.isEmpty || ids.isEmpty) {
      return {'error': '聊天组ID和用户ID列表不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/invite', data: {
        'groupId': groupId,
        'userIds': ids,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('邀请成员失败: $e');
      }
      return {'error': '邀请成员失败'};
    }
  }

  Future<Map<String, dynamic>> transferChatGroup(
      String groupId, String userId) async {
    // 检查必需的参数
    if (groupId.isEmpty || userId.isEmpty) {
      return {'error': '聊天组ID和用户ID不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/transfer', data: {
        'groupId': groupId,
        'userId': userId,
      });
      return response.data
          as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      if (kDebugMode) {
        print('转移聊天组失败: $e');
      }
      return {'error': '转移聊天组失败'}; // 返回错误信息
    }
  }

  Future<Map<String, dynamic>> create(String name) async {
    // 检查必需的参数
    if (name.isEmpty) {
      return {'error': '名称不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/create', data: {
        'name': name,
      });
      return response.data
          as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      if (kDebugMode) {
        print('创建聊天组失败: $e');
      }
      return {'error': '创建聊天组失败'}; // 返回错误信息
    }
  }

  Future<Map<String, dynamic>> quitChatGroup(String groupId) async {
    // 检查必需的参数
    if (groupId.isEmpty) {
      return {'error': '聊天组ID不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/quit', data: {
        'groupId': groupId,
      });
      return response.data
          as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      if (kDebugMode) {
        print('退出聊天组失败: $e');
      }
      return {'error': '退出聊天组失败'}; // 返回错误信息
    }
  }

  Future<Map<String, dynamic>> dissolveChatGroup(String groupId) async {
    if (groupId.isEmpty) {
      return {'error': '聊天组ID不能为空'};
    }

    try {
      final response = await _dio.post('/v1/api/chat-group/dissolve', data: {
        'groupId': groupId,
      });
      return response.data as Map<String, dynamic>; // 确保返回类型为 Map<String, dynamic>
    } catch (e) {
      if (kDebugMode) {
        print('解散聊天组失败: $e');
      }
      return {'error': '解散聊天组失败'}; // 返回错误信息
    }
}

}
