import 'package:flutter/cupertino.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/config/getx/config.dart';
import 'package:linyu_mobile/config/network/http.dart';
import 'package:linyu_mobile/config/network/web_socket.dart' as websocket;

class SettingLogic extends Logic {
  final Http http = new Http(url: baseUrl);
  final TextEditingController httpUrlController = new TextEditingController();
  final TextEditingController wsUrlController = new TextEditingController();
  // 焦点
  final FocusNode httpUrlFocusNode = FocusNode(skipTraversal: true);
  final FocusNode wsUrlFocusNode = FocusNode(skipTraversal: true);

  void setUrl() {
    if (httpUrlController.text.isEmpty) {
      CustomFlutterToast.showErrorToast('请输入http地址');
      return;
    }
    if (wsUrlController.text.isEmpty) {
      CustomFlutterToast.showErrorToast('请输入ws地址');
      return;
    }
    baseUrl = httpUrlController.text;
    http.baseUrl = baseUrl!;
    websocket.websocketUrl = wsUrlController.text;
    wsManager.websocketIp = websocket.websocketUrl!;
    CustomFlutterToast.showSuccessToast('设置成功~');
    wsUrlFocusNode.unfocus();
    httpUrlFocusNode.unfocus();
    update([const Key("setting")]);
  }

  void _init() {
    httpUrlController.text = http.baseUrl;
    wsUrlController.text = wsManager.websocketIp;
    if (httpUrlController.text == 'http://27.25.159.46:9200')
      httpUrlController.text = '';
    if (wsUrlController.text == 'ws://27.25.159.46:9100')
      wsUrlController.text = '';
  }

  @override
  void onInit() {
    _init();
    super.onInit();
  }
}
