import 'package:flutter/cupertino.dart' show Key;
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:linyu_mobile/utils/api/msg_api.dart';

class AboutLogic extends GetxController {
  final _msgApi = new MsgApi();

  // 心灵鸡汤
  Map<String, dynamic> lifeStr = {
    'data': {
      'content': '承君此诺，必守一生~',
    }
  };

  Future<void> init({int? index}) async {
    lifeStr = await _msgApi.getLifeString();
    if (kDebugMode) print(lifeStr);
    update([const Key('about')]);
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }
}
