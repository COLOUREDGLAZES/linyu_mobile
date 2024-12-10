import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/api/msg_api.dart';
import 'package:linyu_mobile/components/custom_image/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

class ImageMessage extends StatelessThemeWidget {
  final _msgApi = MsgApi();
  final dynamic value;
  final bool isRight;

  ImageMessage({
    super.key,
    required this.value,
    required this.isRight,
  });

  Future<String> onGetImg() async {
    dynamic res = await _msgApi.getMedia(value['id']);
    if (res['code'] == 0) {
      return res['data'];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(Get.context!).size.width * 0.4,
      width: MediaQuery.of(Get.context!).size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.black,
        // borderRadius: BorderRadius.all(Radius.circular(5)),
        borderRadius: isRight
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              )
            : const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
      ),
      child: FutureBuilder<String>(
        future: onGetImg(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomImage(url: snapshot.data ?? '');
          } else {
            return Container(
              width: MediaQuery.of(Get.context!).size.width * 0.4,
              color: isRight ? theme.primaryColor : Colors.white,
              height: MediaQuery.of(Get.context!).size.width * 0.4,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(0xffffffff),
                  strokeWidth: 2,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
