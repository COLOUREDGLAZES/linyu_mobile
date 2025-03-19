import 'package:flutter/cupertino.dart' show BuildContext;
import 'package:flutter/foundation.dart' show Key, kDebugMode;
import 'package:get/get.dart' show Get, GetNavigation;
import 'package:linyu_mobile/utils/config/getx/config.dart';

import 'index.dart';

class MineLogic extends Logic<MinePage> {
  late dynamic currentUserInfo = {};
  Future<void> init() async {
    currentUserInfo['name'] = globalData.currentUserName;
    currentUserInfo['portrait'] = globalData.currentPortrait;
    currentUserInfo['account'] = globalData.currentAccount;
    currentUserInfo['sex'] = globalData.currentSex;
    update([const Key("mine")]);
  }

  void handlerLogout() async {
    try {
      globalData.clearUserInfo();
      wsManager.disconnect();
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
    if (!wsManager.isConnected) wsManager.connect();
    if (result != null) {
      init();
    }
  }

  void toEditMien() async {
    try {
      final result = await Get.toNamed('/edit_mine');
      if (result != null && result == true)
        init().then((_) => theme
            .changeThemeMode(globalData.currentSex == "女" ? "pink" : "blue"));
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  void toChangeAccount(BuildContext context) async {
    final result = await Get.toNamed('/change_account');
    if (result != null && result == true) {
      init().then((_) {
        if (kDebugMode) print('currentAccount: ${globalData.currentAccount}');
      });
    }
  }

  @override
  void onInit() {
    init().then((_) {
      if (kDebugMode) print('currentToken: ${globalData.currentToken}');
    });
    super.onInit();
  }
}
