import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Color,
        Colors,
        DefaultTextStyle,
        RichText,
        ScaffoldMessenger,
        SnackBar,
        StatelessWidget,
        Text,
        TextDecoration,
        TextSpan,
        TextStyle,
        VoidCallback,
        Widget;
import 'package:url_launcher/url_launcher.dart'
    show LaunchMode, canLaunchUrl, launchUrl;

class PhoneNumberDetector extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? numberColor;

  final void Function(String? number)? onTap;

  static final RegExp _phoneRegex = RegExp(
    r'(\+?\d{1,3}[-. ]?\(?\d{1,3}\)?[-. ]?\d{1,4}[-. ]?\d{1,4}[-. ]?\d{1,9})',
  );

  static final RegExp _urlRegex = RegExp(
    r'(?:(?:https?|ftp):\/\/|www\.)[^\s/$.?#].[^\s]*',
    caseSensitive: false,
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

class StringDetector extends StatelessWidget {
  final String text;
  final void Function(String? url)? onTap;
  final Color? linkColor;
  final Color? phoneColor;
  final TextStyle? style;

  // 合并正则表达式（电话号码 | 网址）
  static final RegExp _combinedRegex = RegExp(
    r'(\+?\d{1,4}[-. ]?\(?\d{1,4}\)?[-. ]?\d{1,4}[-. ]?\d{1,9})' // 电话号码
    r'|' // 或
    r'((?:(?:https?|ftp):\/\/|www\.)[^\s/$.?#].[^\s]*)', // 网址
    caseSensitive: false,
  );

  const StringDetector({
    super.key,
    required this.text,
    this.onTap,
    this.linkColor,
    this.phoneColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> textSpans = [];
    int lastEnd = 0;

    // 遍历所有匹配项
    for (final match in _combinedRegex.allMatches(text)) {
      final start = match.start;
      final end = match.end;

      // 添加普通文本
      if (start > lastEnd) {
        textSpans.add(TextSpan(text: text.substring(lastEnd, start)));
      }

      // 判断匹配类型
      final phone = match.group(1);
      final url = match.group(2);

      if (phone != null) {
        // 处理电话号码
        textSpans.add(
          _buildClickableSpan(
            context,
            phone,
            isUrl: false,
            onTap: () => _launchPhone(phone, context),
          ),
        );
      } else if (url != null) {
        // 处理网址
        textSpans.add(
          _buildClickableSpan(
            context,
            url,
            isUrl: true,
            onTap: () => _launchUrl(url, context),
          ),
        );
      }

      lastEnd = end;
    }

    // 添加剩余文本
    if (lastEnd < text.length) {
      textSpans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: this.style ??
            DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
        children: textSpans,
      ),
    );
  }

  // 构建可点击文本样式
  TextSpan _buildClickableSpan(
    BuildContext context,
    String text, {
    required bool isUrl,
    required VoidCallback onTap,
  }) {
    final String cleaned =
        !isUrl ? text.replaceAll(RegExp(r'[^0-9+]'), '') : '';
    final bool isValid = cleaned.length >= 10 && cleaned.length <= 15;

    final bool isPhone = isUrl ? false : isValid;

    return TextSpan(
      text: text,
      style: TextStyle(
        color: isUrl
            ? linkColor ?? Colors.blue
            : isPhone
                ? phoneColor ?? Colors.green
                : null,
        decoration: isUrl || isValid ? TextDecoration.underline : null,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  // 拨打电话
  Future<void> _launchPhone(String rawNumber, BuildContext context) async {
    final cleanedNumber = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final bool isValid =
        cleanedNumber.length >= 10 && cleanedNumber.length <= 15;
    if (isValid) this.onTap?.call(cleanedNumber);
  }

  // 打开网址
  Future<void> _launchUrl(String rawUrl, BuildContext context) async {
    String formattedUrl = rawUrl;
    // 自动补全协议
    if (!formattedUrl.startsWith(RegExp(r'https?://'))) {
      formattedUrl = 'https://$formattedUrl';
    }
    final uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError('无法打开链接：$formattedUrl', context);
    }
  }

  // 错误提示
  void _showError(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
