import 'package:flutter/cupertino.dart' show NetworkImage;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:get/get.dart' show GetInstance, GetxController, MapExtension;
import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/utils/app_badger.dart';
import 'package:palette_generator/palette_generator.dart' show PaletteGenerator;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class GlobalData extends GetxController {
  final _userApi = UserApi();
  var unread = <String, int>{}.obs;
  var currentUserId = '';
  var currentUserAccount = '';
  late String? currentUserName;
  late String? currentAvatarUrl =
      'http://114.96.70.115:19000/linyu/default-portrait.jpg';
  String? currentToken;
  String? currentBackGroundUrl;
  Color? currentTalkBackgroundTextColor;

  SharedPreferences get prefs => GetInstance().find<SharedPreferences>();

  Future<Color> updateTextColor(String imageUrl) async {
    if (currentBackGroundUrl != imageUrl) currentBackGroundUrl = imageUrl;
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(NetworkImage(imageUrl));
      Color? dominantColor = paletteGenerator.dominantColor?.color;

      // 如果 dominantColor 存在，计算亮度并选择合适的文本颜色
      if (dominantColor != null) {
        double brightness = (0.299 * dominantColor.red +
                0.587 * dominantColor.green +
                0.114 * dominantColor.blue) /
            255;
        currentTalkBackgroundTextColor =
            brightness > 0.5 ? Colors.white : Colors.black;
      } else
        // 如果无法获取 dominantColor，则默认使用黑色文本颜色
        currentTalkBackgroundTextColor = Colors.black;
    } catch (e) {
      // 增加错误处理
      if (kDebugMode) print('更新文本颜色失败: $e');
      // 默认返回黑色文本颜色
      currentTalkBackgroundTextColor = Colors.black;
    }

    return currentTalkBackgroundTextColor!;
  }

  Future<void> init() async {
    try {
      String? token = prefs.getString('x-token');
      if (token == null) return;
      currentToken = token;
      currentUserId = prefs.getString('userId') ?? '';
      currentUserAccount = prefs.getString('account') ?? '';
      currentUserName = prefs.getString('username');
      currentAvatarUrl = prefs.getString('portrait') ??
          'http://114.96.70.115:19000/linyu/default-portrait.jpg';
      currentBackGroundUrl = prefs.getString('talkBackground') ??
          'http://114.96.70.115:19000/linyu/default-portrait.jpg';
      // 仅当用户 ID 不为空时才获取未读信息
      if (currentUserId.isNotEmpty) await onGetUserUnreadInfo();
    } catch (e) {
      // 增加错误处理
      if (kDebugMode) print('初始化失败: $e');
      // 根据需求可以添加其他处理逻辑，比如记录日志等
    }
  }

  Future<void> onGetUserUnreadInfo() async {
    try {
      final result = await _userApi.unread();
      if (result['code'] == 0) {
        unread.assignAll(Map<String, int>.from(result['data']));
        // 优化：仅在有未读消息时更新角标
        int chatCount = getUnreadCount('chat');
        int notifyCount = getUnreadCount('notify');
        // if (chatCount > 0 || notifyCount > 0)
        AppBadger.setCount(
            chatCount > 0 ? chatCount : 0, notifyCount > 0 ? notifyCount : 0);
      }
    } catch (e) {
      // 增加错误处理
      if (kDebugMode) print('获取未读信息失败: $e');
      // 这里可以根据需求添加其他处理逻辑，比如记录日志等
    }
  }

  int getUnreadCount(String type) {
    if (unread.containsKey(type)) return unread[type]!;
    return 0;
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onReady() {
    if (currentBackGroundUrl != null) updateTextColor(currentBackGroundUrl!);
    super.onReady();
  }
}
