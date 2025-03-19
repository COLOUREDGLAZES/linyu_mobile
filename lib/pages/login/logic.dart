import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart' show Logic;
import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/utils/encrypt.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginLogic extends Logic {
  final _useApi = UserApi();
  late final TextEditingController accountController;
  late final TextEditingController passwordController;
  final DeviceInfoPlugin _deviceInfoPlugin = new DeviceInfoPlugin();

  late Map<String, dynamic>? userData;

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

  bool isAddAccount = false;

  String? otherUserId;

  Map<String, String> otherAccounts = {};

  bool _isLogOut = false;
  bool get isLogOut => _isLogOut;
  set isLogOut(bool value) {
    if (value != null && value) otherUserId = Get.arguments['otherUserId'];
    _isLogOut = value;
    update([const Key('logout')]);
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
    String username = accountController.text.trim(); // 去除前后空格
    String password = passwordController.text.trim(); // 去除前后空格
    if (username.isEmpty || password.isEmpty) {
      _dialog("用户名或密码不能为空~", context);
      isLoggingIn = false;
      return;
    }

    //如果是从退出登录页面跳转过来的，直接登录把token以及其他信息设置到全局变量中
    if (isLogOut && otherUserId != null)
    //如果是用其他账号登录的直接登录
    if (otherAccounts.containsKey(username)) {
      globalData.currentUserId = otherAccounts[username]!;
      await globalData.init();
      if (globalData.currentTalkBackground != null &&
          globalData.currentTalkBackground!.isNotEmpty)
        await globalData.updateTextColor(globalData.currentTalkBackground!);
      await Get.offAndToNamed('/');
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
                    'https://p3-pc-sign.douyinpic.com/obj/douyin-user-image-file/33464188d8a6756edc172ab0b48182d4?lk3s=93de098e&x-expires=1742580000&x-signature=JXhvWepluXb%2FqnNqKN%2BSDSVBSuw%3D&from=2480802190&quot'),
          ]);
          for (bool result in setSharedPreferencesResult)
            if (!result) {
              _dialog("登录失败，请稍后再试~", context);
              isLoggingIn = false;
              return;
            }
          this.userData = userData;

          if (isAddAccount)
            Get.back(result: this.userData);
          else
            await Get.offAndToNamed('/');
          return;
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

  void init() async {
    try {
      isAddAccount = Get.arguments['isAddAccount'] ?? false;
      isLogOut = Get.arguments['isLogout'] ?? false;
    } catch (e) {
      if (kDebugMode) print('init error: $e');
    }
  }

  @override
  void onInit() {
    accountController = new TextEditingController();
    passwordController = new TextEditingController();
    accountFocusNode = new FocusNode();
    passwordFocusNode = new FocusNode();
    init();
    super.onInit();
  }

  @override
  void onReady() {
    if (isLogOut) {
      //是退出登录如果还有其他账号，直接用其他账号登录
      accountController.text =
          sharedPreferences.getString('account_$otherUserId') ?? '';
      //随便写一个密码，防止空密码登录
      passwordController.text = '123456';
      globalData.userIds.forEach((userId) {
        final String? account = sharedPreferences.getString('account_$userId');
        if (account != null && account.isNotEmpty)
          otherAccounts[account] = userId;
      });
    }
    super.onReady();
  }

  @override
  void onClose() {
    try {
      accountController.dispose();
      passwordController.dispose();
      accountFocusNode.dispose();
      passwordFocusNode.dispose();
      if (userData != null) globalData.setCurrentUserInfo(userData!);
    } catch (e) {
      if (kDebugMode) print('onClose error: $e');
    } finally {
      super.onClose();
    }
  }
}
