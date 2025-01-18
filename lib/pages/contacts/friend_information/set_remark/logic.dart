import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/pages/contacts/friend_information/logic.dart';
import 'package:linyu_mobile/utils/api/friend_api.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/config/getx/global_theme_config.dart';

class SetRemarkLogic extends GetxController {
  final _friendApi = FriendApi();
  final TextEditingController remarkController = TextEditingController();
  late int remarkLength = 0;
  late String friendId;
  final FriendInformationLogic _friendInformationLogic =
      GetInstance().find<FriendInformationLogic>();
  GlobalThemeConfig theme = GetInstance().find<GlobalThemeConfig>();

  @override
  void onInit() {
    super.onInit();
    remarkController.text = Get.arguments['remark'];
    friendId = Get.arguments['friendId'];
    remarkLength = remarkController.text.length;
  }

  void onSetRemark() async {
    final response =
        await _friendApi.setRemark(friendId, remarkController.text);
    if (response['code'] == 0) {
      CustomFlutterToast.showSuccessToast('备注设置成功~');
      _friendInformationLogic.getFriendInfo();
      Get.back();
    } else {
      CustomFlutterToast.showErrorToast(response['msg']);
    }
  }

  void onRemarkChanged(String value) {
    remarkLength = value.length;
    update([const Key('set_remark')]);
  }

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
  }
}
