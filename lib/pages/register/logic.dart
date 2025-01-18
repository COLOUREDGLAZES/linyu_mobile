import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_pickers/time_picker/model/date_type.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:get/get.dart' show Get, GetNavigation;
import 'package:intl/intl.dart';

import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:linyu_mobile/utils/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' show MultipartFile, FormData;
import 'dart:io';

// class RegisterPageLogic extends GetxController {
class RegisterPageLogic extends Logic {
  final _useApi = UserApi();

  //用户名
  final usernameController = TextEditingController();

  //生日输入框控制器
  final TextEditingController birthdayController = new TextEditingController();

  //账号
  final accountController = TextEditingController();

  //密码
  final passwordController = TextEditingController();

  //邮箱
  final mailController = TextEditingController();

  //验证码
  final codeController = TextEditingController();

  final FocusNode mailFocusNode = new FocusNode();
  final FocusNode codeFocusNode = new FocusNode();

  //计时器
  late Timer _timer;
  int _countdownTime = 0;

  int get countdownTime => _countdownTime;

  set countdownTime(int value) {
    _countdownTime = value;
    update([
      const Key("register"),
    ]);
  }

  int _userTextLength = 0;

  int get userTextLength => _userTextLength;

  set userTextLength(int value) {
    _userTextLength = value;
    update([const Key("register")]);
  }

  int _accountTextLength = 0;

  int get accountTextLength => _accountTextLength;

  set accountTextLength(int value) {
    _accountTextLength = value;
    update([const Key("register")]);
  }

  int _passwordTextLength = 0;

  int get passwordTextLength => _passwordTextLength;

  set passwordTextLength(int value) {
    _passwordTextLength = value;
    update([const Key("register")]);
  }

  //性别
  late String _sex;

  String get sex => _sex;

  set sex(String value) {
    _sex = value;
    update([const Key("register")]);
  }

  //男性颜色被选中时的颜色
  Color _maleColorActive = const Color(0xFFe0e0e0);

  Color get maleColorActive => _maleColorActive;

  set maleColorActive(Color value) {
    _maleColorActive = value;
    update([const Key("register")]);
  }

  //男性文字颜色被选中时的颜色
  Color _maleTextColorActive = const Color(0xFF727275);

  Color get maleTextColorActive => _maleTextColorActive;

  set maleTextColorActive(Color value) {
    _maleTextColorActive = value;
    update([const Key("register")]);
  }

  //女性颜色被选中时的颜色
  Color _femaleColorActive = const Color(0xFFe0e0e0);

  Color get femaleColorActive => _femaleColorActive;

  set femaleColorActive(Color value) {
    _femaleColorActive = value;
    update([const Key("register")]);
  }

  //女性文字颜色被选中时的颜色
  Color _femaleTextColorActive = const Color(0xFF727275);

  Color get femaleTextColorActive => _femaleTextColorActive;

  set femaleTextColorActive(Color value) {
    _femaleTextColorActive = value;
    update([const Key("register")]);
  }

  //生日
  DateTime _birthday = DateTime.now().toLocal();

  DateTime get birthday => _birthday;

  set birthday(DateTime value) {
    _birthday = value;
    update([const Key("register")]);
  }

  //当前用户信息
  late dynamic currentUserInfo = {};

  //用户名输入长度
  void onUserTextChanged(String value) {
    userTextLength = value.length;
    if (userTextLength >= 30) userTextLength = 30;
  }

  //用户账号输入长度
  void onAccountTextChanged(String value) {
    accountTextLength = value.length;
    if (accountTextLength >= 30) accountTextLength = 30;
  }

  //用户密码输入长度
  void onPasswordTextChanged(String value) {
    passwordTextLength = value.length;
    if (passwordTextLength >= 16) passwordTextLength = 16;
  }

  //发送验证码
  void onTapSendMail() async {
    if (countdownTime > 0) {
      return; // 如果倒计时未结束，直接返回
    }

    final String mail = mailController.text;
    if (mail.isEmpty) {
      CustomFlutterToast.showErrorToast("邮箱不能为空");
      return; // 若邮箱为空，提示用户并返回
    }

    try {
      final emailVerificationResult = await _useApi.emailVerification(mail);
      if (emailVerificationResult['code'] == 0) {
        CustomFlutterToast.showSuccessToast("发送成功~");
        countdownTime = 30;
        _startCountdownTimer();
      } else
        CustomFlutterToast.showErrorToast(emailVerificationResult['msg']);
    } catch (e) {
      CustomFlutterToast.showErrorToast("发送验证码失败，请重试");
      if (kDebugMode) print("Error sending email verification: $e");
    }
  }

  // //设置性别值
  // void _setSexValue(String value) {
  //   sex = value;
  //   theme.changeThemeMode(sex == "女" ? "pink" : "blue");
  //   if (value == "男") {
  //     maleColorActive = const Color(0xFF4C9BFF);
  //     maleTextColorActive = Colors.white;
  //     femaleColorActive = const Color(0xFFe0e0e0);
  //     femaleTextColorActive = const Color(0xFF727275);
  //   } else {
  //     maleColorActive = const Color(0xFFe0e0e0);
  //     maleTextColorActive = const Color(0xFF727275);
  //     femaleColorActive = const Color(0xFFffa0cf);
  //     femaleTextColorActive = Colors.white;
  //   }
  // }
  //
  // //设置性别
  // void setSex(String value) {
  //   _setSexValue(value);
  //   return;
  // }

  //选择生日
  Future<void> selectDate(BuildContext context) async {
    final iniDate = PDuration.parse(birthday);
    Pickers.showDatePicker(
      context,
      maxDate: PDuration.parse(DateTime.now()),
      minDate: PDuration.parse(DateTime(1900, 1, 1)),
      pickerStyle: PickerStyle(
        commitButton: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 12, right: 22),
          child: Text('确定',
              style: TextStyle(color: theme.primaryColor, fontSize: 16.0)),
        ),
        headDecoration: BoxDecoration(
          color: sex == "女" ? const Color(0xFFfcebff) : const Color(0xFFe6f2ff),
        ),
        backgroundColor:
            sex == "女" ? const Color(0xFFfcebff) : const Color(0xFFe6f2ff),
      ),
      selectDate: iniDate,
      onChanged: (res) {
        birthday = DateTime(
          res.getSingle(DateType.Year),
          res.getSingle(DateType.Month),
          res.getSingle(DateType.Day),
        );
        birthdayController.text = DateFormat('yyyy-MM-dd').format(birthday);
      },
      onConfirm: (res) {
        birthday = DateTime(
          res.getSingle(DateType.Year),
          res.getSingle(DateType.Month),
          res.getSingle(DateType.Day),
        );
        birthdayController.text =
            DateFormat('yyyy-MM-dd').format(birthday); // 格式化日期
      },
    );
  }

  //上传头像
  // Future<void> _uploadPicture(File picture) async {
  //   try {
  //     final fileName = picture.path.split('/').last;
  //     final file =
  //         await MultipartFile.fromFile(picture.path, filename: fileName);
  //
  //     final formData = FormData.fromMap({
  //       'type': 'image/jpeg',
  //       'name': fileName,
  //       'size': picture.lengthSync(),
  //       'file': file,
  //     });
  //
  //     final result = await _useApi.upload(formData);
  //
  //     if (result['code'] == 0) {
  //       currentUserInfo['portrait'] = result['data'];
  //       final sharedPreferences = await SharedPreferences.getInstance();
  //       await sharedPreferences.setString(
  //           'portrait', currentUserInfo['portrait']);
  //       globalData.currentAvatarUrl = currentUserInfo['portrait'];
  //       update([const Key("register")]);
  //       CustomFlutterToast.showSuccessToast('头像修改成功');
  //     } else
  //       CustomFlutterToast.showErrorToast(result['msg']);
  //   } catch (e) {
  //     if (kDebugMode) print('头像上传失败: $e');
  //     CustomFlutterToast.showErrorToast('头像上传失败: $e');
  //   }
  // }

  //点击头像按钮弹出底部选择框
  // void selectPortrait() {
  //   Get.toNamed('/image_viewer_update', arguments: {
  //     'imageUrl': currentUserInfo['portrait'] ??
  //         'http://192.168.101.4:9000/linyu/default-portrait.jpg',
  //     'onConfirm': _uploadPicture
  //   });
  // }

  //开始倒计时
  void _startCountdownTimer() {
    const oneSec = Duration(seconds: 1);
    callback(timer) => {
          if (countdownTime < 1)
            {_timer.cancel()}
          else
            {countdownTime = countdownTime - 1}
        };
    _timer = Timer.periodic(oneSec, callback);
  }

  //注册
  void onRegister() async {
    String username = usernameController.text;
    String account = accountController.text;
    String password = passwordController.text;
    String email = mailController.text;
    String code = codeController.text;
    String birthdayStr = birthday.toString();
    if (username.isEmpty ||
        account.isEmpty ||
        password.isEmpty ||
        email.isEmpty ||
        code.isEmpty ||
        birthdayStr.isEmpty) {
      CustomFlutterToast.showErrorToast("不能为空，请填写完整！");
    } else {
      final encryptedPassword = await passwordEncrypt(password);
      assert(encryptedPassword != "-1");
      final registerResult = await _useApi.register(
          username, birthdayStr, account, encryptedPassword, email, code);
      if (registerResult['code'] == 0) {
        CustomFlutterToast.showSuccessToast(registerResult['msg']);
        Get.back();
      } else
        CustomFlutterToast.showErrorToast(registerResult['msg']);
    }
  }

  @override
  void onInit() {
    sex = "男";
    super.onInit();
  }

  @override
  void onClose() {
    try {
      usernameController.dispose();
      accountController.dispose();
      passwordController.dispose();
      mailController.dispose();
      codeController.dispose();
      mailFocusNode.dispose();
      codeFocusNode.dispose();
      birthdayController.dispose();
    } catch (e) {
      if (kDebugMode) print("Error disposing controllers and focus nodes: $e");
    } finally {
      super.onClose();
    }
  }
}
