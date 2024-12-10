import 'package:get/get.dart';

class QrOtherResultLogic extends GetxController {
  late String text;

  @override
  void onInit() {
    super.onInit();
    text = Get.arguments['text'];
  }
}
