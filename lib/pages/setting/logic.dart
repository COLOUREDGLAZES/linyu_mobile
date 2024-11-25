import 'package:flutter/cupertino.dart';
import 'package:linyu_mobile/api/Http.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/pages/setting/index.dart';
import 'package:linyu_mobile/utils/getx_config/config.dart';
import 'package:linyu_mobile/utils/web_socket.dart';

class SettingLogic extends Logic<SettingPage> {
  final Http http = new Http(url: baseUrl);
  final wsManager = WebSocketUtil(websocketUrl: websocketIp);

  final TextEditingController httpUrlController = new TextEditingController();
  final TextEditingController wsUrlController = new TextEditingController();

  void setUrl() {
    this.http.baseUrl = httpUrlController.text;
    this.wsManager.websocketIp = wsUrlController.text;
    CustomFlutterToast.showSuccessToast('设置成功~');
    update([const Key("setting")]);
  }

  @override
  void onInit() {
    super.onInit();
    httpUrlController.text = http.baseUrl;
    wsUrlController.text = wsManager.websocketIp;
  }

}
