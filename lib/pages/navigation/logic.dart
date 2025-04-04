import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/pages/chat_list/logic.dart';
import 'package:linyu_mobile/pages/contacts/logic.dart';
import 'package:linyu_mobile/pages/talk/logic.dart';
import 'package:linyu_mobile/config/getx/config.dart';
import 'package:linyu_mobile/utils/notification.dart';
import 'package:linyu_mobile/utils/permission_handler.dart';

class NavigationLogic extends Logic {
  late RxInt currentIndex = 0.obs;
  final List<GetPage> pages = pageRoute[0].children;

  StreamSubscription? _subscription;

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

  bool _isOpenDrawer = false;
  bool get isOpenDrawer => _isOpenDrawer;
  set isOpenDrawer(bool value) {
    if (_userId != globalData.currentUserId && !value) {
      if (currentIndex.value == 0) {
        final ChatListLogic chatListLogic = Get.find<ChatListLogic>();
        chatListLogic.onGetChatList();
      } else if (currentIndex.value == 1) {
        final ContactsLogic contactsLogic = Get.find<ContactsLogic>();
        contactsLogic.init();
      } else {
        final TalkLogic talkLogic = Get.find<TalkLogic>();
        talkLogic.init();
      }
      _userId = globalData.currentUserId;
      globalData.onGetUserUnreadInfo();
    }
    _isOpenDrawer = value;
    update([const Key('main')]);
  }

  String _userId = '';

  void _initThemeData() {
    theme.changeThemeMode(globalData.currentSex == "女" ? 'pink' : 'blue');
  }

  Future<void> _initializeServices() async {
    await globalData.init();
    _initThemeData();
    await NotificationUtil.initialize();
    await NotificationUtil.createNotificationChannel();
    await PermissionHandler.permissionRequest();
    await wsManager.connect();
    _eventListen();
    _userId = globalData.currentUserId;
  }

  // 监听消息
  void _eventListen() => _subscription = wsManager.eventStream.listen((event) {
        try {
          if (event['type'] == 'on-receive-video') {
            final data = event['content'];
            if (data['type'] == "invite")
              Get.toNamed('/video_chat', arguments: {
                'userId': data['fromId'],
                'isSender': false,
                'isOnlyAudio': data['isOnlyAudio'],
              });
          } else if (event['type'] == 'on-receive-notify') {
            final data = event['content'];
            if (kDebugMode) print('event notify data: $data');
            if (data == 'login=>success') {
              CustomFlutterToast.showErrorToast('您的账号已在其他设备登录，请重新登录~');
              sharedPreferences.clear();
              wsManager.disconnect();
              globalData.currentToken = null;
              Get.offAndToNamed('/login');
            } else
              globalData.onGetUserUnreadInfo();
          } else
            globalData.onGetUserUnreadInfo();
        } catch (e) {
          if (kDebugMode) print('监听WebSocket事件时发生错误: $e');
        }
      });

  Future<bool> _onBackPressed() async {
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

  void onPopPage(didPop, result) {
    if (didPop) return;
    _onBackPressed().then((value) {
      if (value == true) {
        wsManager.disconnect();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    });
  }

  void onSwitchPage(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }

  @override
  void onInit() {
    try {
      _initializeServices().catchError((error) {
        // 适当处理错误，例如记录日志或显示提示
        if (kDebugMode) print('初始化过程中发生错误: $error');
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => theme
          .changeThemeMode(globalData.currentSex == "女" ? 'pink' : 'blue'));
    } on Exception catch (e) {
      if (kDebugMode) print('初始化过程中发生错误: $e');
    } finally {
      super.onInit();
    }
  }

  @override
  void onClose() {
    try {
      wsManager.disconnect();
      _subscription?.cancel();
    } on Exception catch (e) {
      if (kDebugMode) print('关闭WebSocket时发生错误: $e');
    } finally {
      super.onClose();
    }
  }
}
