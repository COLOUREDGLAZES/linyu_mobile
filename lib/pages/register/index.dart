import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linyu_mobile/components/custom_button/index.dart';
import 'package:linyu_mobile/pages/register/logic.dart';
import 'package:linyu_mobile/components/custom_text_field/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

class RegisterPage extends CustomWidget<RegisterPageLogic> {
  RegisterPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.minorColor, const Color(0xFFFFFFFF)],
          // 渐变颜色
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "欢迎注册",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  "请填写相关注册信息。",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 15.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFFF2F2F2),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // CustomUpdatePortrait(
                      //     // isEdit: controller.isEdit,
                      //     isEdit: true,
                      //     onTap: () => controller.selectPortrait(),
                      //     // onTap: () {},
                      //     // url: controller.currentUserInfo['portrait'] ??
                      //     //     'http://192.168.101.4:9000/linyu/default-portrait.jpg',
                      //     url:
                      //         'http://192.168.101.4:9000/linyu/default-portrait.jpg',
                      //     size: 80,
                      //     radius: 50),
                      // const SizedBox(height: 16),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       GestureDetector(
                      //         onTap: () => controller.setSex('男'),
                      //         child: Container(
                      //           height: 30,
                      //           padding:
                      //               const EdgeInsets.symmetric(horizontal: 10),
                      //           decoration: BoxDecoration(
                      //             color: controller.maleColorActive,
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           child: Row(
                      //             children: [
                      //               Icon(
                      //                 Icons.male,
                      //                 size: 20,
                      //                 color: controller.maleTextColorActive,
                      //               ),
                      //               const SizedBox(width: 2),
                      //               Text(
                      //                 '男生',
                      //                 style: TextStyle(
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.bold,
                      //                   color: controller.maleTextColorActive,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //       const SizedBox(width: 30),
                      //       GestureDetector(
                      //         onTap: () => controller.setSex('女'),
                      //         child: Container(
                      //           height: 30,
                      //           padding:
                      //               const EdgeInsets.symmetric(horizontal: 10),
                      //           decoration: BoxDecoration(
                      //             color: controller.femaleColorActive,
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           child: Row(
                      //             children: [
                      //               Icon(
                      //                 Icons.female,
                      //                 size: 20,
                      //                 color: controller.femaleTextColorActive,
                      //               ),
                      //               const SizedBox(width: 2),
                      //               Text(
                      //                 '女生',
                      //                 style: TextStyle(
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.bold,
                      //                   color: controller.femaleTextColorActive,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 16),
                      CustomTextField(
                        labelText: "用户名",
                        controller: controller.usernameController,
                        onChanged: controller.onUserTextChanged,
                        suffix: Text('${controller.userTextLength}/30'),
                        inputLimit: 30,
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        labelText: "生日",
                        hintText: '请选择日期',
                        controller: controller.birthdayController,
                        readOnly: true,
                        showCursor: false,
                        suffixIcon: IconButton(
                          onPressed: () => controller.selectDate(context),
                          icon: Icon(Icons.calendar_today,
                              size: 20, color: theme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        labelText: "账号",
                        controller: controller.accountController,
                        onChanged: controller.onAccountTextChanged,
                        suffix: Text('${controller.accountTextLength}/30'),
                        inputLimit: 30,
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        labelText: "密码",
                        controller: controller.passwordController,
                        obscureText: true,
                        onChanged: controller.onPasswordTextChanged,
                        suffix: Text('${controller.passwordTextLength}/16'),
                        inputLimit: 16,
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        labelText: "邮箱",
                        controller: controller.mailController,
                        focusNode: controller.mailFocusNode,
                        onEditingComplete: () {
                          controller.onTapSendMail();
                          controller.codeFocusNode.requestFocus();
                        },
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        labelText: '验证码',
                        hintText: "请输入验证码",
                        focusNode: controller.codeFocusNode,
                        controller: controller.codeController,
                        suffix: controller.mailController.text != ""
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: controller.onTapSendMail,
                                    child: Text(
                                      controller.countdownTime > 0
                                          ? '${controller.countdownTime}后重新获取'
                                          : '获取验证码',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: controller.countdownTime > 0
                                            ? const Color.fromARGB(
                                                255, 183, 184, 195)
                                            : const Color.fromARGB(
                                                255, 17, 132, 255),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                ],
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                CustomButton(
                  text: "立即注册",
                  onTap: controller.onRegister,
                  width: MediaQuery.of(context).size.width,
                  type: 'gradient',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
