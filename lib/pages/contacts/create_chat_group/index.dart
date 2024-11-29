import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/app_bar_title/index.dart';
import 'package:linyu_mobile/components/custom_button/index.dart';
import 'package:linyu_mobile/components/custom_portrait/index.dart';
import 'package:linyu_mobile/components/custom_search_box/index.dart';
import 'package:linyu_mobile/components/custom_text_field/index.dart';
import 'package:linyu_mobile/utils/getx_config/config.dart';
import 'logic.dart';

class CreateChatGroupPage extends CustomWidgetNew<CreateChatGroupLogic> {
  CreateChatGroupPage({super.key});

  Widget _buildFriendItem(dynamic friend) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        // onLongPress: () => _showDeleteGroupBottomSheet(friend),
        onTap: () => controller.addUsers(friend),
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                CustomPortrait(url: friend['portrait']),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            friend['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (friend['remark'] != null &&
                              friend['remark']?.toString().trim() != '')
                            Text(
                              '(${friend['remark']})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedUserItem(dynamic user) {
    return Container(
      width: 40,
      margin: const EdgeInsets.only(right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(35),
      ),
      child: GestureDetector(
        onTap: () => controller.subUsers(user),
        child: CustomPortrait(url: user['portrait'], size: 70, radius: 35),
      ),
    );
  }

  void _showCreateChatGroupDialog(
      BuildContext context, {
        String? title = "创建群聊",
        String? label = '请填写群聊昵称',
        String? hintText = '',
      }) =>
      showDialog(
        context: context,
        barrierDismissible: false, // 设置为 false 禁止点击外部关闭弹窗
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    vertical: 8,
                    controller: controller.chatGroupController,
                    inputLimit: 10,
                    hintText: hintText!,
                    suffix: Text(
                        '${controller.chatGroupController.text.length}/10'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: '确定',
                          onTap: controller.onCreateChatGroup,
                          width: 120,
                          height: 34,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: '取消',
                          onTap: () => Navigator.of(context).pop(),
                          type: 'minor',
                          height: 34,
                          width: 120,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        leading: TextButton(
          child: Text(
            '取消',
            style: TextStyle(color: theme.primaryColor),
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const AppBarTitle('创建群组'),
        backgroundColor: const Color(0xFFF9FBFF),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (controller.users.isNotEmpty)
                  SizedBox(
                    height: 40,
                    width: controller.userTapWidth >= 200
                        ? 210
                        : controller.userTapWidth + 10,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: controller.users
                          .map((city) => _selectedUserItem(city))
                          .toList(),
                    ),
                  ),
                Expanded(
                  child: CustomSearchBox(
                    isCentered: false,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListView(
                  children: [
                    ...controller.friendList.map((group) {
                      return ExpansionTile(
                        iconColor: theme.primaryColor,
                        visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                        dense: true,
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(
                          '${group['name']}（${group['friends'].length}）',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        children: [
                          ...group['friends'].map(
                                (friend) => Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                              child: _buildFriendItem(friend),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomButton(
        text: '立即创建(${controller.users.length})',
        onTap: () => controller.users.isNotEmpty?_showCreateChatGroupDialog(context,
            title: '创建群聊',
            label: '请填写群聊昵称',
            hintText:
            '${controller.users.map((e) => e['remark'] ?? e['name']).toList()}'):(){},
        width: MediaQuery.of(context).size.width,
        type: 'gradient',
      ),
    );
  }
}
