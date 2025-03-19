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
  SharedPreferences get prefs => GetInstance().find<SharedPreferences>();
  var unread = <String, int>{}.obs;

  String _currentUserId = '';
  String get currentUserId => _currentUserId;
  set currentUserId(String value) {
    _currentUserId = value;
    prefs.setString('currentUserId', value);
  }

  var currentAccount = '';
  late String? currentUserName;
  late String? currentPortrait =
      'http://114.96.70.115:19000/linyu/default-portrait.jpg';
  String? currentToken;

  /// 说说背景图片地址
  String? currentTalkBackground;

  /// 说说背景文本颜色
  Color? currentTalkBackgroundTextColor;
  String? currentSex;
  String? currentBirthday;
  String? currentSignature;

  /// 所有用户 ID 列表
  List<String> userIds = [];

  Future<bool> addUserId(String userId) async {
    if (userIds.contains(userId)) return true;
    userIds.add(userId);
    return await prefs.setStringList('userIds', userIds);
  }

  Future<Color> updateTextColor(String imageUrl) async {
    if (currentTalkBackground != imageUrl) currentTalkBackground = imageUrl;
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

  Future<bool> setTalkBackground(String imageUrl) async {
    updateTextColor(imageUrl);
    return await prefs.setString('talkBackground_$currentUserId', imageUrl);
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

  Future<bool> setCurrentUserInfo(Map<String, dynamic> userInfo) async {
    currentUserId = userInfo['userId'];
    currentToken = userInfo['token'];
    currentUserName = userInfo['username'];
    currentAccount = userInfo['account'];
    currentPortrait = userInfo['portrait'];
    currentSex = userInfo['sex'];
    currentBirthday = userInfo['birthday'] ?? '';
    currentSignature = userInfo['signature'] ?? '';
    currentTalkBackground = userInfo['talkBackground'];
    if (currentTalkBackground != null) updateTextColor(currentTalkBackground!);
    List<bool>? result;
    // 仅当用户 ID 不为空时才更新本地缓存
    if (currentUserId.isNotEmpty) {
      result = await Future.wait([
        prefs.setString('account_$currentUserId', currentAccount),
        prefs.setString('username_$currentUserId', currentUserName ?? ''),
        prefs.setString('portrait_$currentUserId', currentPortrait ?? ''),
        prefs.setString('sex_$currentUserId', currentSex ?? ''),
        prefs.setString('birthday_$currentUserId', currentBirthday ?? ''),
        prefs.setString('signature_$currentUserId', currentSignature ?? ''),
        prefs.setString(
            'talkBackground_$currentUserId', currentTalkBackground ?? ''),
      ]);
    }
    addUserId(currentUserId);
    return result != null && result.every((element) => element);
  }

  Future<void> init() async {
    try {
      if (_currentUserId.isNotEmpty && currentToken != null) {
        await onGetUserUnreadInfo();
        return;
      }
      final userInfo = await _userApi.info();
      _currentUserId = prefs.getString('currentUserId') ?? '';
      String? token = prefs.getString('x-token_$currentUserId');
      if (token == null) return;
      currentToken = token;
      currentAccount = prefs.getString('account_$currentUserId') ?? '';
      currentUserName = prefs.getString('username_$currentUserId');
      currentPortrait = prefs.getString('portrait_$currentUserId') ??
          'http://114.96.70.115:19000/linyu/default-portrait.jpg';
      currentTalkBackground =
          prefs.getString('talkBackground_$currentUserId') ??
              'http://114.96.70.115:19000/linyu/default-portrait.jpg';
      currentSex = prefs.getString('sex_$currentUserId');
      currentBirthday = prefs.getString('birthday_$currentUserId') ?? '';
      if (currentBirthday == null || currentBirthday!.isEmpty) {
        currentBirthday =
            DateTime.parse(userInfo['data']['birthday']).toLocal().toString();
        prefs.setString('birthday_$currentUserId', currentBirthday!);
      }
      currentSignature = prefs.getString('signature_$currentUserId') ?? '';
      if (currentSignature == null || currentSignature!.isEmpty) {
        currentSignature = userInfo['data']['signature'];
        prefs.setString('signature_$currentUserId', currentSignature!);
      }
    } catch (e) {
      // 增加错误处理
      if (kDebugMode) print('初始化失败: $e');
      // 根据需求可以添加其他处理逻辑，比如记录日志等
    }
  }

  void clearUserInfo() {
    _currentUserId = '';
    currentToken = null;
    currentUserName = null;
    currentAccount = '';
    currentPortrait = null;
    currentSex = null;
    currentBirthday = null;
    currentSignature = null;
    currentTalkBackground = null;
    currentTalkBackgroundTextColor = null;
    unread.clear();
    userIds.clear();
    AppBadger.setCount(0, 0);
    prefs.clear();
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onReady() {
    if (userIds.isEmpty) userIds = prefs.getStringList('userIds') ?? [];
    if (currentTalkBackground != null) updateTextColor(currentTalkBackground!);
    super.onReady();
  }
}
