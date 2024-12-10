import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/app_bar_title/index.dart';
import 'package:linyu_mobile/components/custom_text_button/index.dart';
import 'package:linyu_mobile/components/custom_text_field/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

import 'logic.dart';

class SetGroupNamePage extends CustomWidget<SetGroupNameLogic> {
  SetGroupNamePage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const AppBarTitle('群名称'),
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          actions: [
            CustomTextButton('完成',
                onTap: controller.onSetName,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                fontSize: 14),
          ]),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Obx(
              () => CustomTextField(
                labelText: "群名称",
                controller: controller.nameController,
                onChanged: (value) {
                  controller.nameLength.value = value.length;
                },
                inputLimit: 10,
                hintText: "请输入群名称~",
                suffix: Text('${controller.nameLength.value}/10'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
