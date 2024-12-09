import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/utils/encrypt.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPageLogic extends GetxController {
  final _useApi = UserApi();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  RxInt accountTextLength = 0.obs;

  RxInt passwordTextLength = 0.obs;

  //用户账号输入长度
  void onAccountTextChanged(String value) {
    accountTextLength.value = value.length;
    if (accountTextLength.value >= 30) accountTextLength.value = 30;
  }

  //用户密码输入长度
  void onPasswordTextChanged(String value) {
    passwordTextLength.value = value.length;
    if (passwordTextLength.value >= 16) passwordTextLength.value = 16;
  }

  void _dialog(
    String content,
    BuildContext context, [
    String title = '登录失败',
  ]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  void login(context) async {
    String username = usernameController.text.trim(); // 去除前后空格
    String password = passwordController.text.trim(); // 去除前后空格
    if (username.isEmpty || password.isEmpty) {
      _dialog("用户名或密码不能为空~", context);
      return;
    }

    try {
      final encryptedPassword = await passwordEncrypt(password);
      final loginResult = await _useApi.login(username, encryptedPassword);

      if (loginResult['code'] == 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // 使用循环减少冗余代码
        final userData = loginResult['data'];
        await Future.wait([
          prefs.setString('x-token', userData['token']),
          prefs.setString('username', userData['username']),
          prefs.setString('userId', userData['userId']),
          prefs.setString('account', userData['account']),
          prefs.setString('portrait', userData['portrait']),
          prefs.setString('sex', userData['sex'] ?? '男'),
        ]);
        Get.offAllNamed('/?sex=${userData['sex'] ?? '男'}');
      } else {
        _dialog("用户名或密码错误，请重试尝试~", context);
      }
    } catch (e) {
      // 处理异常情况，例如网络错误等
      _dialog("登录过程中出现错误，请稍后再试~", context);
    }
}


  void toRegister() => Get.toNamed('/register');

  void toRetrievePassword() => Get.toNamed('/retrieve_password');

  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void onClose() {
    super.onClose();
    usernameController.dispose();
    passwordController.dispose();
  }
}
