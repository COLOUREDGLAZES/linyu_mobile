import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/api/chat_list_api.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

class RepostLogic extends Logic {
  final _chatListApi = new ChatListApi();

  void onToSendMsg(String toId) async {
    try {
      final res = await _chatListApi.create(toId, type: 'user');
      if (res['code'] == 0)
        Get.offAndToNamed('/chat_frame', arguments: {
          'chatInfo': res['data'],
        });
      else
      // 可以根据需要处理其他情况，例如错误代码
      if (kDebugMode) print('Error: ${res['message']}');
    } catch (e) {
      // 捕获和处理异常
      if (kDebugMode) print('请求失败: $e');
    }
  }
}
