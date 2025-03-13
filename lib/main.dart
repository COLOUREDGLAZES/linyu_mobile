import 'dart:io' show Platform;

import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show MethodChannel, SystemChrome, SystemUiMode, SystemUiOverlay;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart'
    show Get, GetMaterialApp, GetNavigation, Inst, SmartManagement, Transition;
import 'package:linyu_mobile/utils/config/getx/controller_binding.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:permission_handler/permission_handler.dart'
    show FuturePermissionStatusGetters, Permission, PermissionActions;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linyu_mobile/utils/config/network/http.dart' as http;
import 'package:linyu_mobile/utils/config/network/web_socket.dart' as websocket;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await Get.putAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
      permanent: true);
  String? token = prefs.getString('x-token');
  String? sex = prefs.getString('sex');
  http.baseUrl = prefs.getString("httpUrl");
  websocket.websocketUrl = prefs.getString("websocket_ip");
  runApp(MyApp(
      key: const Key('MyApp'),
      initialRoute: token != null ? '/?sex=$sex' : '/login'));
}

class MyApp extends StatefulWidget {
  final String? initialRoute;
  final Widget? initialPage;

  const MyApp({super.key, this.initialPage, this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _androidPlatform =
      MethodChannel('com.cershy.linyu/android/service');

  static const _iosPlatform = MethodChannel('com.example.app/ios_channel');

  void initPlatformState() async {
    if (Platform.isAndroid) {
      final startService = await _androidPlatform.invokeMethod('startService');
      if (kDebugMode) print('the Service start result is: $startService');
    }
    if (Platform.isIOS) {
      final String result = await _iosPlatform.invokeMethod('getDeviceInfo');

      if (kDebugMode) print('the iOS device info is: $result');
    }
  }

  Future<bool> _requestOverlayPermission() async {
    if (await Permission.systemAlertWindow.request().isGranted) return true;
    return false;
  }

  @override
  void initState() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top]);
      initPlatformState();
      _requestOverlayPermission();
    } catch (e) {
      if (kDebugMode) print('initPlatformState error: $e');
    } finally {
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    Size screenSize = MediaQuery.of(context).size;
    if (kDebugMode)
      print(
          'screenWidth: ${screenSize.width}, screenHeight: ${screenSize.height}');
    return ScreenUtilInit(
      designSize: screenSize, // 直接使用screenSize
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          key: UniqueKey(),
          navigatorKey: Get.key,
          smartManagement: SmartManagement.keepFactory,
          title: '林语',
          // 国际化
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CH'),
            Locale('en', 'US'),
          ],
          locale: const Locale('zh'),
          // 依赖注入
          initialBinding: ControllerBinding(),
          enableLog: true,
          // 路由配置
          getPages: pageRoute,
          // 路由从右侧向左滑入（对GetX有效）
          defaultTransition: Transition.rightToLeft,
          // 路由监听
          routingCallback: routingCallback,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C9BFF),
              surface: const Color(0xFFFFFFFF),
              onSurface: const Color(0xFF1F1F1F),
              primary: const Color(0xFF4C9BFF),
              onPrimary: Colors.white,
            ),
            splashColor: const Color(0x80EAEAEA),
            highlightColor: const Color(0x80EAEAEA),
            useMaterial3: true,
          ),
          home: widget.initialPage,
          initialRoute: widget.initialRoute,
        );
      },
    );
  }

  @override
  void dispose() {
    _androidPlatform.invokeMethod('stopService');
    super.dispose();
  }
}
