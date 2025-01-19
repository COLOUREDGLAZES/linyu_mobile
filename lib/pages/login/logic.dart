import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/api/msg_api.dart';
import 'package:linyu_mobile/utils/config/network/web_socket.dart';
import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/utils/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPageLogic extends GetxController {
  final SharedPreferences _sharedPreferences = Get.find<SharedPreferences>();
  final _wsManager = Get.find<WebSocketUtil>();
  final _useApi = UserApi();
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  final _msgApi = MsgApi();
  final DeviceInfoPlugin _deviceInfoPlugin = new DeviceInfoPlugin();
  RxInt accountTextLength = 0.obs;

  RxInt passwordTextLength = 0.obs;

  late final FocusNode accountFocusNode;

  late final FocusNode passwordFocusNode;

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
  ]) =>
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

  void login(context) async {
    if (passwordFocusNode.hasFocus) passwordFocusNode.unfocus();
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    if (kDebugMode) print('$deviceInfo');
    final deviceName = deviceInfo.data['product'];
    String username = usernameController.text.trim(); // 去除前后空格
    String password = passwordController.text.trim(); // 去除前后空格
    if (username.isEmpty || password.isEmpty) {
      _dialog("用户名或密码不能为空~", context);
      return;
    }
    Map<String, dynamic> userData = {};
    try {
      final encryptedPassword = await passwordEncrypt(password);
      if (encryptedPassword.isNotEmpty) {
        final loginResult =
            await _useApi.login(username, encryptedPassword, deviceName ?? '');
        if (kDebugMode) print('userData: $loginResult');
        if (loginResult['code'] == 0) {
          // 使用循环减少冗余代码
          userData = loginResult['data'];
          // if (kDebugMode) print('userData: $userData');
          // final List<bool> setSharedPreferencesResult =
          final List<bool> setSharedPreferencesResult = await Future.wait([
            _sharedPreferences.setString('x-token', userData['token']),
            _sharedPreferences.setString('username', userData['username']),
            _sharedPreferences.setString('userId', userData['userId']),
            _sharedPreferences.setString('account', userData['account']),
            _sharedPreferences.setString('portrait', userData['portrait']),
            _sharedPreferences.setString('sex', userData['sex'] ?? '男'),
          ]);
          for (bool result in setSharedPreferencesResult)
            if (!result) {
              _dialog("登录失败，请稍后再试~", context);
              return;
            }
          await Get.offAndToNamed('/?sex=${userData['sex'] ?? '男'}');
        } else
          _dialog("用户名或密码错误，请重试尝试~", context);
      }
    } catch (e) {
      // 处理异常情况，例如网络错误等
      _dialog("登录过程中出现$e错误，请稍后再试~", context);
    }
  }

  void toRegister() => Get.toNamed('/register');

  void toRetrievePassword() => Get.toNamed('/retrieve_password');

  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri))
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      else
        _dialog("无法打开链接: $url", Get.context!);
    } catch (e) {
      _dialog("打开链接时发生错误: $e", Get.context!);
    }
  }

  void toSetting() async {
    try {
      final result = await Get.toNamed('/setting');
      if (!_wsManager.isConnected) _wsManager.connect();
    } catch (e) {
      // 处理导航到设置页面时可能出现的错误
      _dialog("导航到设置页面时出现错误：$e，请稍后再试~", Get.context!);
    }
  }

  @override
  void onInit() {
    usernameController = new TextEditingController();
    passwordController = new TextEditingController();
    accountFocusNode = new FocusNode();
    passwordFocusNode = new FocusNode();
    super.onInit();
  }

  @override
  void onClose() {
    try {
      usernameController.dispose();
      passwordController.dispose();
      accountFocusNode.dispose();
      passwordFocusNode.dispose();
    } catch (e) {
      if (kDebugMode) print('onClose error: $e');
    } finally {
      super.onClose();
    }
  }
}
