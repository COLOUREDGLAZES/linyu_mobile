import 'dart:io' show Platform;

import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
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
  String? currentUserId = prefs.getString('currentUserId');
  // String? token = prefs.getString('x-token');
  String? token = prefs.getString('x-token_$currentUserId');
  // String? sex = prefs.getString('sex');
  String? sex = prefs.getString('sex_$currentUserId');
  http.baseUrl = prefs.getString("httpUrl");
  websocket.websocketUrl = prefs.getString("websocket_ip");
  runApp(MyApp(
      key: const Key('MyApp'),
      // initialRoute: token != null ? '/?sex=$sex' : '/login'));
      initialRoute:
          currentUserId != null && token != null ? '/?sex=$sex' : '/login'));
}

class MyApp extends StatelessWidget {
  final String? initialRoute;
  final Widget? initialPage;

  const MyApp({super.key, this.initialPage, this.initialRoute});

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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// void main() => runApp(const AccountSwitchApp());
//
// class AccountSwitchApp extends StatelessWidget {
//   const AccountSwitchApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '账号切换',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const AccountSwitchScreen(),
//     );
//   }
// }
//
// class Account {
//   final String id;
//   final String username;
//   final String email;
//   final String avatarUrl;
//   bool isCurrent;
//
//   Account({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.avatarUrl,
//     this.isCurrent = false,
//   });
// }
//
// class AccountSwitchScreen extends StatefulWidget {
//   const AccountSwitchScreen({super.key});
//
//   @override
//   _AccountSwitchScreenState createState() => _AccountSwitchScreenState();
// }
//
// class _AccountSwitchScreenState extends State<AccountSwitchScreen> {
//   List<Account> accounts = [
//     Account(
//       id: '1',
//       username: '张三',
//       email: 'zhangsan@example.com',
//       avatarUrl: 'https://example.com/avatar1.png',
//       isCurrent: true,
//     ),
//     Account(
//       id: '2',
//       username: '李四',
//       email: 'lisi@example.com',
//       avatarUrl: 'https://example.com/avatar2.png',
//     ),
//   ];
//
//   void _switchAccount(Account selectedAccount) {
//     setState(() {
//       for (var account in accounts) {
//         account.isCurrent = account.id == selectedAccount.id;
//       }
//     });
//     // 这里可以添加实际切换账号的逻辑
//   }
//
//   void _addAccount() async {
//     // 模拟添加新账号
//     final newAccount = Account(
//       id: '3',
//       username: '王五',
//       email: 'wangwu@example.com',
//       avatarUrl: 'https://example.com/avatar3.png',
//     );
//
//     setState(() {
//       accounts.add(newAccount);
//     });
//   }
//
//   void _deleteAccount(Account account) async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('确认删除'),
//           content: Text('确定要删除账号 ${account.email} 吗？'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('取消'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   accounts.removeWhere((a) => a.id == account.id);
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('删除', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('账号切换'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: _addAccount,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: accounts.length,
//               itemBuilder: (context, index) {
//                 final account = accounts[index];
//                 return _buildAccountItem(account);
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: OutlinedButton(
//               onPressed: () {
//                 // 退出登录逻辑
//               },
//               style: OutlinedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               child: const Text('退出登录', style: TextStyle(color: Colors.red)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAccountItem(Account account) {
//     return Dismissible(
//       key: Key(account.id),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       onDismissed: (direction) => _deleteAccount(account),
//       confirmDismiss: (direction) async {
//         if (account.isCurrent) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(const SnackBar(content: Text('当前使用账号不能删除')));
//           return false;
//         }
//         return true;
//       },
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: NetworkImage(account.avatarUrl),
//           radius: 20,
//         ),
//         title: Text(account.username),
//         subtitle: Text(account.email),
//         trailing: account.isCurrent
//             ? const Icon(Icons.check_circle, color: Colors.green)
//             : null,
//         onTap: () => _switchAccount(account),
//         tileColor: account.isCurrent ? Colors.blue.withOpacity(0.1) : null,
//       ),
//     );
//   }
// }
