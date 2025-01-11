import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/api/msg_api.dart';
import 'package:linyu_mobile/utils/config/network/web_socket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/utils/encrypt.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPageLogic extends GetxController {
  final SharedPreferences _sharedPreferences = Get.find<SharedPreferences>();
  final _wsManager = Get.find<WebSocketUtil>();
  final _useApi = UserApi();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _msgApi = MsgApi();
  final DeviceInfoPlugin _deviceInfoPlugin = new DeviceInfoPlugin();
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
    final lifeStr = await _msgApi.getLifeString();

    if (kDebugMode) print('get lifeStr: $lifeStr');

    final deviceInfo = await _deviceInfoPlugin.deviceInfo;

    if (kDebugMode) print('$deviceInfo');

    final deviceName = deviceInfo.data['product'];
    String username = usernameController.text.trim(); // 去除前后空格
    String password = passwordController.text.trim(); // 去除前后空格
    if (username.isEmpty || password.isEmpty) {
      _dialog("用户名或密码不能为空~", context);
      return;
    }
    try {
      final encryptedPassword = await passwordEncrypt(password);
      if (encryptedPassword.isNotEmpty) {
        final loginResult =
            await _useApi.login(username, encryptedPassword, deviceName ?? '');
        if (loginResult['code'] == 0) {
          // 使用循环减少冗余代码
          final userData = loginResult['data'];
          await Future.wait([
            _sharedPreferences.setString('x-token', userData['token']),
            _sharedPreferences.setString('username', userData['username']),
            _sharedPreferences.setString('userId', userData['userId']),
            _sharedPreferences.setString('account', userData['account']),
            _sharedPreferences.setString('portrait', userData['portrait']),
            _sharedPreferences.setString('sex', userData['sex'] ?? '男'),
          ]);
          Get.offAllNamed('/?sex=${userData['sex'] ?? '男'}');
        }
      } else
        _dialog("用户名或密码错误，请重试尝试~", context);
    } catch (e) {
      // 处理异常情况，例如网络错误等
      _dialog("登录过程中出现$e错误，请稍后再试~", context);
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

  void toSetting() async {
    final result = await Get.toNamed('/setting');
    if (!_wsManager.isConnected) _wsManager.connect();
  }

  @override
  void onClose() {
    super.onClose();
    usernameController.dispose();
    passwordController.dispose();
  }
}
