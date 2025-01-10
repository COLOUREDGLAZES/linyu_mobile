import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'
    show Get, GetInstance, GetNavigation, GetxController, Inst;
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/api/chat_list_api.dart';
import 'package:linyu_mobile/utils/config/getx/global_data.dart';
import 'package:linyu_mobile/utils/config/network/web_socket.dart';

class ChatListLogic extends GetxController {
  final _chatListApi = ChatListApi();
  final FocusNode focusNode = new FocusNode(skipTraversal: true);
  late List<dynamic> topList = [];
  late List<dynamic> otherList = [];
  late List<dynamic> friendSearchList = [];
  late List<dynamic> groupSearchList = [];
  final _wsManager = Get.find<WebSocketUtil>();
  StreamSubscription? _subscription;
  final TextEditingController searchBoxController = new TextEditingController();

  GlobalData get globalData => GetInstance().find<GlobalData>();

  Future<void> onGetChatList() async {
    try {
      final res = await _chatListApi.list();
      if (res['code'] == 0) {
        if (kDebugMode) print('获取聊天列表成功: ${res['data']}');
        topList = res['data']['tops'];
        otherList = res['data']['others'];
        update([const Key("chat_list")]);
      } else
      // 处理错误情况，比如提示用户
      if (kDebugMode) print('获取聊天列表失败: ${res['message']}');
    } catch (e) {
      // 捕获和处理异常
      if (kDebugMode) print('发生错误: $e');
    } finally {
      // 判断websocket是否连接
      if (!_wsManager.isConnected) _wsManager.connect();
    }
  }

  // 监听消息
  void eventListen() => _subscription = _wsManager.eventStream.listen((event) {
        if (event['type'] == 'on-receive-msg') {
          onGetChatList();
        }
      });

  void onTopStatus(String id, bool isTop) =>
      _chatListApi.top(id, !isTop).then((res) {
        if (res['code'] == 0) onGetChatList();
      });

  void onDeleteChatList(String id) => _chatListApi.delete(id).then((res) {
        if (res['code'] == 0) onGetChatList();
      });

  void onSearch(String searchInfo) async {
    if (searchInfo.trim() == '') {
      friendSearchList.clear();
      groupSearchList.clear();
      onGetChatList();
      return;
    }
    final result = await _chatListApi.search(searchInfo);
    if (result['code'] == 0) {
      if (kDebugMode) print('搜索好友成功: ${result['data']}');
      topList.clear();
      otherList.clear();
      groupSearchList = result['data']['group'];
      friendSearchList = result['data']['friend'];
      update([const Key("chat_list")]);
    }
  }

  void onTapSearchFriend(dynamic chatObject) async {
    if (kDebugMode) print('tap search friend: $chatObject');
    try {
      final result =
          await _chatListApi.create(chatObject['friendId'], type: 'user');
      if (result['code'] == 0) {
        if (kDebugMode) print('创建聊天成功: ${result['data']}');
        await Get.toNamed('/chat_frame', arguments: {
          'chatInfo': result['data'],
        });
      } else
      // 处理错误情况，提示用户
      if (kDebugMode) print('创建聊天失败: ${result['message']}');
    } catch (e) {
      // 捕获和处理异常
      if (kDebugMode) print('发生错误: $e');
    }
  }

  void onTapSearchGroup(dynamic chatObject) async {
    if (kDebugMode) print('tap search friend: $chatObject');
    try {
      final result = await _chatListApi.create(chatObject['id'], type: 'group');
      if (result['code'] == 0) {
        if (kDebugMode) print('创建聊天成功: ${result['data']}');
        await Get.toNamed('/chat_frame', arguments: {
          'chatInfo': result['data'],
        });
      } else
      // 处理错误情况，提示用户
      if (kDebugMode) print('创建聊天失败: ${result['message']}');
    } catch (e) {
      // 捕获和处理异常
      if (kDebugMode) print('发生错误: $e');
    }
  }

  void onTapToChat(dynamic chat) async {
    try {
      final result =
          await Get.toNamed('/chat_frame', arguments: {'chatInfo': chat});
      onGetChatList();
      focusNode.unfocus();
    } on Exception catch (e) {
      // TODO
      if (kDebugMode) print('发生错误: $e');
      CustomFlutterToast.showErrorToast('发生错误: $e');
    } finally {
      // 判断websocket是否连接
      if (!_wsManager.isConnected) _wsManager.connect();
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
