import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/getx_config/GlobalData.dart';
import 'package:linyu_mobile/utils/web_socket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MineLogic extends GetxController {
  late dynamic currentUserInfo = {};
  final _wsManager = Get.find<WebSocketUtil>();
  final _globalData = Get.find<GlobalData>();
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  void init() async {
    currentUserInfo['name'] = _prefs.getString('username');
    currentUserInfo['portrait'] = _prefs.getString('portrait');
    currentUserInfo['account'] = _prefs.getString('account');
    currentUserInfo['sex'] = _prefs.getString('sex');
    update([const Key("mine")]);
  }

  void handlerLogout() async {
    final bool isLogout = await _prefs.clear();
    _globalData.currentToken = null;
    _wsManager.disconnect();
    if (kDebugMode) print('logout success: $isLogout');
    if (isLogout) Get.offAllNamed('/login');
  }

  @override
  void onInit() {
    init();
    if (kDebugMode) print('currentToken: ${_globalData.currentToken}');
    super.onInit();
  }
}
