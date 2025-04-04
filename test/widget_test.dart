// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ducafe_ui_core/ducafe_ui_core.dart' show ScreenUtilInit;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Color,
        ColorScheme,
        Colors,
        Icons,
        Locale,
        Size,
        StatelessWidget,
        ThemeData,
        UniqueKey,
        Widget;
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart'
    show WidgetTester, expect, find, findsNothing, findsOneWidget, testWidgets;
import 'package:get/get.dart'
    show Get, GetMaterialApp, GetNavigation, SmartManagement, Transition;
import 'package:linyu_mobile/config/getx/config.dart'
    show pageRoute, routingCallback;
import 'package:linyu_mobile/config/getx/controller_binding.dart'
    show ControllerBinding;

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // await tester.pumpWidget(MyApp(initialPage: LoginPage()));
    // await tester.pumpWidget(const MyApp());
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

class MyApp extends StatelessWidget {
  final String? initialRoute;
  final Widget? initialPage;

  const MyApp({super.key, this.initialPage, this.initialRoute});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
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
          home: initialPage,
          initialRoute: initialRoute,
        ),
      );
}
