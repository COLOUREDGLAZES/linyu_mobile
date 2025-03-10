import 'package:flutter/material.dart';

class NoMoreContent extends StatelessWidget {
  final String? value;

  const NoMoreContent({super.key, this.value});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 8, bottom: 0),
        child: Center(
          child: Text(
            '没有更多消息了',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
}
