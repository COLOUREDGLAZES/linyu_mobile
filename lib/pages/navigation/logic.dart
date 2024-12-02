import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/getx_config/GlobalData.dart';
import 'package:linyu_mobile/utils/getx_config/GlobalThemeConfig.dart';
import 'package:linyu_mobile/utils/getx_config/config.dart';
import 'package:linyu_mobile/utils/notification.dart';
import 'package:linyu_mobile/utils/permission_handler.dart';
import 'package:linyu_mobile/utils/web_socket.dart';

class NavigationLogic extends GetxController {
  late int currentIndex = 0;
  final _wsManager = WebSocketUtil();
  final List<GetPage> pages = pageRoute[0].children;

  GlobalData get globalData => GetInstance().find<GlobalData>();

  void initData() {
    late String sex = Get.parameters['sex'] ?? "男";
    GlobalThemeConfig theme = GetInstance().find<GlobalThemeConfig>();
    theme.changeThemeMode(sex == "女" ? 'pink' : 'blue');
  }

  @override
  void onInit() {
    super.onInit();
    initData();
    (() async {
      await globalData.init();
      await NotificationUtil.initialize();
      await NotificationUtil.createNotificationChannel();
      await PermissionHandler.permissionRequest();
      await connectWebSocket();
      eventListen();
    })();
  }

  void eventListen() {
    // 监听消息
    _wsManager.eventStream.listen((event) {
      globalData.onGetUserUnreadInfo();
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

  void onTap(int index) {
    currentIndex = index;
    update([const Key("main")]);
  }

  @override
  void onClose() {
    super.onClose();
    _wsManager.dispose();
  }
}
