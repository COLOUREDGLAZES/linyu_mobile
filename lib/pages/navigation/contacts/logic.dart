// ignore_for_file: unnecessary_new
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/api/chat_group_api.dart';
import 'package:linyu_mobile/utils/api/chat_list_api.dart';
import 'package:linyu_mobile/utils/api/friend_api.dart';
import 'package:linyu_mobile/utils/api/notify_api.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/config/getx/global_data.dart';
import 'package:linyu_mobile/utils/config/network/web_socket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsLogic extends GetxController {
  final _friendApi = new FriendApi();
  final _chatGroupApi = new ChatGroupApi();
  final _notifyApi = new NotifyApi();
  final _chatListApi = new ChatListApi();
  final GlobalData _globalData = GetInstance().find<GlobalData>();
  List<String> tabs = ['我的群聊', '我的好友', '好友通知'];
  int selectedIndex = 1;
  String currentUserId = '';
  List<dynamic> friendList = [];
  List<dynamic> chatGroupList = [];
  List<dynamic> notifyFriendList = [];
  late dynamic currentUserInfo = {};
  List<dynamic> searchList = [];
  final TextEditingController searchBoxController = new TextEditingController();
  final _wsManager = new WebSocketUtil();
  StreamSubscription? _subscription;

  GlobalData get globalData => GetInstance().find<GlobalData>();

  // 监听消息
  void eventListen() => _subscription = _wsManager.eventStream.listen((event) {
        if (event['type'] == 'on-receive-notify') {
          init();
        }
      });

  void onFriendList() async {
    try {
      final res = await _friendApi.list();
      if (res['code'] == 0) {
        friendList = res['data'];
        update([const Key("contacts")]);
      } else {
        // 处理非成功状态
        CustomFlutterToast.showErrorToast("获取好友列表失败: ${res['msg']}");
      }
    } catch (e) {
      // 捕获异常并处理
      CustomFlutterToast.showErrorToast("网络错误: $e");
    }
  }

  void onChatGroupList() {
    globalData.onGetUserUnreadInfo();
    _chatGroupApi.list().then((res) {
      if (res['code'] == 0) {
        chatGroupList = res['data'];
        update([const Key("contacts")]);
      }
    });
  }

  void onNotifyFriendList() => _notifyApi.friendList().then((res) {
        if (res['code'] == 0) {
          notifyFriendList = res['data'];
          update([const Key("contacts")]);
        }
      });

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserInfo['name'] = prefs.getString('username');
    currentUserInfo['portrait'] = prefs.getString('portrait');
    currentUserInfo['account'] = prefs.getString('account');
    currentUserInfo['sex'] = prefs.getString('sex');
    currentUserId = prefs.getString('userId') ?? '';
    onNotifyFriendList();
    onChatGroupList();
    onFriendList();
  }

  void onReadNotify() async {
    await _notifyApi.read('friend');
    await _globalData.onGetUserUnreadInfo();
  }

  void handlerTabTapped(int index) {
    selectedIndex = index;
    update([const Key("contacts")]);
    if (index == 2) {
      onReadNotify();
    }
  }

  void handlerFriendTapped(dynamic friend) =>
      Get.toNamed('/friend_info', arguments: {'friendId': friend['friendId']});

  //同意添加好友
  void handlerAgreeFriend(dynamic notify) async {
    onReadNotify();
    final result = await _friendApi.agree(notify['id'], notify['fromId']);
    if (result['code'] == 0) {
      init();
      CustomFlutterToast.showSuccessToast("同意好友请求成功");
    } else {
      CustomFlutterToast.showErrorToast("同意好友请求失败");
    }
  }

  //拒绝添加好友
  void handlerRejectFriend(dynamic notify) async {
    onReadNotify();
    final result = await _friendApi.reject(notify['fromId']);
    if (result['code'] == 0) {
      init();
      CustomFlutterToast.showSuccessToast("操作成功");
    } else {
      CustomFlutterToast.showErrorToast("网络错误");
    }
  }

  //长按分组进入分组设置页面
  void onLongPressGroup() =>
      Get.toNamed("/set_group", arguments: {'groupName': '0', 'friendId': '0'});

  //设置特别关心
  void onSetConcernFriend(dynamic friend) async {
    if (friend['isConcern']) {
      final response = await _friendApi.unCareFor(friend['friendId']);
      setResult(response);
    } else {
      final response = await _friendApi.careFor(friend['friendId']);
      setResult(response);
    }
    Get.back();
    init();
  }

  //特别关心结果
  void setResult(Map<String, dynamic> response) {
    if (response['code'] == 0) {
      CustomFlutterToast.showSuccessToast('设置成功~');
    } else {
      CustomFlutterToast.showErrorToast(response['msg']);
    }
  }

  void onSearchFriend(String friendInfo) {
    if (friendInfo.trim() == '') {
      searchList = [];
      init();
      return;
    }
    _friendApi.search(friendInfo).then((res) {
      if (res['code'] == 0) {
        friendList = [];
        searchList = res['data'];
        update([const Key("contacts")]);
      }
    });
  }

  String getNotifyContentTip(status, isFromCurrentUser) {
    if (!isFromCurrentUser) return "请求加你为好友";
    switch (status) {
      case "wait":
        {
          return "正在验证请求";
        }
      case "reject":
        {
          return "已拒绝申请请求";
        }
      case "agree":
        {
          return "已同意申请请求";
        }
    }
    return "";
  }

  void onToSendGroupMsg(id) =>
      _chatListApi.create(id, type: 'group').then((res) {
        if (res['code'] == 0) {
          Get.toNamed('/chat_frame', arguments: {
            'chatInfo': res['data'],
          });
        }
      });

  void toChatGroupInfo(dynamic group) {
    if (group == null || !group.containsKey('id')) {
      CustomFlutterToast.showErrorToast("群组信息无效");
      return;
    }
    try {
      Get.toNamed('/chat_group_info', arguments: {'chatGroupId': group['id']});
    } catch (e) {
      CustomFlutterToast.showErrorToast("导航到群组信息页面失败: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    eventListen();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
