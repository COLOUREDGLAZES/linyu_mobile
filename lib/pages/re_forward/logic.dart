import 'dart:convert';
import 'package:flutter/foundation.dart' show Key, debugPrint, kDebugMode;
import 'package:flutter/material.dart' show FocusNode, TextEditingController;
import 'package:get/get.dart' show Get, GetNavigation;
import 'package:linyu_mobile/components/CustomDialog/index.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/api/chat_list_api.dart' show ChatListApi;
import 'package:linyu_mobile/utils/api/msg_api.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart' show Logic;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import 'index.dart';

class ReForwardLogic extends Logic<ReForwardPage> {
  final _chatListApi = new ChatListApi();
  final _msgApi = new MsgApi();
  final FocusNode focusNode = new FocusNode(skipTraversal: true);
  final TextEditingController searchBoxController = new TextEditingController();
  // 要发送的消息从参数中获取
  late Map<String, dynamic> sendMsg;
  // 要发送的对象列表
  List<String> toIdList = [];
  // 好友列表
  late List<dynamic> friendSearchList = [];
  // 群聊列表
  late List<dynamic> groupSearchList = [];
  // 其他用户列表
  late List<dynamic> otherList = [];
  //当前用户信息
  late dynamic currentUserInfo = {};

  // 搜索好友
  void onSearchFriend(String friendInfo) async {
    if (friendInfo.trim() == '') {
      friendSearchList = [];
      update([const Key("repost")]);
      return;
    }
    // _friendApi.search(friendInfo).then((res) {
    //   if (res['code'] == 0) {
    //     searchList = res['data'];
    //     update([const Key("repost")]);
    //   }
    // });
    final res = await _chatListApi.search(friendInfo);
    if (res['code'] == 0) {
      debugPrint('searchList is: ${res['data']}');
      friendSearchList = res['data']['friend'];
      groupSearchList = res['data']['group'];
      update([const Key("repost")]);
    }
  }

  // 获取聊天列表
  void onGetChatList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentUserInfo = {
        'name': prefs.getString('username'),
        'portrait': prefs.getString('portrait'),
        'account': prefs.getString('account'),
        'sex': prefs.getString('sex'),
      };

      final res = await _chatListApi.list();
      if (res['code'] == 0) {
        otherList = res['data']['others'];
        update([const Key("repost")]);
      } else {
        // 处理错误情况，比如提示用户
        if (kDebugMode) print('获取聊天列表失败: ${res['message']}');
      }
    } catch (e) {
      // 捕获和处理异常
      if (kDebugMode) print('发生错误: $e');
    }
  }

  // 发送消息
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

  void _parseSendMsgType(Map<String, dynamic> msg, dynamic sendMsg) {
    dynamic content;
    if (sendMsg['msgContent']['type'] == 'text') {
      content = sendMsg['msgContent']['content'];
      msg['msgContent'] = {'type': "text", 'content': content};
      return;
    }
    content = jsonDecode(sendMsg['msgContent']['content']);
    if (kDebugMode) print('content type: $content');

    if (content['type'] == 'jpg') {
      msg['msgContent'] = {
        'type': 'img',
        'content': jsonEncode({
          'name': content['fileName'],
          'size': content['size'],
        })
      };
      return;
    }

    if (content['type'] == 'wav') {
      final int time = content['time'];
      msg['msgContent'] = {
        'type': "voice",
        'content': jsonEncode({
          'name': 'voice.wav',
          'size': content['size'],
          'time': time,
        })
      };
      return;
    }

    msg['msgContent'] = {
      'type': 'file',
      'content': jsonEncode({
        'name': content['fileName'],
        'size': content['size'],
      })
    };
  }

  void onOk(dynamic chatObject) async {
    // 是否已经转发过
    final fromForwardMsgId = sendMsg['fromForwardMsgId'];
    try {
      Map<String, dynamic> msg = {
        'toUserId': sendMsg['toUserId'],
        'source': chatObject['type'] ?? 'user',
        'isForward': true,
        //还未转发的消息用原消息的id，转发过的消息用转发的消息的id
        'fromMsgId': fromForwardMsgId ?? sendMsg['id'],
      };
      _parseSendMsgType(msg, sendMsg);
      final res = await _msgApi.send(msg);
      if (res['code'] == 0) {
        if (kDebugMode) print('发送成功: ${res['data']}');
        Get.back(result: res);
        CustomFlutterToast.showSuccessToast('已发送');
      } else
      // 处理错误情况，比如提示用户
      if (kDebugMode) print('发送失败: ${res['message']}');
    } catch (e) {
      // 捕获和处理异常
      if (kDebugMode) print('请求失败: $e');
      CustomFlutterToast.showErrorToast('发送失败: $e');
    }
  }

  // 点击搜索好友
  void onTapSearchFriend(dynamic friend) async {
    if (kDebugMode) print('tap search friend: $friend');
    final toUserId = friend['friendId'];
    sendMsg['toUserId'] = toUserId;
    final res = await _chatListApi.create(toUserId, type: 'user');
    if (res['code'] == 0)
      CustomDialog.showTipDialog(Get.context!,
          text: '确定要发送给 ${friend['name']} 吗？', onOk: () => onOk(friend));
  }

  // 点击搜索群聊
  void onTapSearchGroup(dynamic group) async {
    if (kDebugMode) print('tap search group: $group');
    final toUserId = group['id'];
    sendMsg['toUserId'] = toUserId;
    final res = await _chatListApi.create(toUserId, type: 'group');
    if (res['code'] == 0) {
      group['type'] = 'group';
      CustomDialog.showTipDialog(Get.context!,
          text: '确定要发送给 ${group['name']} 吗？', onOk: () => onOk(group));
    }
  }

  // 点击要发送的用户时
  void onTapUser(dynamic chatUser) async {
    if (kDebugMode) print('点击用户: $chatUser');
    final toUserId = chatUser['fromId'];
    sendMsg['toUserId'] = toUserId;
    CustomDialog.showTipDialog(Get.context!,
        text: '确定要发送给 ${chatUser['name']} 吗？', onOk: () => onOk(chatUser));
  }

  @override
  void onInit() {
    onGetChatList();
    super.onInit();
  }

  @override
  void onReady() {
    sendMsg = arguments['msg'];
    if (kDebugMode) print('onReady sendMsg: $sendMsg');
    super.onReady();
  }

  @override
  void onClose() {
    searchBoxController.dispose();
    super.onClose();
  }
}
