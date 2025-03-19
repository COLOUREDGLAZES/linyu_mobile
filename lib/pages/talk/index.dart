import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linyu_mobile/components/app_bar_title/index.dart';
import 'package:linyu_mobile/components/custom_image_group/index.dart';
import 'package:linyu_mobile/components/custom_portrait/index.dart';
import 'package:linyu_mobile/components/custom_shadow_text/index.dart';
import 'package:linyu_mobile/components/custom_text_button/index.dart';
import 'package:linyu_mobile/utils/String.dart';
import 'package:linyu_mobile/utils/date.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

import 'logic.dart';

class TalkPage extends CustomWidget<TalkLogic> {
  TalkPage({super.key});

  void bottomSheet(
          BuildContext context, Function(ImageSource? type) cropChatPicture) =>
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('图库'),
                onTap: () => cropChatPicture(null),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () => cropChatPicture(ImageSource.camera),
              ),
            ],
          );
        },
      );

  // 构建appbar
  List<Widget> _buildAppBar(BuildContext context) => [
        SliverAppBar(
          floating: false,
          pinned: true,
          centerTitle: true,
          leading: !controller.isNotShowLeading
              ? Obx(() => Opacity(
                    opacity: controller.opacity.value,
                    child: Container(
                      margin: const EdgeInsets.only(left: 13.2, top: 10.8),
                      child: CustomPortrait(
                        url: globalData.currentPortrait ?? '',
                        size: 40,
                        radius: 20,
                        onTap: () => Scaffold.of(context).openDrawer(),
                        onLongPress: controller.onLongPressPortrait,
                      ),
                    ),
                  ))
              : null,
          title: Obx(() => Opacity(
                opacity: controller.opacity.value,
                child: AppBarTitle(controller.title),
              )),
          backgroundColor: const Color(0xFFF9FBFF),
          expandedHeight: Size.fromHeight(
                  MediaQuery.of(context).size.width * 10.7 / 16.0 -
                      MediaQueryData.fromWindow(window).padding.top +
                      10)
              .height,
          flexibleSpace: LayoutBuilder(
            builder: buildFlexibleSpace,
          ),
          actions: [
            if (StringUtil.isNullOrEmpty(controller.targetUserId))
              CustomTextButton('发表',
                  onTap: () => Get.toNamed('/talk_create'),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  fontSize: 14),
          ],
        ),
      ];

  Widget _buildTalkItem(context, dynamic talk) => Container(
        margin: const EdgeInsets.only(bottom: 15.0),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: InkWell(
            onTap: () => Get.toNamed('/talk_details',
                arguments: {'talkId': talk['talkId']}),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomPortrait(
                          url: talk['portrait'] ?? '',
                          onTap: () => Get.toNamed('/my_talk_page', arguments: {
                            'isNotShowLeading': true,
                            'userId': talk['userId'],
                            'title': StringUtil.isNotNullOrEmpty(talk['remark'])
                                ? talk['remark']
                                : talk['name'],
                          }),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              talk['remark'] ?? talk['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateUtil.formatTime(talk['time']),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[800]),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[100]!, width: 1.0),
                          bottom:
                              BorderSide(color: Colors.grey[100]!, width: 1.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            talk['content']['text'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                          CustomImageGroup(
                              imagesList: talk['content']['img'] ?? [],
                              userId: talk['userId']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text("点赞（${talk['likeNum'] ?? 0}）",
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text("评论（${talk['commentNum'] ?? 0}）",
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        if (controller.currentUserId == talk['userId'])
                          CustomTextButton('删除',
                              onTap: () => controller.handlerDeleteTalkTip(
                                  context, talk['talkId'])),
                      ],
                    ),
                    const SizedBox(height: 5),
                    CustomTextButton(
                      '查看更多内容',
                      onTap: () => Get.toNamed('/talk_details',
                          arguments: {'talkId': talk['talkId']}),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  // 构建appbar展开以及收缩时的动画效果
  Widget buildFlexibleSpace(BuildContext context, BoxConstraints constraints) {
    double top = constraints.biggest.height;
    double avatarSize = 120;
    double minAvatarSize = 36; // 最小头像
    double currentAvatarSize = avatarSize * (top / 250);
    if (currentAvatarSize < minAvatarSize) currentAvatarSize = minAvatarSize;
    //  计算动画进度
    double animationProgress = (250 - top) / (250 - kToolbarHeight);
    if (animationProgress < 0) animationProgress = 0;
    if (animationProgress > 1) animationProgress = 1;
    // 计算头像位置, 当appbar完全展开时，头像在底部中央，当appbar收缩时，头像在左上角
    double avatarBottom = 20 * (1 - animationProgress);

    // 头像组件
    if (kDebugMode) print('currentPortrait is: ${globalData.currentPortrait}');
    final Widget avatarWidget = CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: globalData.currentPortrait ?? '',
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Image.asset('assets/images/default-portrait.jpeg'),
      ),
    ).onTap(
      () => Get.toNamed('/my_talk_page', arguments: {
        'isNotShowLeading': true,
        'userId': globalData.currentUserId,
        'title': '我的说说'
      }),
    );

    // 用户昵称组件
    final Widget nameTextWidget = CustomShadowText(
      text: '${globalData.currentUserName}',
      textColor: controller.textColor,
    ).onLongPress(
      () => Fluttertoast.showToast(msg: '功能暂未开放，敬请期待~'),
    );

    // 账号信息组件
    final Widget accountTextWidget = Text(
      key: ValueKey(globalData.currentAccount),
      globalData.currentAccount,
      style: TextStyle(
        fontSize: 12,
        color: controller.textColor,
        fontWeight: FontWeight.bold,
      ),
    ).onLongPress(
      () => Fluttertoast.showToast(msg: '功能暂未开放，敬请期待~'),
    );

    // 背景图片组件
    if (kDebugMode)
      print('currentTalkBackground: ${globalData.currentTalkBackground}');
    final Widget backgroundImageWidget = CachedNetworkImage(
      key: ValueKey(
          '${globalData.currentUserId}_talk_background_${globalData.currentTalkBackground}'),
      fit: BoxFit.cover,
      imageUrl: globalData.currentTalkBackground ?? '',
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Image.asset(
          'assets/images/default_talk_background.jfif',
          fit: BoxFit.cover,
        ),
      ),
    ).onTap(
      () => !controller.isExpanded
          ? controller.scrollToTop()
          : controller.changeTalkBackground(context),
    );

    // 动画
    return FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          backgroundImageWidget,
          // 过渡动画
          Positioned(
            left: 13.2,
            top: avatarBottom + 88,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: avatarSize, end: currentAvatarSize),
              duration: DurationExtensions(200).milliseconds,
              builder: (BuildContext context, double size, Widget? child) =>
                  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size - 10,
                    height: size - 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(size / 2),
                      child: avatarWidget,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      const SizedBox(height: 36),
                      nameTextWidget,
                      accountTextWidget,
                    ],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (controller.isLoading)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: theme.primaryColor,
            ),
          ),
        ),
      );
    else if (!controller.hasMore)
      return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Center(
          child: Text(
            '没有更多内容了~',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      );

    return const SizedBox.shrink();
  }

  @override
  Widget buildWidget(BuildContext context) => NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            _buildAppBar(context),
        controller: controller.scrollController,
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FBFF),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RefreshIndicator(
              onRefresh: controller.refreshData,
              color: theme.primaryColor,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 23.0.h),
                itemCount: controller.talkList.length + 1,
                itemBuilder: (context, index) =>
                    index < controller.talkList.length
                        ? _buildTalkItem(context, controller.talkList[index])
                        : _buildFooter(),
              ),
            ),
          ),
        ),
      );
}
