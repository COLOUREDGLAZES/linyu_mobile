import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/app_bar_title/index.dart';
import 'package:linyu_mobile/components/custom_button/index.dart';
import 'package:linyu_mobile/components/custom_image_group/index.dart';
import 'package:linyu_mobile/components/custom_label_value_button/index.dart';
import 'package:linyu_mobile/components/custom_portrait/index.dart';
import 'package:linyu_mobile/utils/String.dart';
import 'package:linyu_mobile/utils/date.dart';
import 'package:linyu_mobile/utils/getx_config/config.dart';

import 'logic.dart';

class FriendInformationPage extends CustomWidget<FriendInformationLogic> {
  FriendInformationPage({super.key});

  PopupMenuEntry<int> _buildPopupDivider() => PopupMenuItem<int>(
        enabled: false,
        height: 1,
        child: Container(
          height: 1,
          padding: const EdgeInsets.all(0),
          color: Colors.grey[200],
        ),
      );

  Widget _buildFriendInfoSection() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.minorColor, const Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 5),
                borderRadius: BorderRadius.circular(35),
              ),
              child: CustomPortrait(
                  url: controller.friendPortrait, size: 70, radius: 35),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFriendDetails(),
            ),
          ],
        ),
      );

  Widget _buildFriendDetails() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 13,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 15,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor.withOpacity(0.1),
                              theme.primaryColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10), // 圆角
                        ),
                        child: Opacity(
                          opacity: 0,
                          child: Text(
                            controller.friendName,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    controller.friendName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                controller.friendAccount,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      );

  Widget _buildFriendMiscInfo() => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(controller.friendGender == "男" ? Icons.male : Icons.female,
                color: controller.friendGender == "男"
                    ? const Color(0xFF4C9BFF)
                    : const Color(0xFFFFA0CF),
                size: 18),
            const SizedBox(width: 2),
            Text(
              controller.friendGender,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Container(
              width: 1,
              height: 14,
              color: Colors.black38,
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            Text(
              DateUtil.calculateAge(controller.friendBirthday),
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Container(
              width: 1,
              height: 14,
              color: Colors.black38,
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            Text(
              DateUtil.getYearDayMonth(controller.friendBirthday),
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      );

  Widget _buildRemarkButton() => CustomLabelValueButton(
      onTap: () => controller.navigateToPage('set_remark',
          {'remark': controller.friendRemark, 'friendId': controller.friendId}),
      width: 50,
      label: '备注',
      hint: '未设置备注',
      value: controller.friendRemark);

  Widget _buildGroupButton() => CustomLabelValueButton(
      onTap: () => controller.navigateToPage('set_group', {
            'groupName': controller.friendGroup,
            'friendId': controller.friendId
          }),
      width: 50,
      label: '分组',
      value: controller.friendGroup);

  Widget _buildSignatureButton() => CustomLabelValueButton(
      onTap: () {},
      width: 50,
      label: '签名',
      hint: 'ta没有要说的签名~',
      maxLines: 10,
      value: controller.friendSignature);

  Widget _buildTalkButton() => CustomLabelValueButton(
        onTap: () => Get.toNamed('/talk', arguments: {
          'userId': controller.friendId,
          'title': StringUtil.isNotNullOrEmpty(controller.friendRemark)
              ? controller.friendRemark
              : controller.friendName,
        }),
        width: 50,
        label: '说说',
        hint: '这个人很懒，什么都没留下~',
        child: (controller.talkContent['text']?.isNotEmpty == true ||
                (controller.talkContent['img']?.isNotEmpty ?? false))
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.talkContent['text']?.isNotEmpty == true)
                    Text(controller.talkContent['text'],
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87)),
                  if (controller.talkContent['img']?.isNotEmpty == true)
                    CustomImageGroup(
                        imagesList: controller.talkContent['img'],
                        userId: controller.friendId),
                ],
              )
            : null,
      );

  Widget _buildBottomNavigationBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomButton(
                text: '发消息',
                onTap: controller.toSendMsg,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: CustomButton(
                text: '视频聊天',
                onTap: () {},
                type: 'minor',
              ),
            ),
          ],
        ),
      );

  @override
  Widget buildWidget(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FBFF),
    appBar: AppBar(
      centerTitle: true,
      title: const AppBarTitle('好友资料'),
      backgroundColor: const Color(0xFFF9FBFF),
      actions: [
        IconButton(
          onPressed: controller.setConcern,
          icon: Icon(
            controller.isConcern ? Icons.favorite : Icons.favorite_border,
            size: 32,
            color: controller.isConcern
                ? theme.primaryColor
                : const Color(0xFF989898),
          ),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, size: 32),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          color: const Color(0xFFFFFFFF),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            PopupMenuItem(
              value: 1,
              height: 40,
              onTap: controller.deleteFriend,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, size: 20),
                  SizedBox(width: 12),
                  Text('删除好友', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            _buildPopupDivider(),
            PopupMenuItem(
              value: 1,
              height: 40,
              onTap: controller.setConcern,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, size: 20),
                  const SizedBox(width: 12),
                  Text(controller.isConcern ? '取消特别关心' : '特别关心',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFriendInfoSection(),
              const SizedBox(height: 1),
              _buildFriendMiscInfo(),
              const SizedBox(height: 1),
              _buildRemarkButton(),
              const SizedBox(height: 1),
              _buildGroupButton(),
              const SizedBox(height: 1),
              _buildSignatureButton(),
              const SizedBox(height: 1),
              _buildTalkButton(),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}
