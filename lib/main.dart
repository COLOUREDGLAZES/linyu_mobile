import 'dart:io' show Platform;

import 'package:ducafe_ui_core/ducafe_ui_core.dart' show ScreenUtilInit;
import 'package:flutter/foundation.dart' show Key, UniqueKey, kDebugMode;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Color,
        ColorScheme,
        Colors,
        Key,
        Locale,
        MediaQuery,
        Size,
        StatelessWidget,
        ThemeData,
        UniqueKey,
        Widget,
        WidgetsFlutterBinding,
        runApp;
import 'package:flutter/services.dart'
    show DeviceOrientation, MethodChannel, SystemChrome;
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;
import 'package:get/get.dart'
    show Get, GetMaterialApp, GetNavigation, Inst, SmartManagement, Transition;
import 'package:linyu_mobile/config/getx/config.dart'
    show pageRoute, routingCallback;
import 'package:linyu_mobile/config/getx/controller_binding.dart';
import 'package:linyu_mobile/config/network/http.dart' as http;
import 'package:linyu_mobile/config/network/web_socket.dart' as websocket;
import "package:permission_handler/permission_handler.dart"
    show FuturePermissionStatusGetters, Permission, PermissionActions;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await Get.putAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
      permanent: true);
  String? currentUserId = prefs.getString('currentUserId');
  String? token = prefs.getString('x-token_$currentUserId');
  String? sex = prefs.getString('sex_$currentUserId');
  http.baseUrl = prefs.getString("httpUrl");
  websocket.websocketUrl = prefs.getString("websocket_ip");
  final String initialRoute =
      currentUserId != null && token != null ? '/?sex=$sex' : '/login';
  // 锁定竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // 正竖屏
    // DeviceOrientation.portraitDown, // 倒竖屏（可选）
  ]).then((_) =>
      runApp(MyApp(key: const Key('MyApp'), initialRoute: initialRoute)));
  // runApp(MyApp(key: const Key('MyApp'), initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String? initialRoute;
  final Widget? initialPage;

  const MyApp({super.key, this.initialPage, this.initialRoute});

  static const _androidPlatform =
      MethodChannel('com.cershy.linyu/android/service');

  static const _iosPlatform = MethodChannel('com.example.app/ios_channel');

  void _initPlatformState() async {
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
  Widget build(BuildContext context) {
    // _initPlatformState();
    // 获取屏幕尺寸
    Size screenSize = MediaQuery.of(context).size;
    if (kDebugMode) print('the screen size is: $screenSize');
    return ScreenUtilInit(
      designSize: screenSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
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
        home: initialPage,
        initialRoute: initialRoute,
      ),
    );
  }
}
