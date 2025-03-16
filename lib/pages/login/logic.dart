import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart' show Logic;
import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/utils/encrypt.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPageLogic extends Logic {
  final _useApi = UserApi();
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  final DeviceInfoPlugin _deviceInfoPlugin = new DeviceInfoPlugin();
  RxInt accountTextLength = 0.obs;

  RxInt passwordTextLength = 0.obs;

  late final FocusNode accountFocusNode;

  late final FocusNode passwordFocusNode;

  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;
  set isLoggingIn(bool value) {
    _isLoggingIn = value;
    update([const Key('login')]);
  }

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
    isLoggingIn = true;
    if (passwordFocusNode.hasFocus) passwordFocusNode.unfocus();
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    if (kDebugMode) print('$deviceInfo');
    final deviceName = deviceInfo.data['product'];
    String username = usernameController.text.trim(); // 去除前后空格
    String password = passwordController.text.trim(); // 去除前后空格
    if (username.isEmpty || password.isEmpty) {
      _dialog("用户名或密码不能为空~", context);
      isLoggingIn = false;
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

          if (kDebugMode)
            print('userData talkBackground is: ${userData['talkBackground']}');
          final String currentUserId = userData['userId'];
          final List<bool> setSharedPreferencesResult = await Future.wait([
            sharedPreferences.setString('currentUserId', currentUserId),
            sharedPreferences.setString(
                'x-token_$currentUserId', userData['token']),
            sharedPreferences.setString(
                'username_$currentUserId', userData['username']),
            sharedPreferences.setString(
                'account_$currentUserId', userData['account']),
            sharedPreferences.setString(
                'portrait_$currentUserId', userData['portrait']),
            sharedPreferences.setString(
                'sex_$currentUserId', userData['sex'] ?? '男'),
            sharedPreferences.setString(
                'talkBackground_$currentUserId',
                userData['talkBackground'] ??
                    'http://114.96.70.115:19000/linyu/default-portrait.jpg'),
          ]);
          for (bool result in setSharedPreferencesResult)
            if (!result) {
              _dialog("登录失败，请稍后再试~", context);
              isLoggingIn = false;
              return;
            }
          // globalData.currentUserId = currentUserId;
          // globalData.currentToken = userData['token'];
          // globalData.currentUserName = userData['username'];
          // globalData.currentAccount = userData['account'];
          // globalData.currentPortrait = userData['portrait'];
          // globalData.currentSex = userData['sex'] ?? '男';
          // globalData.currentTalkBackground = userData['talkBackground'] ??
          //     'http://114.96.70.115:19000/linyu/default-portrait.jpg';
          final bool setCurrentUserInfoResult =
              await globalData.setCurrentUserInfo(userData);
          // await Get.offAndToNamed('/?sex=${globalData.currentSex ?? '男'}');
          if (setCurrentUserInfoResult)
            await Get.offAndToNamed('/');
          else
            _dialog("登录失败，请稍后再试~", context);
        } else
          isLoggingIn = false;
        _dialog("用户名或密码错误，请重试尝试~", context);
      }
    } catch (e) {
      if (kDebugMode) print('login error: $e');
      isLoggingIn = false;
    }
  }

  void toRegister() {
    if (!this.isLoggingIn) Get.toNamed('/register');
  }

  void toRetrievePassword() {
    if (!this.isLoggingIn) Get.toNamed('/retrieve_password');
  }

  Future<void> launchURL(String url) async {
    if (this.isLoggingIn) return;
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
      if (!this.isLoggingIn) await Get.toNamed('/setting');
    } catch (e) {
      // 处理导航到设置页面时可能出现的错误
      _dialog("导航到设置页面时出现错误：$e，请稍后再试~", Get.context!);
    } finally {
      if (!wsManager.isConnected) wsManager.connect();
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
