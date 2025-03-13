import 'dart:convert';
import 'dart:io' show Platform;

import 'package:chat_bottom_container/panel_container.dart'
    show ChatBottomPanelContainer, ChatBottomPanelContainerController;
import 'package:chat_bottom_container/typedef.dart';
import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, Color;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart'
    show ExtensionBottomSheet, Get, GetNavigation, WidgetPaddingX;
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:linyu_mobile/components/app_bar_title/index.dart';
import 'package:linyu_mobile/components/custom_button/index.dart';
import 'package:linyu_mobile/components/custom_icon_button/index.dart';
import 'package:linyu_mobile/components/custom_text_field/index.dart';
import 'package:linyu_mobile/components/custom_voice_record_button/index.dart';
import 'package:linyu_mobile/pages/chat_frame/chat_content/msg.dart';
import 'package:linyu_mobile/pages/chat_frame/logic.dart';
import 'package:linyu_mobile/utils/String.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart' show CustomView;
import 'package:linyu_mobile/utils/emoji.dart';
import 'package:linyu_mobile/utils/extension.dart';

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

  // 构建表情面板内容
  Widget _buildEmoji() {
    double height = 300;
    final keyboardHeight = panelController.keyboardHeight;
    if (keyboardHeight != 0) height = keyboardHeight;
    return [
      const SizedBox(height: 10),
      [
        Emoji.emojis
            .map(
              (emoji) => Text(emoji)
                  .fontSize(24)
                  .onTap(() => controller.onEmojiTap(emoji)),
            )
            .toList()
            .toWrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
            )
            .toSingleChildScrollView(),
        if (controller.msgContentController.text.isNotEmpty)
          const Icon(Icons.backspace)
              .borderRadius(all: 8)
              .height(34)
              .width(60)
              .onTap(controller.removeChar)
              .positioned(bottom: 0, right: 0),
      ]
          .toStack()
          .decorated(
              border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1.0,
            ),
          ))
          .alignCenter()
          .paddingAll(10)
          .width(MediaQuery.of(Get.context!).size.width)
          .expanded(),
    ].toColumn().height(height);
  }

  // 构建更多操作面板内容
  Widget _buildMoreOperation() {
    double height = 300;
    final keyboardHeight = panelController.keyboardHeight;
    if (keyboardHeight != 0) height = keyboardHeight;
    return [
      const SizedBox(height: 10),
      GridView.count(
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
      )
          .decorated(
              border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1.0,
            ),
          ))
          .paddingAll(10)
          .width(MediaQuery.of(Get.context!).size.width)
          .height(height)
          .expanded(),
    ].toColumn().height(height);
  }

  Widget _buildPanelContainer() => ChatBottomPanelContainer<PanelType>(
        controller: panelController,
        inputFocusNode: controller.focusNode,
        otherPanelWidget: (type) {
          if (type == null) return const SizedBox.shrink();
          final panelBuilder = {
            PanelType.emoji: _buildEmoji,
            PanelType.tool: _buildMoreOperation,
          };
          return panelBuilder[type]?.call() ?? const SizedBox.shrink();
        },
        panelBgColor: Colors.transparent,
        changeKeyboardPanelHeight: (height) => height,
      );

  // 按钮第一种格式
  Widget _buildIconButton1(iconData, onTap) => CustomIconButton(
        onTap: onTap,
        icon: iconData,
        width: 36,
        height: 36,
        iconSize: 26,
        iconColor: Colors.black,
        color: Colors.transparent,
      );

  // 按钮第二种格式
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

  // 群聊解散底部提示构建
  Widget _buildGroupDissolvedMessage() => [
        const Text('该群已解散').fontSize(14).textColor(Colors.grey),
        _buildIconButton1(
            Icons.keyboard_arrow_down, () => controller.scrollBottom()),
      ]
          .toRow(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
          )
          .paddingSymmetric(horizontal: 10.0, vertical: 10)
          .backgroundColor(const Color(0xFFEDF2F9));

  // 不是好友时展示的组件
  Widget _buildNotFriendMessage() => [
        const Text('Ta已不是好友').fontSize(14).textColor(Colors.grey),
        if (!controller.isOnBottom && controller.isUpSroll)
          _buildIconButton1(
              Icons.keyboard_arrow_down, () => controller.scrollBottom()),
      ]
          .toRow(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
          )
          .paddingSymmetric(horizontal: 10.0, vertical: 10)
          .backgroundColor(const Color(0xFFEDF2F9));

  //聊天记录展示
  Widget _buildMsgRecord(context, index) {
    final Map<String, dynamic> msg = controller.msgList[index] is String
        ? jsonDecode(controller.msgList[index])
        : controller.msgList[index];
    final Widget widget = ChatMessage(
      key: ValueKey(msg['id']),
      onTapChatPortrait: controller.onTapChatPortrait,
      onTapDelete: (data) => controller.deleteMsg(data, msg, index),
      onTapMultipleChoice: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
      onTapCite: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
      onTapRemind: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
      onTapSearch: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
      onTapFavorite: (data) => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"),
      onTapRepost: (data) => controller.onRepostMsg(msg),
      reEdit: () => controller.reEditMsg(msg),
      onTapMsg: () => controller.onTapMsg(msg),
      onTapVoiceToText: (data) => controller.onVoiceToTxt(msg),
      onTapVoiceHiddenText: (data) => controller.onHideText(msg),
      onTapCopy: (data) =>
          Clipboard.setData(ClipboardData(text: msg['msgContent']['content'])),
      onTapRetract: (data) => controller.retractMsg(msg),
      msg: msg,
      chatPortrait: controller.chatInfo['portrait'],
      chatInfo: controller.chatInfo,
      member: controller.members[msg['fromId']],
    );
    return widget;
  }

  // 输入框和按钮构建
  Widget _buildTextFieldAndButtons() => [
        [
          controller.isRecording
              ? _buildIconButton1(
                  const IconData(0xe661, fontFamily: 'IconFont'),
                  () {
                    controller.isRecording = false;
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => controller.focusNode.requestFocus());
                  },
                )
              : _buildIconButton1(
                  const IconData(0xe7e2, fontFamily: 'IconFont'),
                  () {
                    controller.isRecording = true;
                    controller.hidePanel(panelController);
                  },
                ),
          const SizedBox(width: 5),
          controller.isRecording
              ? CustomVoiceRecordButton(
                  onFinish: controller.onSendVoiceMsg,
                ).expanded()
              : CustomTextField(
                  controller: controller.msgContentController,
                  maxLines: 3,
                  minLines: 1,
                  readOnly: controller.isReadOnly,
                  hintTextColor: theme.primaryColor,
                  hintText: controller.lifeStr['data']['content'],
                  vertical: 8,
                  focusNode: controller.focusNode,
                  fillColor: Colors.white.withOpacity(0.9),
                  onTap: () {
                    controller.isReadOnly = false;
                    WidgetsBinding.instance.addPostFrameCallback((_) =>
                        panelController
                            .updatePanelType(ChatBottomPanelType.keyboard));
                  },
                  onChanged: (value) =>
                      controller.isSend = value.trim().isNotEmpty,
                  onSubmitted: (text) => controller.sendTextMsg(),
                ).expanded(),
          const SizedBox(width: 5),
          if (!controller.isRecording)
            _buildIconButton1(
              const IconData(0xe632, fontFamily: 'IconFont'),
              () {
                controller.isReadOnly = true;
                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    panelController.updatePanelType(ChatBottomPanelType.other,
                        data: PanelType.emoji,
                        forceHandleFocus: ChatBottomHandleFocus.requestFocus));
              },
            ),
          controller.isSend && !Platform.isIOS
              ? CustomButton(
                  text: '发送',
                  onTap: controller.sendTextMsg,
                  width: 60,
                  textSize: 14,
                  height: 34,
                )
              : !controller.isOnBottom && controller.isUpSroll
                  ? _buildIconButton1(Icons.keyboard_arrow_down,
                      () => controller.scrollBottom())
                  : _buildIconButton1(
                      const IconData(0xe636, fontFamily: 'IconFont'), () {
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          panelController.updatePanelType(
                              ChatBottomPanelType.other,
                              data: PanelType.tool));
                    }),
        ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
        _buildPanelContainer(),
      ]
          .toColumn(
            mainAxisSize: MainAxisSize.min,
          )
          .paddingSymmetric(horizontal: 10.0, vertical: 10)
          .backgroundColor(const Color(0xFFEDF2F9))
          .toRepaintBoundary();

  void _buildBottomSheet() => Get.bottomSheet(
        backgroundColor: Colors.white,
        [
          const Text('语音通话')
              .textColor(theme.primaryColor)
              .fontSize(18)
              .onTap(() {
            controller.onInviteVideoChat(true);
            Get.back();
          }).center(),
          const Text('视频通话')
              .textColor(theme.primaryColor)
              .fontSize(18)
              .onTap(() {
            controller.onInviteVideoChat(false);
            Get.back();
          }).center(),
        ].toWrap(),
      );

  @override
  void init(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
    super.init(context);
  }

  @override
  Widget buildView(BuildContext context) {
    controller.hasBeenLoaded();

    // 聊天页面拨号图标按钮
    final Widget callImage =
        Image.asset('assets/images/call.png', height: 24, width: 24)
            .onTap(_buildBottomSheet);

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
        if (controller.chatInfo['type'] != 'group') callImage,
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

    //加入黑名单按钮组件
    final Widget blockUser = [
      const Icon(Icons.block_flipped, size: 18),
      const Text('加入黑名单'),
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.center)
        .onTap(() => Fluttertoast.showToast(msg: "功能建设中，敬请期待！"))
        .expanded();

    // 添加好友按钮组件
    final Widget addFriend = [
      const Icon(Icons.person_add_alt_1_outlined, size: 18),
      const Text('添加为好友'),
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.center)
        .onTap(controller.onTapAddFriend)
        .expanded();

    // 不是好友时展示的组件构建
    final Widget notFriend = [
      blockUser,
      const VerticalDivider(width: 1, color: Colors.grey),
      addFriend,
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.center)
        .backgroundColor(Colors.white)
        .height(35);

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
    final Widget chatMsgContent = [
      ListView.builder(
        itemCount: controller.msgList.length,
        controller: controller.scrollController,
        itemBuilder: _buildMsgRecord,
      ).paddingHorizontal(16),
      if (controller.isLoading)
        const CupertinoActivityIndicator().paddingAll(8.0).center().positioned(
              top: 0,
              left: 0,
              right: 0,
            ),
      if (!controller.isLoading && !controller.isFriend) notFriend,
    ].toStack().onTap(() => controller.hidePanel(panelController)).expanded();

    // 底部输入框构建
    final Widget bottomInput = controller.chatInfo['name'] == null &&
            controller.chatInfo['type'] == 'group'
        ? _buildGroupDissolvedMessage()
        : !controller.isFriend
            ? _buildNotFriendMessage()
            : _buildTextFieldAndButtons();

    // 整体布局构建
    final Widget view = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: appBar,
      body: Container(
        decoration: chatBackground,
        child: [
          chatMsgContent,
          bottomInput,
        ].toColumn(),
      ),
    ).onTap(() => controller.panelType.value = 'none');
    return view;
  }

  @override
  void close(BuildContext context) {
    WidgetsBinding.instance.removeObserver(this);
    super.close(context);
  }
}
