import 'package:flutter/material.dart';
import 'package:linyu_mobile/components/custom_label_value_button/index.dart';
import 'package:linyu_mobile/components/custom_portrait/index.dart';
import 'package:linyu_mobile/utils/getx_config/config.dart';

import 'logic.dart';

class ChatSettingPage extends CustomView<ChatSettingLogic> {
  ChatSettingPage({super.key});

  @override
  Widget buildView(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF9FBFF),
        appBar: AppBar(
          title: const Text('聊天设置'),
          centerTitle: true,
          backgroundColor: const Color(0xFFF9FBFF),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView(
            children: [
              SizedBox(
                child: CustomLabelValueButton(
                  iconShowCenter: true,
                  onTap: controller.goToChatDetailPage,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomPortrait(
                        url: controller.chatInfo['portrait'],
                        size: 50,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 85.5,
                        height: 20,
                        child: Text(
                          controller.chatInfo['name'],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '设为置顶',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      child: Switch(
                        trackOutlineColor: WidgetStateColor.transparent,
                        activeTrackColor: theme.primaryColor,
                        inactiveThumbColor: Colors.white,
                        value: controller.isTop,
                        onChanged: controller.onSetChatTop,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: CustomLabelValueButton(
                  onTap: controller.selectPicture,
                  child: const Text(
                    '设置当前聊天背景',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
