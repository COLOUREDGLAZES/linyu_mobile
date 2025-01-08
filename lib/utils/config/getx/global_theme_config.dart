import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class GlobalThemeConfig extends GetxController {
  late RxString themeMode = 'blue'.obs;

  void changeThemeMode(String mode) {
    themeMode.value = mode;
    update();
  }

  //主题色
  Color get primaryColor {
    const Map<String, Color> colorMap = {
      'blue': Color(0xFF4C9BFF),
      'pink': Color(0xFFFFA0CF),
    };
    try {
      if (colorMap.containsKey(themeMode.value)) {
        return colorMap[themeMode.value]!;
      } else {
        // 如果没有匹配的主题模式，抛出异常
        throw Exception('未知的主题模式: ${themeMode.value}');
      }
    } catch (e) {
      // 在捕获异常时，返回默认颜色
      return const Color(0xFF4C9BFF);
    }
  }

  Color get boldColor {
    switch (themeMode.value) {
      case 'blue':
        return const Color(0xFF0060D9);
      case 'pink':
        return const Color(0xFFFF53A8);
      default:
        return const Color(0xFF0060D9);
    }
  }

  Color get minorColor {
    switch (themeMode.value) {
      case 'blue':
        return const Color(0xFFDFF4FF);
      case 'pink':
        return const Color(0xFFFBEBFF);
      default:
        return const Color(0xFFDFF4FF);
    }
  }

  Color get qrColor {
    switch (themeMode.value) {
      case 'blue':
        return const Color(0xFFA0D9F6);
      case 'pink':
        return const Color(0xFFF5CFFF);
      default:
        return const Color(0xFFA0D9F6);
    }
  }

  //搜索框背景色
  Color get searchBarColor {
    switch (themeMode.value) {
      case 'blue':
        return const Color(0xFFE3ECFF);
      case 'pink':
        return const Color(0xFFFBEDFF);
      default:
        return const Color(0xFFE3ECFF);
    }
  }

  Color get errorColor {
    return const Color(0xFFFF4C4C);
  }
}