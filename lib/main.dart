import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart'
    show Get, GetMaterialApp, GetNavigation, Inst, SmartManagement, Transition;
import 'package:linyu_mobile/utils/config/getx/controller_binding.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
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

class MyApp extends StatelessWidget {
  final String? initialRoute;
  final Widget? initialPage;

  const MyApp({super.key, this.initialPage, this.initialRoute});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        key: UniqueKey(),
        navigatorKey: Get.key,
        smartManagement: SmartManagement.keepFactory,
        title: '林语',
        //国际化
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
        //全局绑定Controller
        initialBinding: ControllerBinding(),
        enableLog: true,
        //路由配置
        getPages: pageRoute,
        //路由从右侧向左滑入（对GetX有效）
        defaultTransition: Transition.rightToLeft,
        initialRoute: initialRoute,
        //路由监听
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
        // home: initialPage,
      );
}
