import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/app_bar_title/index.dart';
import 'package:linyu_mobile/components/custom_image_group/index.dart';
import 'package:linyu_mobile/components/custom_portrait/index.dart';
import 'package:linyu_mobile/components/custom_text_button/index.dart';
import 'package:linyu_mobile/utils/String.dart';
import 'package:linyu_mobile/utils/date.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

import 'logic.dart';

class TalkPage extends CustomWidget<TalkLogic> {
  TalkPage({super.key});

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
                        url: globalData.currentAvatarUrl ?? '',
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
            builder: (BuildContext context, BoxConstraints constraints) {
              double top = constraints.biggest.height;
              double avatarSize = 120;
              double minAvatarSize = 36; // 最小头像
              double currentAvatarSize = avatarSize * (top / 250);
              if (currentAvatarSize < minAvatarSize)
                currentAvatarSize = minAvatarSize;
              //  计算动画进度
              double animationProgress = (250 - top) / (250 - kToolbarHeight);
              if (animationProgress < 0) animationProgress = 0;
              if (animationProgress > 1) animationProgress = 1;
              // 计算头像位置, 当appbar完全展开时，头像在底部中央，当appbar收缩时，头像在左上角
              double avatarBottom = 20 * (1 - animationProgress);
              // 动画
              return FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 背景图片
                    GestureDetector(
                      onTap: () => !controller.isExpanded
                          ? controller.scrollToTop()
                          : Fluttertoast.showToast(msg: '功能暂未开放，敬请期待~'),
                      child: Image.network(
                        globalData.currentBackGroundUrl ??
                            "http://114.96.70.115:19000/linyu/default-portrait.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 过渡动画
                    Positioned(
                      left: 13.2,
                      top: avatarBottom + 88,
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(
                            begin: avatarSize, end: currentAvatarSize),
                        duration: const Duration(milliseconds: 200),
                        builder: (BuildContext context, double size,
                                Widget? child) =>
                            Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => Get.toNamed('/my_talk_page',
                                  arguments: {
                                    'isNotShowLeading': true,
                                    'userId': globalData.currentUserId,
                                    'title': '我的说说'
                                  }),
                              child: SizedBox(
                                width: size - 10,
                                height: size - 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(size / 2),
                                  child: Image.network(
                                    globalData.currentAvatarUrl ??
                                        'https://avatars.githubusercontent.com/u/66918811?v=4',
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                                Text('${globalData.currentUserName}'),
                                Text(globalData.currentUserAccount),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    // 返回按钮的动画
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Opacity(
                        opacity: animationProgress,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
