import 'package:flutter/foundation.dart' show Key, kDebugMode;
import 'package:get/get.dart' show Get, GetNavigation, Inst;
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:linyu_mobile/utils/config/getx/global_data.dart';
import 'package:linyu_mobile/utils/config/network/web_socket.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class MineLogic extends Logic {
  late dynamic currentUserInfo = {};
  final _wsManager = Get.find<WebSocketUtil>();
  final _globalData = Get.find<GlobalData>();
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  Future<void> init() async {
    currentUserInfo['name'] = _prefs.getString('username');
    currentUserInfo['portrait'] = _prefs.getString('portrait');
    currentUserInfo['account'] = _prefs.getString('account');
    currentUserInfo['sex'] = _prefs.getString('sex');
    update([const Key("mine")]);
  }

  void handlerLogout() async {
    try {
      await _prefs.clear();
      _globalData.currentToken = null;
      _wsManager.disconnect();
      if (kDebugMode) print('logout success');
      Get.back();
    } catch (e) {
      if (kDebugMode) print('logout failed: $e');
    } finally {
      Get.offAndToNamed('/login');
    }
  }

  void toSetting() async {
    final result = await Get.toNamed('/setting');
    if (!_wsManager.isConnected) _wsManager.connect();
    if (result != null) {
      init();
    }
  }

  void toEditMien() async {
    try {
      final result = await Get.toNamed('/edit_mine');
      if (result != null && result == true)
        init().then((_) => theme.changeThemeMode(
            sharedPreferences.getString('sex') == "女" ? "pink" : "blue"));
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      if (!_wsManager.isConnected) _wsManager.connect();
    }
  }

  void toChangeAccount() async {
    final result = await Get.toNamed('/change_accounts');
  }

  @override
  void onInit() {
    init().then((_) {
      if (kDebugMode) print('currentToken: ${_globalData.currentToken}');
    });
    super.onInit();
  }
}
