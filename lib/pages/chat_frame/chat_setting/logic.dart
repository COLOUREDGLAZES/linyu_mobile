import 'dart:io' show File;
import 'package:flutter/foundation.dart' show Key, kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart'
    show ExtensionBottomSheet, Get, GetNavigation, Inst;
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:linyu_mobile/api/chat_group_member.dart';
import 'package:linyu_mobile/api/chat_list_api.dart';
import 'package:linyu_mobile/api/friend_api.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/pages/chat_frame/logic.dart';
import 'package:dio/dio.dart' show MultipartFile, FormData;
import 'package:linyu_mobile/utils/cropPicture.dart';
import 'package:linyu_mobile/utils/getx_config/config.dart';

import 'index.dart';

class ChatSettingLogic extends Logic<ChatSettingPage> {
  bool _isTop = false;
  bool get isTop => _isTop;
  set isTop(bool value) {
    _isTop = value;
    update([const Key('chat_setting')]);
  }

  late File _chatBackground;

  final _chatListApi = new ChatListApi();

  final _friendApi = new FriendApi();

  final _chatGroupMemberApi = new ChatGroupMemberApi();

  final ChatFrameLogic _chatFrameLogic = Get.find();

  late dynamic chatInfo;

  void init() async {
    chatInfo = arguments;
    isTop = chatInfo['isTop'] ?? false;
    // _chatBackground = File.fromUri(uri);
    _chatBackground = new File(
        "/data/user/0/com.cershy.linyu_mobile/cache/026a435d-cb6c-473e-a2f6-280756f0d0e6/Image_136076170223505.jpg");
  }

  // 聊天对象详情页面
  void goToChatDetailPage() async {
    final route =
        chatInfo['type'] == 'group' ? '/chat_group_info' : '/friend_info';
    final arg = chatInfo['type'] == 'group'
        ? {
            'chatGroupId': chatInfo['fromId'],
            'isFromChatSetting': true,
          }
        : {
            'friendId': chatInfo['fromId'],
            'isFromChatSetting': true,
          };
    final result = await Get.toNamed(route, arguments: arg);
  }

  // 设置聊天置顶
  void onSetChatTop(bool isTop) async {
    final result = await _chatListApi.top(chatInfo['id'], isTop);
    if (result['code'] == 0) {
      CustomFlutterToast.showSuccessToast('设置成功~');
      arguments['isTop'] = isTop;
      this.isTop = isTop;
    }
  }

  // 设置聊天背景
  Future<void> _setChatBackground(File file) async {
    try {
      _chatBackground = file;
      if (kDebugMode) print('chat background path is: ${_chatBackground.path}');
      MultipartFile picture = await MultipartFile.fromFile(
        _chatBackground.path,
        filename: _chatBackground.path.split('/').last,
      );
      final isGroupChat = chatInfo['type'] == 'group';
      final map = {
        'name': _chatBackground.path.split('/').last,
        'type': 'image/jpeg',
        'size': _chatBackground.lengthSync(),
        'file': picture,
      };
      if (isGroupChat)
        map['groupId'] = chatInfo['fromId'];
      else
        map['friendId'] = chatInfo['fromId'];
      FormData formData = FormData.fromMap(map);
      final setResult = isGroupChat
          ? await _chatGroupMemberApi.setChatBackground(formData)
          : await _friendApi.setChatBackground(formData);

      if (setResult['code'] == 0) {
        if (kDebugMode) print('set chat background is:${setResult['data']}');
        _chatFrameLogic.chatBackground = setResult['data'];
        CustomFlutterToast.showSuccessToast('设置聊天背景成功~');
        Get.back();
      } else
        CustomFlutterToast.showErrorToast('设置聊天背景失败: ${setResult['message']}');
    } catch (e) {
      CustomFlutterToast.showErrorToast('网络错误~');
    }
  }

  Future cropChatPicture(ImageSource? type) async =>
      cropPicture(type, _setChatBackground, isVariable: true);

  // 选择图片方式
  void selectPicture() async => Get.bottomSheet(
        backgroundColor: Colors.white,
        Wrap(
          children: [
            Center(
              child: TextButton(
                onPressed: () => cropChatPicture(null),
                child: Text(
                  '图库',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => cropChatPicture(ImageSource.camera),
                child: Text(
                  '相机',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  void onInit() {
    if (kDebugMode) print('view type is:${view.runtimeType}');
    if (kDebugMode) print('arguments is:$arguments');
    init();
    super.onInit();
  }
}
