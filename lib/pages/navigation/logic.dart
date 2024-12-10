import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/config/getx/global_data.dart';
import 'package:linyu_mobile/utils/config/getx/global_theme_config.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:linyu_mobile/utils/notification.dart';
import 'package:linyu_mobile/utils/permission_handler.dart';
import 'package:linyu_mobile/utils/config/network/web_socket.dart';

class NavigationLogic extends GetxController {
  late RxInt currentIndex = 0.obs;
  final _wsManager = WebSocketUtil();
  final List<GetPage> pages = pageRoute[0].children;
  StreamSubscription? _subscription;

  GlobalData get globalData => GetInstance().find<GlobalData>();

  Future<void> initThemeData() async {
    late String sex = Get.parameters['sex'] ?? "男";
    GlobalThemeConfig theme = GetInstance().find<GlobalThemeConfig>();
    theme.changeThemeMode(sex == "女" ? 'pink' : 'blue');
  }

  Future<void> _initializeServices() async {
    await globalData.init();
    await NotificationUtil.initialize();
    await NotificationUtil.createNotificationChannel();
    await PermissionHandler.permissionRequest();
    await connectWebSocket();
    eventListen();
  }

  void eventListen() {
    // 监听消息
    _subscription = _wsManager.eventStream.listen((event) {
      globalData.onGetUserUnreadInfo();
      if (event['type'] == 'on-receive-video') {
        var data = event['content'];
        if (data['type'] == "invite") {
          Get.toNamed('/video_chat', arguments: {
            'userId': data['fromId'],
            'isSender': false,
            'isOnlyAudio': data['isOnlyAudio'],
          });
        }
      }
    });
  }

  Future<void> connectWebSocket() async {
    _wsManager.connect();
  }

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

  @override
  void onInit() {
    super.onInit();
    _initializeServices().catchError((error) {
      // 适当处理错误，例如记录日志或显示提示
      if (kDebugMode) print('初始化过程中发生错误: $error');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initThemeData();
    });
  }

  @override
  void onClose() {
    super.onClose();
    _wsManager.dispose();
    _subscription?.cancel();
  }
}
