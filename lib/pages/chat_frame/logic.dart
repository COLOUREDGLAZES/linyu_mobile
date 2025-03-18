import 'dart:async' show Future, StreamSubscription;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show File;

import 'package:chat_bottom_container/panel_container.dart';
import 'package:chat_bottom_container/typedef.dart';
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:file_picker/file_picker.dart' show FilePicker, FilePickerResult;
import 'package:flutter/cupertino.dart'
    show
        Curves,
        FocusNode,
        Key,
        ScrollController,
        StringCharacters,
        TextEditingController,
        TextEditingValue,
        TextSelection,
        WidgetsBinding;
import 'package:flutter/foundation.dart' show Key, kDebugMode;
import 'package:get/get.dart'
    show Get, GetNavigation, Inst, RxString, StringExtension;
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/String.dart';
import 'package:linyu_mobile/utils/api/chat_group_member.dart';
import 'package:linyu_mobile/utils/api/chat_list_api.dart';
import 'package:linyu_mobile/utils/api/friend_api.dart';
import 'package:linyu_mobile/utils/api/msg_api.dart';
import 'package:linyu_mobile/utils/api/video_api.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart' show Logic;
import 'package:linyu_mobile/utils/crop_picture.dart';
import 'package:linyu_mobile/utils/extension.dart';

import 'index.dart';

class ChatFrameLogic extends Logic<ChatFramePage> {
  // 后端接口
  final _msgApi = MsgApi();
  final _chatListApi = ChatListApi();
  final _videoApi = VideoApi();
  final _chatGroupMemberApi = ChatGroupMemberApi();
  final _friendApi = new FriendApi();

  // 输入框控制器
  final TextEditingController msgContentController = TextEditingController();

  // 滑动控制器
  final ScrollController scrollController = ScrollController();

  // 焦点
  final FocusNode focusNode = FocusNode(skipTraversal: true);
  final RxString panelType = "none".obs;
  late Map<String, dynamic> members = {};

  // 消息记录
  late List<dynamic> msgList = [];
  late String _targetId = '';
  late dynamic chatInfo = {_targetId: ''};

  bool _isSend = false;

  bool get isSend => _isSend;

  set isSend(bool value) {
    _isSend = value;
    update([const Key('chat_frame')]);
  }

  // 录制状态
  // late RxBool isRecording = false.obs;

  bool _isRecording = false;

  bool get isRecording => _isRecording;

  set isRecording(bool value) {
    _isRecording = value;
    update([const Key('chat_frame')]);
  }

  // late RxBool isReadOnly = false.obs;

  bool _isReadOnly = false;

  bool get isReadOnly => _isReadOnly;

  set isReadOnly(bool value) {
    _isReadOnly = value;
    update([const Key('chat_frame')]);
  }

  // 用于信息监听
  StreamSubscription? _subscription;

  // 聊天背景
  String _chatBackground = '';

  String get chatBackground => _chatBackground;

  set chatBackground(String value) {
    _chatBackground = value;
    update([const Key('chat_frame')]);
  }

  // 分页相关
  final int _num = 20;
  int _index = 0;
  bool isLoading = false;
  bool hasMore = true;

  // 是否为好友
  bool _isFriend = true;

  bool get isFriend => _isFriend;

  set isFriend(bool value) {
    _isFriend = value;
    update([const Key('chat_frame')]);
  }

  // 是否在底部
  bool _isOnBottom = false;

  bool get isOnBottom => _isOnBottom;

  set isOnBottom(bool value) {
    _isOnBottom = value;
    update([const Key('chat_frame')]);
  }

  double _previousOffset = 0.0;

  bool _isUpSroll = false;

  bool get isUpSroll => _isUpSroll;

  set isUpSroll(bool value) {
    _isUpSroll = value;
    update([const Key('chat_frame')]);
  }

  // 心灵鸡汤
  Map<String, dynamic> lifeStr = {
    'data': {
      'content': '死生契阔，与子成说~',
      // 'content': '输入文字~',
    }
  };

  // 消息已读
  Future<void> _onRead(String? targetId) async {
    try {
      if (kDebugMode) print('onRead:$_targetId');
      targetId ??= _targetId;
      await _chatListApi.read(targetId);
      await globalData.onGetUserUnreadInfo();
    } catch (e) {
      if (kDebugMode) print('onRead error: $e');
      Get.delete<ChatFrameLogic>();
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 监听消息
  void _eventListen() => _subscription = wsManager.eventStream.listen((event) {
        if (event['type'] == 'on-receive-msg') {
          final data = event['content'];
          try {
            bool isRelevantMsg =
                (data['fromId'] == _targetId && data['source'] == 'user') ||
                    (data['toId'] == _targetId && data['source'] == 'group') ||
                    (data['fromId'] == globalData.currentUserId &&
                        data['toId'] == _targetId);
            if (isRelevantMsg) {
              if (data['msgContent']['type'] == 'retraction') {
                msgList = msgList.replace(newValue: data);
                _onRead(null);
                update([const Key('chat_frame')]);
                return;
              }
              _onRead(null);
              _msgListAddMsg(event['content']);
            }
          } catch (e) {
            CustomFlutterToast.showErrorToast('处理消息时发生错误: $e');
          }
        }
      }, onError: (error) {
        CustomFlutterToast.showErrorToast('WebSocket发生错误: $error');
        if (!wsManager.isConnected) wsManager.connect();
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
  Future<void> _onGetMsgRecode({int? index}) async {
    // lifeStr = await _msgApi.getLifeString();
    if (isLoading) return; // 防止重复加载
    isLoading = true;
    try {
      //先获取本地消息记录
      // if (kDebugMode) print('sqfliteHelper: $sqfliteHelper');
      // List<dynamic> localMsgList = await sqfliteHelper.queryMessageByCondition(
      //     globalData.currentUserId, _targetId, index ?? _index, _num);
      // msgList = localMsgList.copy();
      // if (kDebugMode) print('msgList :${msgList.length}');
      // if (msgList.isEmpty) {
      // 本地消息记录为空，从服务器获取
      final res = await _msgApi.record(_targetId, index ?? _index, _num);
      if (res['code'] == 0 && res['data'] is List) {
        // 确认返回的数据类型
        msgList = res['data'];
        _index += msgList.length;
        hasMore = msgList.isNotEmpty; // 判断是否还有更多数据
      }
      // }
    } catch (e) {
      if (kDebugMode) print('onGetMsgRecode error: $e');
    } finally {
      isLoading = false;
      scrollBottom();
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
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            );
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print('loadMore error: $e');
    } finally {
      isLoading = false;
      update([const Key('chat_frame')]);
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 滚动到底部
  void scrollBottom() {
    try {
      if (scrollController.hasClients)
        WidgetsBinding.instance
            .addPostFrameCallback((_) => scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                ));
    } on Exception catch (e) {
      if (kDebugMode) print('scrollBottom error: $e');
    } finally {
      update([const Key('chat_frame')]);
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 查看双方是否为好友
  Future<bool> _onCheckFriend(String friendId) async {
    try {
      final result = await _friendApi.details(friendId);
      return isFriend = result['code'] == 0;
    } catch (e) {
      CustomFlutterToast.showErrorToast('检查是否为好友时发生错误: $e');
      return false;
    }
  }

  // 进入聊天设置页面
  void toChatSetting() async {
    try {
      // 检查聊天对象是否为好友或群是否已解散
      if ((chatInfo['type'] == 'user' && !await _onCheckFriend(_targetId)) ||
          (chatInfo['type'] == 'group' && chatInfo['name'] == null)) {
        CustomFlutterToast.showErrorToast(
            chatInfo['type'] == 'user' ? 'Ta还不是好友哦' : '该群已解散~');
        return;
      }

      final result = await Get.toNamed('/chat_setting', arguments: chatInfo);
      if (result != null) {
        if (kDebugMode) print('chat_setting result is: $result');
        await _onGetMsgRecode(index: 0);
      }
    } catch (error) {
      CustomFlutterToast.showErrorToast('导航到详情页时发生错误: $error');
      if (kDebugMode) print('导航到详情页时发生错误: $error');
    } finally {
      // 判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 发送文本消息
  void sendTextMsg({String? text}) async {
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
        isSend = false;
        _msgListAddMsg(res['data']);
        await _onRead(null);
      } else
        CustomFlutterToast.showErrorToast('发送失败: ${res['message'] ?? '未知错误'}');
    } catch (e) {
      if (kDebugMode) print('发送消息时发生错误: $e');
    }
  }

  // 把消息添加到消息列表中
  void _msgListAddMsg(Map<String, dynamic> msg) async {
    if (msg == null) {
      CustomFlutterToast.showErrorToast('消息内容不能为空');
      return;
    }
    try {
      if (msg['msgContent'] is Map) {
        String msgContent = jsonEncode(msg['msgContent']);
        if (kDebugMode) print('onClose msgContent: $msgContent');
        msg['msgContent'] = msgContent;
      }
      if (msg['lastMsgContent'] is Map) {
        String lastMsgContent = jsonEncode(msg['lastMsgContent']);
        if (kDebugMode) print('onClose lastMsgContent: $lastMsgContent');
        msg['lastMsgContent'] = lastMsgContent;
      }
      // final int? insertMsg = await sqfliteHelper.insert(msg);
      // if (insertMsg != null) {
      msgList.add(msg);
      _index = msgList.length;
      update([const Key('chat_frame')]);
      scrollBottom();
      // } else
      //   CustomFlutterToast.showErrorToast('消息保存失败');
    } catch (e) {
      if (kDebugMode) print('添加消息时发生错误: $e');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 音视通话
  void onInviteVideoChat(isOnlyAudio) =>
      _videoApi.invite(_targetId, isOnlyAudio).then((res) => res['code'] == 0
          ? Get.toNamed('video_chat', arguments: {
              'userId': _targetId,
              'isSender': true,
              'isOnlyAudio': isOnlyAudio,
            })
          : CustomFlutterToast.showErrorToast('${res['msg']}'));

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
          _onRead(null);
        });
      }
    });
  }

  // 选择文件
  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path != null) {
      File file = new File(path);
      _onSendImgOrFileMsg(file, 'file');
    }
  }

  // 上传图片
  Future<void> _onUploadImg(File file) async =>
      _onSendImgOrFileMsg(file, 'img');

  // 选择图片
  Future cropChatPicture(ImageSource? type) async =>
      cropPicture(type, _onUploadImg, isVariable: true);

  // 发送语音消息
  void onSendVoiceMsg(String filePath, int time) async {
    if (StringUtil.isNullOrEmpty(filePath)) return;
    if (time == 0) {
      CustomFlutterToast.showSuccessToast('录制时间太短~');
      return;
    }
    try {
      // 上传语音文件
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
      final res = await _msgApi.send(msg);
      if (res['code'] == 0 && StringUtil.isNotNullOrEmpty(res['data']?['id'])) {
        Map<String, dynamic> map = {
          "file": file,
          'msgId': res['data']['id'],
        };
        FormData formData = FormData.fromMap(map);
        await _msgApi.sendMedia(formData);
        _msgListAddMsg(res['data']);
        await _onRead(null);
      }
    } catch (e) {
      if (kDebugMode) print('发送语音消息时发生错误: $e');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 点击消息记录
  void onTapMsg(dynamic msg) {
    hidePanel(view?.panelController as ChatBottomPanelContainerController);
    final Map<String, dynamic> msgContent;
    if (msg['msgContent'] is String)
      msgContent = jsonDecode(msg['msgContent']);
    else
      msgContent = msg['msgContent'] as Map<String, dynamic>;
    // 检查消息类型是否为非文本类型
    if (msgContent['type'] != 'text')
      try {
        final Map<String, dynamic> content = jsonDecode(msgContent['content']);
        // 处理通话消息
        if (msgContent['type'] == 'call')
          onInviteVideoChat(content['type'] != 'video');
      } catch (e) {
        if (kDebugMode) print('解析消息内容时发生错误: $e');
      } finally {
        //判断websocket是否连接
        if (!wsManager.isConnected) wsManager.connect();
      }
  }

  // 撤回消息
  void retractMsg(dynamic msg) async {
    try {
      final result = await _msgApi.retract(msg['id'], _targetId);
      if (result['code'] == 0) {
        msgList = msgList.replace(oldValue: msg, newValue: result['data']);
        update([const Key('chat_frame')]);
        CustomFlutterToast.showSuccessToast('撤回成功');
      } else
        CustomFlutterToast.showErrorToast(
            '撤回失败: ${result['message'] ?? '未知错误'}');
    } catch (e) {
      if (kDebugMode) print('撤回消息时发生错误: $e');
      CustomFlutterToast.showErrorToast('撤回失败~');
    } finally {
      isLoading = false;
      update([const Key('chat_frame')]);
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 重新编辑消息
  void reEditMsg(dynamic msg) async {
    try {
      final result = await _msgApi.reEdit(msg['id']);
      if (result['code'] == 0) {
        msgContentController.text = result['data']['msgContent']['content'];
        isRecording = false;
        isSend = true;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => focusNode.requestFocus());
        update([const Key('chat_frame')]);
      } else
        CustomFlutterToast.showErrorToast(
            '重新编辑消息失败: ${result['message'] ?? '未知错误'}');
    } catch (e) {
      CustomFlutterToast.showErrorToast('编辑消息时发生错误: $e');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 更新消息列表
  void _updateMessageList(dynamic oldMsg, dynamic newMsg) {
    msgList = msgList.replace(oldValue: oldMsg, newValue: newMsg);
    update([const Key('chat_frame')]);
  }

  // 处理语音转文字错误
  void _handleVoiceToTextError(
      dynamic msg, Map<String, dynamic> content, String errorMessage) {
    CustomFlutterToast.showErrorToast(errorMessage);
    content['text'] = '网络错误，语音转文字失败~';
    Map<String, dynamic> msgContent = msg['msgContent'] is String
        ? jsonDecode(msg['msgContent'])
        : msg['msgContent'] as Map<String, dynamic>;
    msgContent['content'] = jsonEncode(content);
    final Map<String, dynamic> newMsg = Map<String, dynamic>.from(msg);

    newMsg['msgContent'] =
        newMsg['msgContent'] is String ? jsonEncode(msgContent) : msgContent;

    msgList = msgList.replace(oldValue: msg, newValue: newMsg);
    update([const Key('chat_frame')]);
  }

  // 语音转文字
  void onVoiceToTxt(dynamic msg) async {
    if (kDebugMode) print("from chat_frame: $msg");
    final fromForwardMsgId = msg['fromForwardMsgId'];
    // 显示转文字tips
    Map<String, dynamic> newMsg = Map<String, dynamic>.from(msg);

    final Map<String, dynamic> msgContent;
    msgContent = msg['msgContent'] is String
        ? jsonDecode(msg['msgContent'])
        : msg['msgContent'] as Map<String, dynamic>;

    var content = jsonDecode(msgContent['content']);
    content['text'] = '正在识别中...';
    // newMsg['msgContent']['content'] = jsonEncode(content);
    msgContent['content'] = jsonEncode(content);

    newMsg['msgContent'] = msg['msgContent'] is String
        ? jsonEncode(msgContent)
        : newMsg['msgContent'] = msgContent;

    _updateMessageList(msg, newMsg);
    // 转文字
    try {
      // 优先使用转发消息的id，否则使用当前消息的id
      final String useId = fromForwardMsgId ?? msg['id'];
      // 转文字
      final result = await _msgApi.voiceToText(
        useId,
        isChatGroupMessage: msg['source'] == 'group',
      );
      if (kDebugMode) print('转文字 result is: $result');
      if (result['code'] == 0) {
        final resultMsg = result['data'];
        if (kDebugMode) print('newMsg data: $resultMsg');
        resultMsg['id'] = msg['id'];
        resultMsg['fromForwardMsgId'] = fromForwardMsgId;
        resultMsg['fromId'] = msg['fromId'];

        if (resultMsg['msgContent'] is String || msg['msgContent'] is String) {
          Map<String, dynamic> newMsgContent = resultMsg['msgContent'] is String
              ? jsonDecode(resultMsg['msgContent'])
              : resultMsg['msgContent'] as Map<String, dynamic>;
          Map<String, dynamic> msgContent = msg['msgContent'] is String
              ? jsonDecode(msg['msgContent'])
              : msg['msgContent'] as Map<String, dynamic>;
          newMsgContent['formUserPortrait'] = msgContent['formUserPortrait'];
          resultMsg['msgContent'] = resultMsg['msgContent'] is String
              ? jsonEncode(newMsgContent)
              : newMsgContent;
        } else
          resultMsg['msgContent']['formUserPortrait'] =
              msg['msgContent']['formUserPortrait'];

        if (kDebugMode) print('the resultMsg data is: $resultMsg');

        _updateMessageList(msg, resultMsg);
      } else
        _handleVoiceToTextError(msg, content, '语音转文字失败: 网络错误');
    } catch (e) {
      // CustomFlutterToast.showErrorToast('语音转文字时发生错误: $e');
      if (kDebugMode) print('语音转文字时发生错误: $e');
      content['text'] = '识别失败!';
      _updateMessageList(
          msg, msg..['msgContent']['content'] = jsonEncode(content));
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 隐藏文字
  void onHideText(dynamic msg) {
    try {
      Map<String, dynamic> newMsg = Map<String, dynamic>.from(msg);

      final Map<String, dynamic> msgContent = newMsg['msgContent'] is String
          ? jsonDecode(newMsg['msgContent'])
          : newMsg['msgContent'] as Map<String, dynamic>;

      var content = jsonDecode(msgContent['content']);
      // 仅在文本非空时才进行替换，以减少不必要的操作
      if (content['text'] != '' || content['text'] != null) {
        content['text'] = '';
        msgContent['content'] = jsonEncode(content);
        newMsg['msgContent'] = newMsg['msgContent'] is String
            ? jsonEncode(msgContent)
            : msgContent;
        msgList = msgList.replace(oldValue: msg, newValue: newMsg);
        update([const Key('chat_frame')]);
      }
    } catch (e) {
      if (kDebugMode) print('隐藏文字时发生错误: $e');
      // CustomFlutterToast.showErrorToast('隐藏文字时发生错误: $e');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 点击表情添加到消息输入框
  void onEmojiTap(String emoji) {
    try {
      if (emoji.isEmpty) return; // 检查传入的表情是否为空
      if (msgContentController.text.isEmpty) update([const Key('chat_frame')]);
      final text = msgContentController.text;
      final selection = msgContentController.selection;
      // 使用 StringBuffer 减少不必要的字符串创建
      final newText = StringBuffer()
        ..write(text.substring(0, selection.start))
        ..write(emoji)
        ..write(text.substring(selection.end));
      msgContentController.value = TextEditingValue(
        text: newText.toString(),
        selection: TextSelection.collapsed(
          offset: selection.start + emoji.length,
        ),
      );
      isSend = true;
    } catch (e) {
      CustomFlutterToast.showErrorToast('添加表情时发生错误: $e');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 转发消息
  void onRepostMsg(dynamic msg) async {
    try {
      final resultMsg = await Get.toNamed('/repost', arguments: {'msg': msg});
      if (kDebugMode) print('result: $resultMsg');
      await _onGetMsgRecode(index: 0);
    } on Exception catch (e) {
      CustomFlutterToast.showErrorToast('转发消息失败~');
      if (kDebugMode) print('转发消息时发生错误: $e');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 当前聊天对象不是好友点击添加好友
  void onTapAddFriend() async {
    if (kDebugMode) print('chat_frame chatInfo: $chatInfo');
    try {
      final friend = {
        'id': _targetId,
        'name': chatInfo['name'] ?? '',
        'portrait': chatInfo['portrait'] ?? '',
      };
      final result = await Get.toNamed('/friend_request',
          arguments: {'friendInfo': friend});
      if (result != null && result) await _onGetMsgRecode(index: 0);
    } catch (e) {
      if (kDebugMode) print('添加好友失败: $e');
      CustomFlutterToast.showErrorToast('添加好友失败~');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 点击头像查看用户详情
  void onTapChatPortrait(dynamic msg) async {
    try {
      // 点击自己的头像查看个人信息
      if (globalData.currentUserId == msg['fromId']) {
        final result = await Get.toNamed('/friend_info', arguments: {
          'friendId': msg['fromId'],
          'isFromChatPage': true,
        });
        if (result != null && result) await _onGetMsgRecode(index: 0);
        return;
      }
      // 点击私聊中的头像查看用户详情
      if (msg['source'] == 'user' &&
          globalData.currentUserId != msg['fromId']) {
        // 先检查是否为好友
        if (!await _onCheckFriend(msg['fromId'])) {
          CustomFlutterToast.showErrorToast('Ta还不是好友哦');
          return;
        }
        // 点击用户头像查看用户详情
        final result = await Get.toNamed('/friend_info', arguments: {
          'friendId': msg['fromId'],
          'isFromChatPage': true,
        });
        if (result != null && result) await _onGetMsgRecode(index: 0);
        return;
      }
      // 在群聊中点击头像查看用户详情
      if (globalData.currentUserId != msg['fromId'] &&
          msg['source'] == 'group') {
        // 先检查是否为好友
        final friendData = await _friendApi.details(msg['fromId']);
        if (kDebugMode) print('friend data: $friendData');
        // 不是好友先添加好友
        if (friendData['code'] != 0) {
          CustomFlutterToast.showErrorToast('Ta还不是好友');
          final friend = {
            'id': msg['fromId'],
            'name': msg['msgContent']['formUserName'] ?? '',
            'portrait': msg['msgContent']['formUserPortrait'] ?? '',
          };
          final result = await Get.toNamed('/friend_request',
              arguments: {'friendInfo': friend});
          if (result != null && result) await _onGetMsgRecode(index: 0);
          return;
        }
        // 点击当前聊天框内好友头像查看好友详情
        final result = await Get.toNamed('/friend_info', arguments: {
          'friendId': msg['fromId'],
          'isFromChatGroupPage': true,
        });
        if (result != null) {
          chatInfo = result;
          _targetId = chatInfo['fromId'];
          // 聊天背景本地获取
          chatBackground =
              sharedPreferences.getString('${_targetId}_chat_background') ?? '';
          // 若本地没有获取到则从网络获取聊天背景
          if (chatBackground.isEmpty) {
            chatBackground = chatInfo['chatBackground'] ?? '';
            // 保存聊天背景到本地
            if (chatBackground.isNotEmpty)
              sharedPreferences.setString(
                  '${_targetId}_chat_background', chatBackground);
          }
          await _onGetMsgRecode(index: 0);
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) print('查看用户详情时发生错误: $e');
      CustomFlutterToast.showErrorToast('查看用户详情失败~');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 在表情面板中点击删除按钮
  void removeChar() {
    String originalText = msgContentController.text;
    dynamic text;
    if (originalText.isNotEmpty) {
      text = originalText.characters.skipLast(1);
      msgContentController.text =
          "$text"; // 这里是做一次字符串的转化，我们不能直接as String去转，不然会报错
    }
    if (msgContentController.text.isEmpty) {
      update([const Key('chat_frame')]);
      isSend = false;
    }
  }

  // 保存消息到本地
  void saveMsgToLocal() async {
    List newMsgList = new List.generate(msgList.length, (index) {
      if (msgList[index]['msgContent'] is Map) {
        String msgContent = jsonEncode(msgList[index]['msgContent']);
        if (kDebugMode) print('onClose msgContent: $msgContent');
        msgList[index]['msgContent'] = msgContent;
      }
      if (msgList[index]['lastMsgContent'] is Map) {
        String lastMsgContent = jsonEncode(msgList[index]['lastMsgContent']);
        if (kDebugMode) print('onClose lastMsgContent: $lastMsgContent');
        msgList[index]['lastMsgContent'] = lastMsgContent;
      }
      return msgList[index];
    });
    if (newMsgList.isNotEmpty) newMsgList.removeAt(0);
    int? result = await sqfliteHelper.updateOrInsertAll(newMsgList);
    if (result != null) if (kDebugMode)
      print('onClose insertAll result: $result');
  }

  //当加载完所有消息时
  void hasBeenLoaded() {
    if (!hasMore && msgList.isNotEmpty) {
      final Map<String, dynamic> noMore = Map.from(msgList[0]);
      if (noMore['isNoMore'] == null || !noMore['isNoMore']) {
        noMore['id'] = 'no_more';
        noMore['isNoMore'] = true;
        noMore['isShowTime'] = false;
        noMore['msgContent'] = {
          "no_more_flag": true,
          "formUserId": "xxx",
          "formUserName": "xxx",
          "formUserPortrait": "xxx",
          "type": "no_more",
          "content": "没有更多消息了"
        };
        msgList.insert(0, noMore);
      }
    }
  }

  //删除消息
  void deleteMsg(dynamic data, Map<String, dynamic> msg, int index) async {
    try {
      final int? result = await sqfliteHelper.delete(msg['id']);
      if (result != null || result != 0) {
        msgList.removeAt(index);
        update([const Key('chat_frame')]);
        CustomFlutterToast.showSuccessToast('删除成功');
      } else
        CustomFlutterToast.showErrorToast('删除失败');
    } catch (e) {
      if (kDebugMode) print('删除消息时发生错误: $e');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // 隐藏表情或更多操作面板
  void hidePanel(ChatBottomPanelContainerController panelController) {
    if (focusNode.hasFocus) focusNode.unfocus();
    isReadOnly = false;
    panelController.updatePanelType(ChatBottomPanelType.none);
  }

  // 初始化数据
  void _initData() async {
    if (kDebugMode) print('view type is: ${view.runtimeType}');
    chatInfo = Get.arguments?['chatInfo'] ?? {};
    if (kDebugMode) print('chat_frame chatInfo: $chatInfo');
    _targetId = chatInfo['fromId'] ?? '';
    if (kDebugMode) print('chat_frame targetId: $chatInfo');
    // 聊天背景本地获取
    chatBackground = sharedPreferences.getString(
            '${_targetId}_chat_background_${globalData.currentUserId}') ??
        '';
    // 若本地没有获取到则从网络获取聊天背景
    if (chatBackground.isEmpty) {
      chatBackground = chatInfo['chatBackground'] ?? '';
      // 保存聊天背景到本地
      if (chatBackground.isNotEmpty)
        sharedPreferences.setString(
            '${_targetId}_chat_background_${globalData.currentUserId}',
            chatBackground);
    }
  }

  @override
  void onInit() {
    _initData();
    _onGetMsgRecode().catchError((error) {
      // 适当处理错误，例如记录日志或显示提示
      if (kDebugMode) print('初始化过程中发生错误: $error');
    });
    _eventListen();
    super.onInit();
  }

  @override
  void onReady() {
    // 判断是否是好友
    if (chatInfo['type'] == 'user') _onCheckFriend(_targetId);
    try {
      _onGetMembers();
    } on Exception catch (e) {
      if (kDebugMode) print('onReady过程中发生错误: $e');
    } finally {
      _onRead(null);
      super.onReady();
      // 添加滚动监听
      scrollController.addListener(() {
        // 判断是否更新消息列表
        if (scrollController.hasClients &&
            scrollController.position.pixels ==
                scrollController.position.minScrollExtent) _loadMore();
        // 判断是否滑动到底部
        isOnBottom = scrollController.position.pixels ==
            scrollController.position.maxScrollExtent;
        // 判断是否向上滑动
        final currentOffset = scrollController.offset;
        if (currentOffset > _previousOffset)
          isUpSroll = true;
        else if (currentOffset < _previousOffset)
          isUpSroll = false;
        else
          isUpSroll = false;
        _previousOffset = currentOffset;
      });
    }
  }

  @override
  void onClose() {
    // try {
    //   saveMsgToLocal();
    // } catch (e) {
    //   if (kDebugMode) print('onClose过程中发生错误: $e');
    // } finally {
    msgContentController.dispose();
    scrollController.dispose();
    _subscription?.cancel();
    focusNode.dispose();
    super.onClose();
    // }
  }
}
