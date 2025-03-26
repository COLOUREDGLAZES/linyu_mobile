import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/custom_button/index.dart';
import 'package:linyu_mobile/components/custom_text_field/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'logic.dart';

class SettingPage extends CustomView<SettingLogic> {
  SettingPage({super.key});

  @override
  Widget buildView(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        controller.httpUrlFocusNode.unfocus();
        controller.wsUrlFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置服务器'),
          centerTitle: true,
          elevation: 0.1,
        ),
        body: SizedBox(
          height: screenHeight -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: Column(
            children: [
              // const SizedBox(height: 20.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: const Color(0xFFF2F2F2),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // assets/images/logo.png
                      const SizedBox(width: 10),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 120,
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      CustomTextField(
                        labelText: 'ip地址：',
                        controller: controller.httpUrlController,
                        focusNode: controller.httpUrlFocusNode,
                      ),
                      const SizedBox(height: 20.0),
                      CustomTextField(
                        labelText: 'WebSocket地址：',
                        controller: controller.wsUrlController,
                        focusNode: controller.wsUrlFocusNode,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '确定',
                  onTap: controller.setUrl,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  text: '取消',
                  onTap: () => Get.back(),
                  type: 'minor',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
