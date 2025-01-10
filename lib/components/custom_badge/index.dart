import 'package:flutter/material.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

class CustomBadge extends StatelessThemeWidget {
  final String text;
  final String type;
  final Color? color;

  const CustomBadge({
    super.key,
    required this.text,
    this.type = 'primary',
    this.color,
  });

  Color _getColor(String type) {
    switch (type) {
      case 'primary':
        return theme.primaryColor;
      case 'gold':
        return const Color(0xFFF3B659);
      default:
        return theme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getColor(type).withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: color ?? _getColor(type), width: 1),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 10, color: color ?? _getColor(type)),
        ),
      ),
    );
  }
}
