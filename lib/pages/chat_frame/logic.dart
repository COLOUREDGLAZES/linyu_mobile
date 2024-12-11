// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart'
    show
        BoolExtension,
        Get,
        GetNavigation,
        Inst,
        RxBool,
        RxString,
        StringExtension;
import 'package:image_picker/image_picker.dart';
import 'package:linyu_mobile/utils/api/chat_group_member.dart';
import 'package:linyu_mobile/utils/api/chat_list_api.dart';
import 'package:linyu_mobile/utils/api/msg_api.dart';
import 'package:linyu_mobile/utils/api/video_api.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/String.dart';
import 'package:linyu_mobile/utils/cropPicture.dart';
import 'package:linyu_mobile/utils/extension.dart';
import 'package:linyu_mobile/utils/config/getx/global_data.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:linyu_mobile/utils/config/network/web_socket.dart';
import 'package:dio/dio.dart' show MultipartFile, FormData;

import 'index.dart';

class ChatFrameLogic extends Logic<ChatFramePage> {
  // 后端接口
  final _msgApi = MsgApi();
  final _chatListApi = ChatListApi();
  final _wsManager = WebSocketUtil();
  final _videoApi = VideoApi();
  final _chatGroupMemberApi = ChatGroupMemberApi();

  // 控制器
  final TextEditingController msgContentController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // 焦点
  final FocusNode focusNode = FocusNode(skipTraversal: true);

  // 控制台类型
  final RxString panelType = "none".obs;

  // 群成员
  late Map<String, dynamic> members = {};

  // 消息记录
  late List<dynamic> msgList = [];

  // 目标id
  late String _targetId = '';

  // 聊天信息
  late dynamic chatInfo = {_targetId: ''};

  // 发送状态
  late RxBool isSend = false.obs;

  // 录制状态
  late RxBool isRecording = false.obs;

  // 是否只读
  late RxBool isReadOnly = false.obs;

  // 用于信息监听
  StreamSubscription? _subscription;

  // 全局数据
  final GlobalData _globalData = Get.find<GlobalData>();

  // 分页相关
  final int _num = 20;
  int _index = 0;
  bool isLoading = false;
  bool hasMore = true;

  // 监听消息
  void _eventListen() => _subscription = _wsManager.eventStream.listen((event) {
        if (event['type'] == 'on-receive-msg') {
          final data = event['content'];
          try {
            bool isRelevantMsg =
                (data['fromId'] == _targetId && data['source'] == 'user') ||
                    (data['toId'] == _targetId && data['source'] == 'group') ||
                    (data['fromId'] == _globalData.currentUserId &&
                        data['toId'] == _targetId);
            if (isRelevantMsg) {
              if (data['msgContent']['type'] == 'retraction') {
                msgList = msgList.replace(newValue: data);
                _onRead();
                update([const Key('chat_frame')]);
                return;
              }
              _onRead();
              _msgListAddMsg(event['content']);
            }
          } catch (e) {
            CustomFlutterToast.showErrorToast('处理消息时发生错误: $e');
          }
        }
      }, onError: (error) {
        CustomFlutterToast.showErrorToast('WebSocket发生错误: $error');
      });

  // 获取群成员
  void _onGetMembers() async {
    if (chatInfo['type'] == 'group')
      await _chatGroupMemberApi.list(_targetId).then((res) {
        if (res['code'] == 0) {
          members = res['data'];
          update([const Key('chat_frame')]);
        }
      });
  }

  // 获取消息记录
  Future<void> _onGetMsgRecode() async {
    if (isLoading) return; // 防止重复加载
    isLoading = true;
    update([const Key('chat_frame')]);
    try {
      final res = await _msgApi.record(_targetId, _index, _num);
      if (res['code'] == 0 && res['data'] is List) {
        // 确认返回的数据类型
        msgList = res['data'];
        _index += msgList.length;
        hasMore = msgList.isNotEmpty; // 判断是否还有更多数据
        update([const Key('chat_frame')]);
        scrollBottom();
      } else {
        CustomFlutterToast.showErrorToast(
            '获取消息记录失败: ${res['message'] ?? '未知错误'}');
      }
    } catch (e) {
      CustomFlutterToast.showErrorToast('获取消息记录时发生错误: $e');
    } finally {
      isLoading = false;
      update([const Key('chat_frame')]);
    }
  }

  // 加载更多
  Future<void> _loadMore() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    update([const Key('chat_frame')]);
    try {
      final res = await _msgApi.record(_targetId, _index, _num);
      if (res['code'] == 0) {
        if (res['data'].isEmpty)
          hasMore = false;
        else {
          final double previousScrollOffset = scrollController.position.pixels;
          final double previousMaxScrollExtent =
              scrollController.position.maxScrollExtent;
          msgList.insertAll(0, res['data']);
          _index = msgList.length;
          hasMore = res['data'].length >= 0;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final double newMaxScrollExtent =
                scrollController.position.maxScrollExtent;
            final double newOffset = previousScrollOffset +
                (newMaxScrollExtent - previousMaxScrollExtent) -
                10;
            scrollController.animateTo(
              newOffset,
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
            );
          });
        }
      }
    } finally {
      isLoading = false;
      update([const Key('chat_frame')]);
    }
  }

  // 滚动到底部
  void scrollBottom() {
    if (scrollController.hasClients)
      WidgetsBinding.instance
          .addPostFrameCallback((_) => scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              ));
  }

  // 切换面板类型
  void toDetailsPage() {
    try {
      final route =
          chatInfo['type'] == 'group' ? '/chat_group_info' : '/friend_info';
      final arguments = chatInfo['type'] == 'group'
          ? {'chatGroupId': _targetId}
          : {'friendId': _targetId};
      Get.offAndToNamed(route, arguments: arguments);
    } catch (e) {
      CustomFlutterToast.showErrorToast('导航到详情页时发生错误: $e');
    }
  }

  // 发送文本消息
  void sendTextMsg() async {
    if (StringUtil.isNullOrEmpty(msgContentController.text)) return;
    final String content = msgContentController.text;
    dynamic msg = {
      'toUserId': _targetId,
      'source': chatInfo['type'],
      'msgContent': {'type': "text", 'content': content}
    };
    msgContentController.clear(); // 使用clear()简化设置为空字符串
    try {
      final res = await _msgApi.send(msg);
      if (res['code'] == 0) {
        isSend.value = false;
        _msgListAddMsg(res['data']);
        _onRead();
      } else {
        CustomFlutterToast.showErrorToast('发送失败: ${res['message'] ?? '未知错误'}');
      }
    } catch (e) {
      CustomFlutterToast.showErrorToast('发送消息时发生错误: $e');
    }
  }

  //添加新的消息
  void _msgListAddMsg(msg) {
    if (msg == null) {
      CustomFlutterToast.showErrorToast('消息内容不能为空');
      return;
    }
    try {
      msgList.add(msg);
      _index = msgList.length;
      update([const Key('chat_frame')]);
      scrollBottom();
    } catch (e) {
      CustomFlutterToast.showErrorToast('添加消息时发生错误: $e');
    }
  }

  // 消息已读
  void _onRead() async {
    try {
      await _chatListApi.read(_targetId);
      _globalData.onGetUserUnreadInfo();
    } catch (e) {
      CustomFlutterToast.showErrorToast('标记为已读时发生错误: $e');
    }
  }

  // 音视通话
  void onInviteVideoChat(isOnlyAudio) =>
      _videoApi.invite(_targetId, isOnlyAudio).then((res) {
        if (res['code'] == 0)
          Get.toNamed('video_chat', arguments: {
            'userId': _targetId,
            'isSender': true,
            'isOnlyAudio': isOnlyAudio,
          });
      });

  // 选择图片
  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path != null) {
      File file = File(path);
      _onSendImgOrFileMsg(file, 'file');
    }
  }

  // 发送图片或文件消息
  Future<void> _onSendImgOrFileMsg(File file, type) async {
    if (StringUtil.isNullOrEmpty(file.path)) return;
    String fileName = file.path.split('/').last;
    final fileData =
        await MultipartFile.fromFile(file.path, filename: fileName);
    dynamic msg = {
      'toUserId': _targetId,
      'source': chatInfo['type'],
      'msgContent': {
        'type': type,
        'content': jsonEncode({
          'name': fileName,
          'size': fileData.length,
        })
      }
    };
    _msgApi.send(msg).then((res) {
      if (res['code'] == 0 && StringUtil.isNotNullOrEmpty(res['data']?['id'])) {
        Map<String, dynamic> map = {};
        map["file"] = fileData;
        map['msgId'] = res['data']['id'];
        FormData formData = FormData.fromMap(map);
        _msgApi.sendMedia(formData).then((v) {
          _msgListAddMsg(res['data']);
          _onRead();
        });
      }
    });
  }

  //上传图片
  Future<void> _onUploadImg(File file) async =>
      _onSendImgOrFileMsg(file, 'img');

  // 裁剪图片
  Future cropChatPicture(ImageSource? type) async =>
      cropPicture(type, _onUploadImg, isVariable: true);

  // 发送语音消息
  void onSendVoiceMsg(filePath, time) async {
    if (StringUtil.isNullOrEmpty(filePath)) return;
    if (time == 0) {
      CustomFlutterToast.showSuccessToast('录制时间太短~');
      return;
    }
    MultipartFile file =
        await MultipartFile.fromFile(filePath, filename: 'voice.wav');
    dynamic msg = {
      'toUserId': _targetId,
      'source': chatInfo['type'],
      'msgContent': {
        'type': "voice",
        'content': jsonEncode({
          'name': 'voice.wav',
          'size': file.length,
          'time': time,
        })
      }
    };
    _msgApi.send(msg).then((res) {
      if (res['code'] == 0 && StringUtil.isNotNullOrEmpty(res['data']?['id'])) {
        Map<String, dynamic> map = {};
        map["file"] = file;
        map['msgId'] = res['data']['id'];
        FormData formData = FormData.fromMap(map);
        _msgApi.sendMedia(formData).then((v) {
          _msgListAddMsg(res['data']);
          _onRead();
        });
      }
    });
  }

  //点击通话消息记录
  void onTapMsg(dynamic msg) {
    widget?.hidePanel();
    final msgContent = msg['msgContent'] as Map<String, dynamic>;
    // 检查消息类型是否为非文本类型
    if (msgContent['type'] != 'text')
      try {
        final Map<String, dynamic> content = jsonDecode(msgContent['content']);
        // 处理通话消息
        if (msgContent['type'] == 'call')
          onInviteVideoChat(content['type'] != 'video');
      } catch (e) {
        CustomFlutterToast.showErrorToast('解析消息内容时发生错误: $e');
      }
  }

  //撤回消息
  void retractMsg(dynamic data, dynamic msg) async {
    try {
      final result = await _msgApi.retract(msg['id'], _targetId);
      if (result['code'] == 0) {
        msgList = msgList.replace(oldValue: msg, newValue: result['data']);
        CustomFlutterToast.showSuccessToast('撤回成功');
      } else
        CustomFlutterToast.showErrorToast(
            '撤回失败: ${result['message'] ?? '未知错误'}');
    } catch (e) {
      CustomFlutterToast.showErrorToast('撤回失败: $e');
    } finally {
      isLoading = false;
      update([const Key('chat_frame')]);
    }
  }

  // 重新编辑消息
  void reEditMsg(dynamic msg) async {
    try {
      final result = await _msgApi.reEdit(msg['id']);
      if (result['code'] == 0) {
        msgContentController.text = result['data']['msgContent']['content'];
        isRecording.value = false;
        isSend.value = true;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => focusNode.requestFocus());
        update([const Key('chat_frame')]);
      } else
        CustomFlutterToast.showErrorToast(
            '重新编辑消息失败: ${result['message'] ?? '未知错误'}');
    } catch (e) {
      CustomFlutterToast.showErrorToast('编辑消息时发生错误: $e');
    }
  }

  //更新消息列表
  void _updateMessageList(dynamic oldMsg, dynamic newMsg) {
    msgList = msgList.replace(oldValue: oldMsg, newValue: newMsg);
    update([const Key('chat_frame')]);
  }

  // 处理语音转文字错误
  void _handleVoiceToTextError(
      dynamic msg, Map<String, dynamic> content, String errorMessage) {
    CustomFlutterToast.showErrorToast(errorMessage);
    content['text'] = '';
    msgList = msgList.replace(
        oldValue: msg,
        newValue: msg..['msgContent']['content'] = jsonEncode(content));
    update([const Key('chat_frame')]);
  }

  // 语音转文字
  void onVoiceToTxt(dynamic msg) async {
    Map<String, dynamic> newMsg = Map<String, dynamic>.from(msg);
    var content = jsonDecode(newMsg['msgContent']['content']);
    content['text'] = '正在识别中...';
    newMsg['msgContent']['content'] = jsonEncode(content);
    _updateMessageList(msg, newMsg);
    try {
      final result = await _msgApi.voiceToText(msg['id']);
      if (result['code'] == 0)
        _updateMessageList(msg, result['data']);
      else
        _handleVoiceToTextError(msg, content, '语音转文字失败: 网络错误');
    } catch (e) {
      CustomFlutterToast.showErrorToast('语音转文字时发生错误: $e');
    }
  }

  // 隐藏文字
  void onHideText(dynamic msg) {
    try {
      Map<String, dynamic> newMsg = Map<String, dynamic>.from(msg);
      var content = jsonDecode(newMsg['msgContent']['content']);
      // 仅在文本非空时才进行替换，以减少不必要的操作
      if (content['text'] != '' || content['text'] != null) {
        content['text'] = '';
        newMsg['msgContent']['content'] = jsonEncode(content);
        msgList = msgList.replace(oldValue: msg, newValue: newMsg);
        update([const Key('chat_frame')]);
      }
    } catch (e) {
      CustomFlutterToast.showErrorToast('隐藏文字时发生错误: $e');
    }
  }

  @override
  void onInit() {
    chatInfo = Get.arguments?['chatInfo'] ?? {};
    _targetId = chatInfo['fromId'] ?? '';
    super.onInit();
    _onGetMembers();
    _onGetMsgRecode();
    _eventListen();
    _onRead();
    // 添加滚动监听
    scrollController.addListener(() {
      if (scrollController.hasClients &&
          scrollController.position.pixels ==
              scrollController.position.minScrollExtent) _loadMore();
    });
  }

  @override
  void onClose() {
    super.onClose();
    msgContentController.dispose();
    scrollController.dispose();
    _subscription?.cancel();
    focusNode.dispose();
  }
}
