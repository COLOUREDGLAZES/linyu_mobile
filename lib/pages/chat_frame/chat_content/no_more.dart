import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoMoreContent extends StatelessWidget {
  final String? value;

  const NoMoreContent({super.key, this.value});

  @override
  Widget build(BuildContext context) => const Text(
        '没有更多消息了',
      )
          .textColor(Colors.grey)
          .fontSize(12)
          .center()
          .paddingOnly(top: 8, bottom: 0);
}
