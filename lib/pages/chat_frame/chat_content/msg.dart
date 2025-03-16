import 'dart:convert';

import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:custom_pop_up_menu_fork/custom_pop_up_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/components/custom_portrait/index.dart';
import 'package:linyu_mobile/components/custom_text_button/index.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/call.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/file.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/image.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/retraction.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/system.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/time.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/voice.dart';
import 'package:linyu_mobile/utils/date.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

import 'no_more.dart';
import 'text.dart';

typedef CallBack = dynamic Function(dynamic data);

class ChatMessage extends StatelessThemeWidget {
  const ChatMessage({
    super.key,
    required this.msg,
    required this.chatInfo,
    required this.member,
    this.chatPortrait = 'http://192.168.101.4:9000/linyu/default-portrait.jpg',
    this.onTapCopy,
    this.onTapRepost,
    this.onTapDelete,
    this.onTapRetract,
    this.onTapCite,
    this.onTapMsg,
    this.reEdit,
    this.onTapVoiceToText,
    this.onTapVoiceHiddenText,
    this.onTapMultipleChoice,
    this.onTapRemind,
    this.onTapSearch,
    this.onTapFavorite,
    this.onTapChatPortrait,
    this.onDoubleTapChatPortrait,
    this.onLongPressChatPortrait,
  });

  // 消息内容以及聊天信息
  final Map<String, dynamic> msg, chatInfo;

  // 群聊成员信息
  final Map<String, dynamic>? member;

  // 聊天头像
  final String? chatPortrait;

  // 当单击消息时触发的回调
  final void Function()? onTapMsg, reEdit;

  // 当点击聊天头像回调
  final void Function(dynamic msg)? onTapChatPortrait,
      // 当双击聊天头像回调
      onDoubleTapChatPortrait,
      // 当长按聊天头像回调
      onLongPressChatPortrait;

  // 当点击复制菜单项时触发的回调
  final CallBack? onTapCopy;

  // 转发回调
  final CallBack? onTapRepost;

  // 收藏回调（未实现）
  final CallBack? onTapFavorite;

  // 删除回调（未实现）
  final CallBack? onTapDelete;

  // 撤回回调
  final CallBack? onTapRetract;

  // 引用回调（未实现）
  final CallBack? onTapCite;

  // 转文字回调（语音消息）
  final CallBack? onTapVoiceToText;

  // 隐藏文字回调（语音消息）
  final CallBack? onTapVoiceHiddenText;

  // 多选回调（未实现）
  final CallBack? onTapMultipleChoice;

  // 提醒回调（未实现）
  final CallBack? onTapRemind;

  // 点击搜一搜回调（未实现）
  final CallBack? onTapSearch;

  // 处理群聊消息的显示名称
  String _handlerGroupDisplayName() {
    Map<String, dynamic>? msgContent = msg['msgContent'] is String
        ? jsonDecode(msg['msgContent'])
        : msg['msgContent'];

    // 检查 member 是否为 null
    // if (member == null) return msg['msgContent']?['formUserName'] ?? '';
    if (member == null) return msgContent?['formUserName'] ?? '';
    // 尝试从 member 中获取优先属性
    try {
      return member?.containsKey('groupName') == true &&
              member!['groupName'] != null
          ? member!['groupName']!
          : member?.containsKey('remark') == true && member!['remark'] != null
              ? member!['remark']!
              : member!['name'] ?? '';
    } catch (e) {
      // 异常处理：返回一个空字符串或增加日志记录
      if (kDebugMode) print('Error fetching display name: $e');
      CustomFlutterToast.showErrorToast('Error fetching display name :$e');
      return '';
    }
  }

  // 构建聊天头像
  Widget _buildChatPortrait(dynamic msg, bool isRight, bool isGroup) {
    String? avatarUrl;
    Map<String, dynamic> msgContent = {};
    Widget? chatPortraitWidget;

    try {
      msgContent = msg['msgContent'] is String
          ? jsonDecode(msg['msgContent'])
          : msg['msgContent'];
      // 获取头像 URL
      avatarUrl = isRight
          ? globalData.currentPortrait
          : isGroup && !isRight
              ? msgContent['formUserPortrait']
              : chatPortrait;

      // 检查头像 URL 是否有效
      if (avatarUrl == null || avatarUrl.isEmpty) {
        throw Exception('头像 URL 无效');
      }
    } catch (e) {
      if (kDebugMode) print('获取头像出错: $e');
      CustomFlutterToast.showErrorToast('获取头像出错: $e');
      avatarUrl = chatPortrait; // 使用默认头像作为后备
    }
    chatPortraitWidget = CustomPortrait(
      url: avatarUrl!,
      size: 40,
      onTap: () {
        if (kDebugMode) print('点击头像 :$msg');
        onTapChatPortrait?.call(msg);
      },
      onDoubleTap: () {
        if (kDebugMode) print('双击头像 :$msg');
        onDoubleTapChatPortrait?.call(msg);
      },
      onLongPress: () {
        if (kDebugMode) print('长按头像 :$msg');
        onLongPressChatPortrait?.call(msg);
      },
    );
    if (msgContent['type'] == 'no_more') chatPortraitWidget = Container();
    return chatPortraitWidget;
  }

  // 长按消息弹出菜单项
  List<PopMenuItemModel> _menuItems(String type, {bool? toText = true}) => [
        if (type == 'text')
          PopMenuItemModel(
            title: '复制',
            icon: Icons.content_copy,
            callback: (data) {
              if (kDebugMode) print("data: ${data.toString()}");
              onTapCopy?.call(data);
            },
          ),
        if (type == 'voice' && toText!)
          PopMenuItemModel(
            title: '转文字',
            icon: Icons.text_fields,
            callback: (data) {
              if (kDebugMode) print("data: ${data.toString()}");
              onTapVoiceToText?.call(data);
            },
          ),
        if (type == 'voice' && !toText!)
          PopMenuItemModel(
            title: '隐藏',
            icon: Icons.high_quality,
            callback: (data) {
              if (kDebugMode) print("data: ${data.toString()}");
              onTapVoiceHiddenText?.call(data);
            },
          ),
        if (type != 'call')
          PopMenuItemModel(
              title: '转发',
              icon: Icons.send_sharp,
              callback: (data) {
                if (kDebugMode) print("data: ${data.toString()}");
                onTapRepost?.call(data);
              }),
        PopMenuItemModel(
            title: '收藏',
            icon: Icons.collections,
            callback: (data) {
              if (kDebugMode) print("data: ${data.toString()}");
              onTapFavorite?.call(data);
            }),
        PopMenuItemModel(
            title: '删除',
            icon: Icons.delete,
            callback: (data) {
              if (kDebugMode) print("data: ${data.toString()}");
              onTapDelete?.call(data);
            }),
        if (msg['fromId'] == globalData.currentUserId)
          PopMenuItemModel(
              title: '撤回',
              icon: Icons.reply_all,
              callback: (data) {
                if (kDebugMode) print("data: ${data.toString()}");
                onTapRetract?.call(data);
              }),
        PopMenuItemModel(
            title: '多选',
            icon: Icons.playlist_add_check,
            callback: (data) {
              if (kDebugMode) print("data: ${data.toString()}");
              onTapMultipleChoice?.call(data);
            }),
        PopMenuItemModel(
            title: '引用',
            icon: Icons.format_quote,
            callback: (data) {
              if (kDebugMode) print("data: ${data.toString()}");
              onTapCite?.call(data);
            }),
        PopMenuItemModel(
            title: '提醒',
            icon: Icons.add_alert,
            callback: (data) {
              if (kDebugMode) print("data: ${data.toString()}");
              onTapRemind?.call(data);
            }),
        if (type == 'text')
          PopMenuItemModel(
              title: '搜一搜',
              icon: Icons.search,
              callback: (data) {
                if (kDebugMode) print("data: ${data.toString()} ");
                onTapSearch?.call(data);
              }),
      ];

  // 根据消息类型获取组件
  Widget _getComponentByType(Map<String, dynamic> msg, bool isRight) {
    Map<String, dynamic> msgContent = msg['msgContent'] is String
        ? jsonDecode(msg['msgContent'])
        : msg['msgContent'];
    String? type = msgContent['type'];
    Map<String, dynamic>? content;
    if (type == 'voice') content = jsonDecode(msgContent['content']);
    final messageMap = {
      'no_more': (String? username) => Container(),
      'text': (String? username) => TextMessage(value: msg, isRight: isRight),
      'file': (String? username) => FileMessage(value: msg, isRight: isRight),
      'img': (String? username) => ImageMessage(value: msg, isRight: isRight),
      'retraction': (String? username) => RetractionMessage(
            isRight: isRight,
            userName: username,
          ),
      'voice': (String? username) => VoiceMessage(value: msg, isRight: isRight),
      'call': (String? username) => CallMessage(value: msg, isRight: isRight),
    };

    if (messageMap.containsKey(type)) {
      Map<String, dynamic> msgContent = msg['msgContent'] is String
          ? jsonDecode(msg['msgContent'])
          : msg['msgContent'];
      final messageWidget = messageMap[type]!(msgContent['formUserName']);

      return type == 'retraction' || chatInfo['name'] == null
          ? messageWidget
          : QuickPopUpMenu(
              showArrow: true,
              useGridView: true,
              darkMode: true,
              pressType: PressType.longPress,
              menuItems: _menuItems(type!,
                  toText: content != null
                      ? content['text'] == null || content['text'].isEmpty
                      : false),
              dataObj: messageWidget,
              child: messageWidget.onTap(() {
                if (kDebugMode) print('点击消息 :$msg');
                onTapMsg?.call();
              }),
            );
    } else
      // 异常处理
      return const Text('暂不支持该消息类型');
  }

  @override
  Widget build(BuildContext context) {
    bool isNoMore = msg['isNoMore'] == true;
    bool isRight = msg['fromId'] == globalData.currentUserId;
    Map<String, dynamic> msgContent;
    bool isRetract;
    if (msg['msgContent'] is String) {
      msgContent = jsonDecode(msg['msgContent']);
      isRetract = msgContent['type'] == 'retraction';
    } else {
      msgContent = msg['msgContent'];
      isRetract = msgContent['type'] == 'retraction';
    }
    bool isShowTime = msg['isShowTime'] == true;
    bool isGroupChat = chatInfo['type'] == 'group';
    bool isUserChat = chatInfo['type'] == 'user';
    bool isSystemMsg = msg['type'] == 'system';
    String displayName = isGroupChat ? _handlerGroupDisplayName() : '';

    return [
      const SizedBox(height: 10),
      if (isNoMore) const NoMoreContent(),
      // 时间组件
      if (isShowTime)
        TimeContent(value: DateUtil.formatTime(msg['createTime'])),
      // 系统消息
      if (isSystemMsg) SystemMessage(value: msg['msgContent'] ?? ''),
      // 群聊消息
      if (isGroupChat && !isSystemMsg)
        [
          if (!isRight && !isRetract) _buildChatPortrait(msg, isRight, true),
          const SizedBox(width: 5),
          [
            if (!isRetract && !isNoMore)
              Text(displayName).textColor(const Color(0xFF969696)).fontSize(12),
            if (!isNoMore) const SizedBox(height: 5),
            // 消息组件
            _getComponentByType(msg, isRight),
          ].toColumn(
              crossAxisAlignment:
                  isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start),
          if (isRetract && isRight && msgContent['ext'] == 'text') ...[
            const SizedBox(width: 1.2),
            [
              const SizedBox(height: 6),
              CustomTextButton(
                '重新编辑',
                fontSize: 12,
                onTap: () {
                  if (kDebugMode) print("重新编辑");
                  reEdit?.call();
                },
              ),
            ].toColumn(),
          ],
          const SizedBox(width: 5),
          if (isRight && !isRetract) _buildChatPortrait(msg, isRight, true),
        ]
            .toRow(
                mainAxisAlignment: isRetract
                    ? MainAxisAlignment.center
                    : isRight
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start)
            .align(isRight ? Alignment.centerRight : Alignment.centerLeft),

      // 私聊消息
      if (isUserChat)
        [
          if (!isRight && !isRetract) _buildChatPortrait(msg, isRight, false),
          const SizedBox(width: 5),
          [
            const SizedBox(height: 10),
            // 消息组件
            _getComponentByType(msg, isRight),
          ].toColumn(
              crossAxisAlignment:
                  isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start),
          if (isRetract && isRight && msgContent['ext'] == 'text') ...[
            const SizedBox(width: 1),
            [
              SizedBox(height: 12.4.h),
              CustomTextButton(
                '重新编辑',
                fontSize: 12,
                onTap: () {
                  if (kDebugMode) print("重新编辑");
                  reEdit?.call();
                },
              ),
            ].toColumn(),
          ],
          const SizedBox(width: 5),
          if (isRight && !isRetract) _buildChatPortrait(msg, isRight, false),
        ]
            .toRow(
              mainAxisAlignment: isRetract
                  ? MainAxisAlignment.center
                  : (isRight ? MainAxisAlignment.end : MainAxisAlignment.start),
              crossAxisAlignment: CrossAxisAlignment.start,
            )
            .align(isRight ? Alignment.centerRight : Alignment.centerLeft),
      if (!isNoMore) const SizedBox(height: 15),
    ].toColumn();
  }
}
