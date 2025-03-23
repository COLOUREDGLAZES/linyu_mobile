import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Color,
        Colors,
        DefaultTextStyle,
        RichText,
        StatelessWidget,
        TextDecoration,
        TextSpan,
        TextStyle,
        Widget;

class PhoneNumberDetector extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? numberColor;

  final void Function(String? number)? onTap;

  static final RegExp _phoneRegex = RegExp(
    r'(\+?\d{1,3}[-. ]?\(?\d{1,3}\)?[-. ]?\d{1,4}[-. ]?\d{1,4}[-. ]?\d{1,9})',
  );

  const PhoneNumberDetector(
      {super.key,
      required this.text,
      this.style,
      this.onTap,
      this.numberColor});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpans = [];
    int lastEnd = 0;
    for (final match in _phoneRegex.allMatches(text)) {
      final start = match.start;
      final end = match.end;
      // 添加非电话号码的普通文本
      if (start > lastEnd)
        textSpans.add(TextSpan(text: text.substring(lastEnd, start)));
      // 提取电话号码并处理
      final phoneNumber = text.substring(start, end);
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final bool isValid =
          cleanedNumber.length >= 10 && cleanedNumber.length <= 15;
      textSpans.add(
        TextSpan(
          text: cleanedNumber,
          style: TextStyle(
            color: numberColor != null && isValid ? numberColor : null,
            decoration: isValid ? TextDecoration.underline : null,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              // 清理号码中的非数字和+号字符
              if (isValid) this.onTap?.call(cleanedNumber);
            },
        ),
      );
      lastEnd = end;
    }
    // 添加剩余的普通文本
    if (lastEnd < text.length)
      textSpans.add(TextSpan(text: text.substring(lastEnd)));
    return RichText(
      text: TextSpan(
        style: this.style ?? DefaultTextStyle.of(context).style,
        children: textSpans,
      ),
    );
  }
}
