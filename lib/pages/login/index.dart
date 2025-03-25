import 'package:ducafe_ui_core/ducafe_ui_core.dart'
    show ListExtensions, ScreenUtilExtensions, TextExtensions, WidgetExtensions;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:get/get.dart'
    show Get, GetNavigation, Obx, WidgetMarginX, WidgetPaddingX;
import 'package:linyu_mobile/components/custom_button/index.dart';
import 'package:linyu_mobile/components/custom_gradient_line/index.dart';
import 'package:linyu_mobile/components/custom_material_button/index.dart';
import 'package:linyu_mobile/components/custom_shadow_text/index.dart';
import 'package:linyu_mobile/pages/login/logic.dart';
import 'package:linyu_mobile/components/custom_text_field/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart' show CustomView;
import 'package:linyu_mobile/utils/extension.dart';

class LoginPage extends CustomView<LoginLogic> {
  LoginPage({super.key});

  @override
  Widget buildView(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: [
          [
            Image.asset('assets/images/mine-about.png', width: 26)
                .paddingZero
                .onTap(() => Get.toNamed('/about')),
            IconButton(
              onPressed: controller.toSetting,
              icon: const Icon(Icons.settings),
              padding: const EdgeInsets.all(0.0),
            ),
          ].toRow(mainAxisAlignment: MainAxisAlignment.end).height(40.0),
          [
            [
              const CustomShadowText(
                text: 'HELLO',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                shadowTop: 22,
              ),
              const Text("欢迎使用，林语").fontSize(26).fontWeight(FontWeight.w900),
            ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
            10.verticalSpace,
            Obx(
              () => Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Image.asset(
                    'assets/images/logo-login-${theme.themeMode.value}.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ]
              .toRow(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              )
              .paddingSymmetric(horizontal: 20),
          20.verticalSpace,
          // 登录框部分
          Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: const Color(0xFFF2F2F2), width: 1.0),
            ),
            child: [
              Obx(() => CustomTextField(
                    hintText: '请输入账号',
                    focusNode: controller.accountFocusNode,
                    onEditingComplete: () => FocusScope.of(context)
                        .requestFocus(controller.passwordFocusNode),
                    iconData: const IconData(0xe60d, fontFamily: 'IconFont'),
                    controller: controller.accountController,
                    inputLimit: 30,
                    onChanged: controller.onAccountTextChanged,
                    suffix: Text('${controller.accountTextLength.value}/30'),
                  )),
              20.verticalSpace,
              Obx(() => CustomTextField(
                    hintText: '请输入密码',
                    focusNode: controller.passwordFocusNode,
                    iconData: const IconData(0xe620, fontFamily: 'IconFont'),
                    controller: controller.passwordController,
                    onEditingComplete: () => controller.login(context),
                    obscureText: true,
                    inputLimit: 16,
                    onChanged: controller.onPasswordTextChanged,
                    suffix: Text('${controller.passwordTextLength.value}/16'),
                  )),
              [
                const Text("忘记密码?")
                    .fontSize(12)
                    .textColor(const Color(0xFFb0b0ba))
                    .onTap(controller.toRetrievePassword)
                    .marginSymmetric(vertical: 10),
              ].toRow(mainAxisAlignment: MainAxisAlignment.end),
              controller.isLoggingIn
                  ? CircularProgressIndicator(color: theme.primaryColor)
                  : controller.isAddAccount
                      ? CustomButton(
                          text: '添加用户',
                          type: 'gradient',
                          onTap: () => controller.login(context),
                          width: MediaQuery.of(context).size.width,
                        )
                      : CustomButton(
                          text: '立即登录',
                          type: 'gradient',
                          onTap: () => controller.login(context),
                          width: MediaQuery.of(context).size.width,
                        ),
              20.verticalSpace,
              [
                const Text("没有账号?")
                    .fontSize(13)
                    .textColor(const Color(0xFFb0b0ba)),
                3.horizontalSpace,
                const Text("立即注册")
                    .fontSize(13)
                    .textColor(theme.primaryColor)
                    .onTap(controller.toRegister),
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              [
                [
                  const CustomGradientLine(
                    width: 80,
                    height: 1.5,
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFb0b0ba)],
                    ),
                  ),
                  const Text(" 其他登录方式 ")
                      .fontSize(13)
                      .textColor(const Color(0xFFb0b0ba)),
                  const CustomGradientLine(
                    width: 80,
                    height: 1.5,
                    gradient: LinearGradient(
                      colors: [Color(0xFFb0b0ba), Colors.white],
                    ),
                  ),
                ].toRow(mainAxisAlignment: MainAxisAlignment.center),
                15.verticalSpace,
                [
                  CustomMaterialButton(
                    child: const Icon(
                      IconData(0xe6f6, fontFamily: 'IconFont'),
                      size: 36.0,
                      color: Color(0xFFb0b0ba),
                    ),
                    // onTap: () => controller.launchURL(
                    //     'https://github.com/DWHengr/linyu_mobile'),
                    onTap: () => Fluttertoast.showToast(msg: "功能开发中..."),
                  ),
                  15.horizontalSpace,
                  CustomMaterialButton(
                    child: const Icon(
                      IconData(0xe600, fontFamily: 'IconFont'),
                      size: 36.0,
                      color: Color(0xFFb0b0ba),
                    ),
                    // onTap: () => controller.launchURL(
                    //     'https://space.bilibili.com/135427028/channel/series'),
                    onTap: () => Fluttertoast.showToast(msg: "功能开发中..."),
                  ),
                ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              ]
                  .toColumn(mainAxisAlignment: MainAxisAlignment.center)
                  .expanded(),
            ].toColumn(mainAxisSize: MainAxisSize.min),
          ).expanded(),
        ]
            .toColumn()
            .height(screenHeight -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom)
            .toSingleChildScrollView(padding: 0),
      ).decorated(
          gradient: LinearGradient(
        colors: [
          theme.minorColor,
          const Color(0xFFFFFFFF),
          const Color(0xFFFFFFFF),
          const Color(0xFFFFFFFF)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
    );
  }
}
