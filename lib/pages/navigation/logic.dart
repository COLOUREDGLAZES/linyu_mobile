import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/config/getx/global_data.dart';
import 'package:linyu_mobile/utils/config/getx/global_theme_config.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:linyu_mobile/utils/notification.dart';
import 'package:linyu_mobile/utils/permission_handler.dart';
import 'package:linyu_mobile/utils/config/network/web_socket.dart';

class NavigationLogic extends GetxController {
  late RxInt currentIndex = 0.obs;
  final _wsManager = Get.find<WebSocketUtil>();

  final List<GetPage> pages = pageRoute[0].children;

  StreamSubscription? _subscription;
  GlobalData get globalData => GetInstance().find<GlobalData>();

  final List<String> selectedIcons = [
    'chat',
    'user',
    'talk',
  ];
  final List<String> unselectedIcons = [
    'assets/images/chat-empty.png',
    'assets/images/user-empty.png',
    'assets/images/talk-empty.png',
  ];
  final List<String> name = [
    '消息',
    '通讯',
    '说说',
  ];

  int lastExitTime = 0;

  bool isOpenDrawer = false;

  Future<void> _initThemeData() async {
    late String sex = Get.parameters['sex'] ?? "男";
    GlobalThemeConfig theme = GetInstance().find<GlobalThemeConfig>();
    theme.changeThemeMode(sex == "女" ? 'pink' : 'blue');
  }

  Future<void> _initializeServices() async {
    await globalData.init();
    await NotificationUtil.initialize();
    await NotificationUtil.createNotificationChannel();
    await PermissionHandler.permissionRequest();
    await _wsManager.connect();
    _eventListen();
  }

  // 监听消息
  void _eventListen() => _subscription = _wsManager.eventStream.listen((event) {
        if (event['type'] == 'on-receive-video') {
          var data = event['content'];
          if (data['type'] == "invite")
            Get.toNamed('/video_chat', arguments: {
              'userId': data['fromId'],
              'isSender': false,
              'isOnlyAudio': data['isOnlyAudio'],
            });
          return;
        }
        // if (event['type'] == 'on-receive-notify') {
        //   var data = event['content'];
        //   if (kDebugMode) print('event notify data: $data');
        //   if (data == 'login=>success') {
        //     CustomFlutterToast.showErrorToast('您的账号已在其他设备登录，请重新登录~');
        //     _sharedPreferences.clear();
        //     _wsManager.disconnect();
        //     globalData.currentToken = null;
        //     Get.offAllNamed('/login');
        //     return;
        //   }
        // }
        globalData.onGetUserUnreadInfo();
      });

  Future<bool> onBackPressed() async {
    try {
      if (!isOpenDrawer) {
        int nowExitTime = DateTime.now().millisecondsSinceEpoch;
        if (nowExitTime - lastExitTime > 2000) {
          lastExitTime = nowExitTime;
          CustomFlutterToast.showErrorToast('再按一次退出应用');
          return false;
        }
        return true;
      }
      Get.back(result: true);
      return false;
    } catch (e) {
      // 错误处理，例如记录日志
      if (kDebugMode) print('处理返回按键时发生错误: $e');
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices().catchError((error) {
      // 适当处理错误，例如记录日志或显示提示
      if (kDebugMode) print('初始化过程中发生错误: $error');
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await _initThemeData());
  }

  @override
  void onClose() {
    super.onClose();
    _wsManager.dispose();
    _subscription?.cancel();
  }
}
