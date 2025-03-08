import 'dart:convert';

import 'package:chat_bottom_container/panel_container.dart'
    show ChatBottomPanelContainer, ChatBottomPanelContainerController;
import 'package:chat_bottom_container/typedef.dart';
import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, Color;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart'
    show ExtensionBottomSheet, Get, GetBuilder, GetNavigation, Obx;
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:linyu_mobile/components/app_bar_title/index.dart';
import 'package:linyu_mobile/components/custom_button/index.dart';
import 'package:linyu_mobile/components/custom_icon_button/index.dart';
import 'package:linyu_mobile/components/custom_text_field/index.dart';
import 'package:linyu_mobile/components/custom_voice_record_button/index.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/msg.dart';
import 'package:linyu_mobile/pages/chat_frame/logic.dart';
import 'package:linyu_mobile/utils/String.dart';
import 'package:linyu_mobile/utils/emoji.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart' show CustomView;

enum PanelType {
  none,
  keyboard,
  emoji,
  tool,
}

class ChatFramePage extends CustomView<ChatFrameLogic>
    with WidgetsBindingObserver {
  ChatFramePage({super.key});

  final panelController = new ChatBottomPanelContainerController<PanelType>();

  Widget _buildPanelContainer() {
    try {
      return ChatBottomPanelContainer<PanelType>(
        controller: panelController,
        inputFocusNode: controller.focusNode,
        otherPanelWidget: (type) {
          // 提前处理type为null的情况，减少代码嵌套
          if (type == null) return const SizedBox.shrink();
          // 使用Map来简化case的切换
          final panelBuilder = {
            PanelType.emoji: _buildEmoji,
            PanelType.tool: _buildMoreOperation,
          };
          return panelBuilder[type]?.call() ?? const SizedBox.shrink();
        },
        panelBgColor: Colors.transparent,
        changeKeyboardPanelHeight: (height) => height,
      );
    } catch (e) {
      // 错误处理，可以根据需要进行日志记录或用户友好的提示
      if (kDebugMode) print('构建面板时发生错误: $e');
      return const SizedBox.shrink(); // 返回空组件，避免崩溃
    }
  }

  void hidePanel() {
    if (controller.focusNode.hasFocus) controller.focusNode.unfocus();
    controller.isReadOnly.value = false;
    panelController.updatePanelType(ChatBottomPanelType.none);
  }

  Widget _buildEmoji() {
    double height = 300;
    final keyboardHeight = panelController.keyboardHeight;
    if (keyboardHeight != 0) height = keyboardHeight;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: MediaQuery.of(Get.context!).size.width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: Emoji.emojis
                          .map(
                            (emoji) => GestureDetector(
                              onTap: () => controller.onEmojiTap(emoji),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (controller.msgContentController.text.isNotEmpty)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: controller.removeChar,
                            child: Container(
                              width: 60,
                              height: 34,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.backspace),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOperation() {
    double height = 300;
    final keyboardHeight = panelController.keyboardHeight;
    if (keyboardHeight != 0) height = keyboardHeight;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              height: height,
              width: MediaQuery.of(Get.context!).size.width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                children: [
                  _buildIconButton2(
                    '图片',
                    const IconData(0xe9f4, fontFamily: 'IconFont'),
                    () => controller.cropChatPicture(null),
                  ),
                  _buildIconButton2(
                    '拍照',
                    const IconData(0xe9f3, fontFamily: 'IconFont'),
                    () => controller.cropChatPicture(ImageSource.camera),
                  ),
                  _buildIconButton2(
                    '文件',
                    const IconData(0xeac4, fontFamily: 'IconFont'),
                    () => controller.selectFile(),
                  ),
                  if (controller.chatInfo['type'] == 'user')
                    _buildIconButton2(
                      '语音通话',
                      const IconData(0xe969, fontFamily: 'IconFont'),
                      () => controller.onInviteVideoChat(true),
                    ),
                  if (controller.chatInfo['type'] == 'user')
                    _buildIconButton2(
                      '视频通话',
                      const IconData(0xe9f5, fontFamily: 'IconFont'),
                      () => controller.onInviteVideoChat(false),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton1(iconData, onTap) => CustomIconButton(
        onTap: onTap,
        icon: iconData,
        width: 36,
        height: 36,
        iconSize: 26,
        iconColor: Colors.black,
        color: Colors.transparent,
      );

  Widget _buildIconButton2(text, iconData, onTap) => CustomIconButton(
        onTap: onTap,
        icon: iconData,
        width: 50,
        height: 50,
        radius: 15,
        iconSize: 26,
        text: text,
        color: Colors.white.withOpacity(0.9),
        iconColor: const Color(0xFF1F1F1F),
      );

  //聊天记录展示
  Widget _buildMsgRecord(context, index) {
    final Map<String, dynamic> msg = controller.msgList[index] is String
        ? jsonDecode(controller.msgList[index])
        : controller.msgList[index];
    final Widget widget = index == controller.msgList.length - 1
        ? Container()
        : ChatMessage(
            key: ValueKey(msg['id']),
            onTapChatPortrait: controller.onTapChatPortrait,
            onTapDelete: (data) => controller.deleteMsg(data, msg, index),
            onTapMultipleChoice: (data) =>
                Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
            onTapCite: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
            onTapRemind: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
            onTapSearch: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
            onTapFavorite: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
            onTapRepost: (data) => controller.onRepostMsg(msg),
            reEdit: () => controller.reEditMsg(msg),
            onTapMsg: () => controller.onTapMsg(msg),
            onTapVoiceToText: (data) => controller.onVoiceToTxt(msg),
            onTapVoiceHiddenText: (data) => controller.onHideText(msg),
            onTapCopy: (data) => Clipboard.setData(
                ClipboardData(text: msg['msgContent']['content'])),
            onTapRetract: (data) => controller.retractMsg(msg),
            msg: msg,
            chatPortrait: controller.chatInfo['portrait'],
            chatInfo: controller.chatInfo,
            member: controller.members[msg['fromId']],
          );

    return widget;
  }

  Widget _buildGroupDissolvedMessage() {
    return Container(
      color: const Color(0xFFEDF2F9),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('该群已解散', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  // 不是好友时展示的组件
  Widget _buildNotFriendMessage() {
    return Container(
      color: const Color(0xFFEDF2F9),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ta已不是好友', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  // 输入框和按钮构建
  Widget _buildTextFieldAndButtons() {
    return RepaintBoundary(
      child: Container(
        color: const Color(0xFFEDF2F9),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                controller.isRecording.value
                    ? _buildIconButton1(
                        const IconData(0xe661, fontFamily: 'IconFont'),
                        () {
                          controller.isRecording.value = false;
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => controller.focusNode.requestFocus());
                        },
                      )
                    : _buildIconButton1(
                        const IconData(0xe7e2, fontFamily: 'IconFont'),
                        () {
                          controller.isRecording.value = true;
                          hidePanel();
                        },
                      ),
                const SizedBox(width: 5),
                controller.isRecording.value
                    ? Expanded(
                        child: CustomVoiceRecordButton(
                          onFinish: controller.onSendVoiceMsg,
                        ),
                      )
                    : Expanded(
                        child: Obx(
                          () => CustomTextField(
                            controller: controller.msgContentController,
                            maxLines: 3,
                            minLines: 1,
                            readOnly: controller.isReadOnly.value,
                            hintTextColor: theme.primaryColor,
                            hintText: controller.lifeStr['data']['content'],
                            vertical: 8,
                            focusNode: controller.focusNode,
                            fillColor: Colors.white.withOpacity(0.9),
                            onTap: () {
                              controller.isReadOnly.value = false;
                              WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => panelController.updatePanelType(
                                      ChatBottomPanelType.keyboard));
                              // Future.delayed(const Duration(milliseconds: 500),
                              //     controller.scrollBottom);
                            },
                            onChanged: (value) => controller.isSend.value =
                                value.trim().isNotEmpty,
                          ),
                        ),
                      ),
                const SizedBox(width: 5),
                if (!controller.isRecording.value)
                  _buildIconButton1(
                    const IconData(0xe632, fontFamily: 'IconFont'),
                    () {
                      controller.isReadOnly.value = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          panelController.updatePanelType(
                              ChatBottomPanelType.other,
                              data: PanelType.emoji,
                              forceHandleFocus:
                                  ChatBottomHandleFocus.requestFocus));
                      // Future.delayed(const Duration(milliseconds: 500),
                      //     controller.scrollBottom);
                    },
                  ),
                controller.isSend.value
                    ? CustomButton(
                        text: '发送',
                        onTap: controller.sendTextMsg,
                        width: 60,
                        textSize: 14,
                        height: 34,
                      )
                    : _buildIconButton1(
                        const IconData(0xe636, fontFamily: 'IconFont'),
                        () => WidgetsBinding.instance.addPostFrameCallback((_) {
                          panelController.updatePanelType(
                              ChatBottomPanelType.other,
                              data: PanelType.tool);
                          // Future.delayed(const Duration(milliseconds: 500),
                          //     controller.scrollBottom);
                        }),
                      ),
              ],
            ),
            _buildPanelContainer(),
          ],
        ),
      ),
    );
  }

  @override
  void init(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
    super.init(context);
  }

  @override
  Widget buildView(BuildContext context) {
    controller.hasBeenLoaded();
    // appBar 构建
    final PreferredSizeWidget appBar = AppBar(
      centerTitle: true,
      title: AppBarTitle(
        StringUtil.isNotNullOrEmpty(controller.chatInfo['remark'])
            ? controller.chatInfo['remark']
            : controller.chatInfo['name'] ?? '',
      ),
      backgroundColor: const Color(0xFFF9FBFF),
      actions: [
        if (controller.chatInfo['type'] != 'group')
          IconButton(
            onPressed: () => Get.bottomSheet(
              backgroundColor: Colors.white,
              Wrap(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () {
                        controller.onInviteVideoChat(true);
                        Get.back();
                      },
                      child: Text(
                        '语音通话',
                        style: TextStyle(color: theme.primaryColor),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        controller.onInviteVideoChat(false);
                        Get.back();
                      },
                      child: Text(
                        '视频通话',
                        style: TextStyle(color: theme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            icon: Image.asset('assets/images/call.png', height: 24, width: 24),
          ),
        IconButton(
          onPressed: controller.toChatSetting,
          icon: Image.asset(
            'assets/images/more.png',
            height: 24,
            width: 24,
          ),
        ),
      ],
    );

    // 聊天背景构建
    final Decoration chatBackground = controller.chatBackground.isNotEmpty
        ? BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(controller.chatBackground),
            ),
          )
        : const BoxDecoration(
            color: Color(0xFFF9FBFF),
          );

    // 聊天内容展示构建
    final Widget chatContent = Expanded(
      child: GestureDetector(
        onTap: hidePanel,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GetBuilder<ChatFrameLogic>(
            id: const Key('chat_frame'),
            builder: (controller) {
              return Stack(
                children: [
                  ListView.builder(
                    itemCount: controller.msgList.length,
                    controller: controller.scrollController,
                    itemBuilder: _buildMsgRecord,
                  ),
                  if (controller.isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // 底部输入框构建
    final Widget bottomInput = Obx(() {
      if (controller.chatInfo['name'] == null &&
          controller.chatInfo['type'] == 'group') {
        return _buildGroupDissolvedMessage();
      } else if (!controller.isFriend) {
        return _buildNotFriendMessage();
      } else {
        return _buildTextFieldAndButtons();
      }
    });

    // 不是好友时展示的组件构建
    final Widget notFriend = Container(
      height: 35,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              // onTap: controller.onBlockUser,
              onTap: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block_flipped, size: 18),
                  Text('加入黑名单'),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.grey),
          Expanded(
            child: GestureDetector(
              onTap: controller.onTapAddFriend,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_outlined, size: 18),
                  Text('添加为好友'),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // 整体布局构建
    final Widget view = GestureDetector(
      onTap: () => controller.panelType.value = 'none',
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF9FBFF),
        appBar: appBar,
        body: Stack(
          children: [
            Container(
              decoration: chatBackground,
              child: Column(
                children: <Widget>[
                  chatContent,
                  bottomInput,
                ],
              ),
            ),
            if (!controller.isLoading && !controller.isFriend) notFriend,
            if (!controller.isOnBottom)
              Positioned(
                  bottom: 66.h,
                  right: 9.w,
                  child: Column(
                    children: [
                      CustomIconButton(
                        width: 32.w,
                        height: 32.h,
                        iconSize: 26.sp,
                        onTap: () => controller.scrollBottom(),
                        icon: Icons.keyboard_arrow_down,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  )),
          ],
        ),
      ),
    );

    return view;
  }

  // @override
  // void didChangeMetrics() {
  //   final keyboardHeight = MediaQuery.of(Get.context!).viewInsets.bottom;
  //   if (keyboardHeight > 0)
  //     Future.delayed(
  //         const Duration(milliseconds: 300),
  //         () => WidgetsBinding.instance.addPostFrameCallback((_) {
  //               if (controller.scrollController.hasClients &&
  //                   controller.scrollController.position.pixels !=
  //                       controller.scrollController.position.maxScrollExtent)
  //                 controller.scrollController.animateTo(
  //                   controller.scrollController.position.maxScrollExtent + 500,
  //                   duration: const Duration(milliseconds: 300),
  //                   curve: Curves.fastOutSlowIn,
  //                 );
  //             }));
  //   super.didChangeMetrics();
  // }

  @override
  void close(BuildContext context) {
    WidgetsBinding.instance.removeObserver(this);
    super.close(context);
  }
}
