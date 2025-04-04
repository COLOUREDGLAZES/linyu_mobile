import 'package:flutter/cupertino.dart';
import 'package:linyu_mobile/api/qr_api.dart';
import 'package:linyu_mobile/config/getx/config.dart' show Logic;

// class MineQRCodeLogic extends GetxController {
class MineQRCodeLogic extends Logic {
  final _qrApi = QrApi();
  late dynamic currentUserInfo = {};
  late String qrCode = '';

  @override
  void onInit() async {
    super.onInit();
    currentUserInfo['name'] = globalData.currentUserName;
    currentUserInfo['portrait'] = globalData.currentPortrait;
    currentUserInfo['account'] = globalData.currentAccount;
    currentUserInfo['sex'] = globalData.currentSex;
    update([const Key("mine_qr_code")]);
    onQrCode();
  }

  void onQrCode() {
    _qrApi.code().then((res) {
      if (res['code'] == 0) {
        qrCode = res['data'];
        update([const Key("mine_qr_code")]);
      }
    });
  }
}
