import 'dart:convert' show jsonDecode;

import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:get/get.dart';
import 'package:linyu_mobile/components/custom_string_detector/index.dart'
    show StringDetector;
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;

class TextMessage extends StatelessThemeWidget {
  final dynamic value;
  final bool isRight;

  const TextMessage({
    super.key,
    required this.value,
    required this.isRight,
  });

  void _showCupertinoSheet(String number) => showCupertinoModalPopup(
        context: Get.context!,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: [
            Text(number).textColor(theme.primaryColor).fontSize(20),
            const Text('可能是电话号码，是否拨打？')
          ].toColumn(),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context); // 关闭弹窗
                final uri = Uri.parse('tel:$number');
                if (await canLaunchUrl(uri))
                  await launchUrl(uri);
                else
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('无法拨号: $number')
                            .textColor(theme.primaryColor)),
                  );
              },
              child: const Text('拨打电话').textColor(theme.primaryColor),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: number));
              },
              child: const Text('复制号码').textColor(theme.primaryColor),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消').textColor(theme.primaryColor),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Map msgContent;
    if (value['msgContent'].runtimeType == String)
      msgContent = jsonDecode(value['msgContent']);
    else
      msgContent = value['msgContent'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isRight ? theme.primaryColor : Colors.white,
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
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(Get.context!).size.width * 0.7,
      ),
      child: StringDetector(
        text: msgContent['content'],
        linkColor: isRight && globalData.currentSex == '男'
            ? Colors.white
            : Colors.blue,
        phoneColor: isRight && globalData.currentSex == '男'
            ? Colors.white
            : Colors.blue,
        style: TextStyle(
            color: isRight ? Colors.white : Colors.black, fontSize: 14),
        onTap: (number) async => _showCupertinoSheet(number!),
      ),
    );
  }
}
