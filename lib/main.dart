import 'package:ducafe_ui_core/ducafe_ui_core.dart';
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
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(375, 812),
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

// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';
//
// import 'audio_player.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   bool showPlayer = false;
//   String? audioPath;
//
//   @override
//   void initState() {
//     showPlayer = false;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: showPlayer
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 25),
//                   child: AudioPlayer(
//                     source: audioPath!,
//                     onDelete: () {
//                       setState(() => showPlayer = false);
//                     },
//                   ),
//                 )
//               : AudioRecorder(
//                   onStop: (path) {
//                     if (kDebugMode) print('Recorded file path: $path');
//                     setState(() {
//                       audioPath = path;
//                       showPlayer = true;
//                     });
//                   },
//                 ),
//         ),
//       ),
//     );
//   }
// }
//
// class AudioRecorder extends StatefulWidget {
//   final void Function(String path) onStop;
//
//   const AudioRecorder({super.key, required this.onStop});
//
//   @override
//   State<AudioRecorder> createState() => _AudioRecorderState();
// }
//
// class _AudioRecorderState extends State<AudioRecorder> {
//   int _recordDuration = 0;
//   Timer? _timer;
//   final _audioRecorder = Record();
//   StreamSubscription<RecordState>? _recordSub;
//   RecordState _recordState = RecordState.stop;
//   StreamSubscription<Amplitude>? _amplitudeSub;
//   Amplitude? _amplitude;
//
//   @override
//   void initState() {
//     _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
//       setState(() => _recordState = recordState);
//     });
//
//     _amplitudeSub = _audioRecorder
//         .onAmplitudeChanged(const Duration(milliseconds: 300))
//         .listen((amp) => setState(() => _amplitude = amp));
//
//     super.initState();
//   }
//
//   Future<void> _start() async {
//     try {
//       if (await _audioRecorder.hasPermission()) {
//         // We don't do anything with this but printing
//         final isSupported = await _audioRecorder.isEncoderSupported(
//           // AudioEncoder.aacLc,
//           AudioEncoder.wav,
//         );
//         if (kDebugMode) {
//           print('${AudioEncoder.aacLc.name} supported: $isSupported');
//         }
//
//         // final devs = await _audioRecorder.listInputDevices();
//         // final isRecording = await _audioRecorder.isRecording();
//         final directory = await getTemporaryDirectory();
//         final filePath = '${directory.path}/voice.wav';
//         await _audioRecorder.start(
//           path: filePath,
//           encoder: AudioEncoder.wav,
//           bitRate: 128000,
//           samplingRate: 44100,
//         );
//         _recordDuration = 0;
//
//         _startTimer();
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
//
//   Future<void> _stop() async {
//     _timer?.cancel();
//     _recordDuration = 0;
//
//     final path = await _audioRecorder.stop();
//
//     if (path != null) {
//       widget.onStop(path);
//     }
//   }
//
//   Future<void> _pause() async {
//     _timer?.cancel();
//     await _audioRecorder.pause();
//   }
//
//   Future<void> _resume() async {
//     _startTimer();
//     await _audioRecorder.resume();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // GestureDetector(
//             //   // onTapDown: (details) async {
//             //   //   var status = await Permission.microphone.request();
//             //   //   // if (!status.isGranted) {
//             //   //   //   CustomFlutterToast.showErrorToast("权限申请失败，请在设置中手动开启麦克风权限");
//             //   //   //   return; // 直接返回，避免后续操作
//             //   //   // }
//             //   //
//             //   //   if (status.isGranted) {
//             //   //     if (kDebugMode) print("麦克风权限已授予");
//             //   //   } else if (status.isDenied) {
//             //   //     if (kDebugMode) print("麦克风权限被拒绝");
//             //   //   } else if (status.isPermanentlyDenied) {
//             //   //     // 如果权限永久被拒绝，跳转到系统设置页面
//             //   //     CustomFlutterToast.showErrorToast("权限申请失败，请在设置中手动开启麦克风权限");
//             //   //     openAppSettings();
//             //   //   }
//             //   // },
//             //   onTap: () {
//             //     (_recordState != RecordState.stop) ? _stop() : _start();
//             //   },
//             //   // onLongPressStart: (details) {
//             //   //   _start();
//             //   // },
//             //   // onLongPressEnd: (details) {
//             //   //   _stop();
//             //   // },
//             //   child: const Text('按住 说话'),
//             // ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _buildRecordStopControl(),
//                 const SizedBox(width: 20),
//                 _buildPauseResumeControl(),
//                 const SizedBox(width: 20),
//                 _buildText(),
//               ],
//             ),
//             if (_amplitude != null) ...[
//               const SizedBox(height: 40),
//               Text('Current: ${_amplitude?.current ?? 0.0}'),
//               Text('Max: ${_amplitude?.max ?? 0.0}'),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _recordSub?.cancel();
//     _amplitudeSub?.cancel();
//     _audioRecorder.dispose();
//     super.dispose();
//   }
//
//   Widget _buildRecordStopControl() {
//     late Icon icon;
//     late Color color;
//
//     if (_recordState != RecordState.stop) {
//       icon = const Icon(Icons.stop, color: Colors.red, size: 30);
//       color = Colors.red.withOpacity(0.1);
//     } else {
//       final theme = Theme.of(context);
//       icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
//       color = theme.primaryColor.withOpacity(0.1);
//     }
//
//     return ClipOval(
//       child: Material(
//         color: color,
//         child: InkWell(
//           child: SizedBox(width: 56, height: 56, child: icon),
//           onTap: () {
//             (_recordState != RecordState.stop) ? _stop() : _start();
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPauseResumeControl() {
//     if (_recordState == RecordState.stop) {
//       return const SizedBox.shrink();
//     }
//
//     late Icon icon;
//     late Color color;
//
//     if (_recordState == RecordState.record) {
//       icon = const Icon(Icons.pause, color: Colors.red, size: 30);
//       color = Colors.red.withOpacity(0.1);
//     } else {
//       final theme = Theme.of(context);
//       icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
//       color = theme.primaryColor.withOpacity(0.1);
//     }
//
//     return ClipOval(
//       child: Material(
//         color: color,
//         child: InkWell(
//           child: SizedBox(width: 56, height: 56, child: icon),
//           onTap: () {
//             (_recordState == RecordState.pause) ? _resume() : _pause();
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildText() {
//     if (_recordState != RecordState.stop) {
//       return _buildTimer();
//     }
//
//     return const Text("Waiting to record");
//   }
//
//   Widget _buildTimer() {
//     final String minutes = _formatNumber(_recordDuration ~/ 60);
//     final String seconds = _formatNumber(_recordDuration % 60);
//
//     return Text(
//       '$minutes : $seconds',
//       style: const TextStyle(color: Colors.red),
//     );
//   }
//
//   String _formatNumber(int number) {
//     String numberStr = number.toString();
//     if (number < 10) {
//       numberStr = '0$numberStr';
//     }
//
//     return numberStr;
//   }
//
//   void _startTimer() {
//     _timer?.cancel();
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
//       setState(() => _recordDuration++);
//     });
//   }
// }

// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       // home: Scaffold(
//       //   appBar: AppBar(
//       //     title: const Text('长按弹出菜单示例'),
//       //   ),
//       //   body: Center(
//       //     child: GestureDetector(
//       //       onLongPress: () {
//       //         _showPopupMenu(context);
//       //       },
//       //       child: Container(
//       //         padding: const EdgeInsets.all(10.0),
//       //         color: Colors.blue,
//       //         child: const Text(
//       //           '长按我',
//       //           style: TextStyle(color: Colors.white),
//       //         ),
//       //       ),
//       //     ),
//       //   ),
//       // ),
//       home: TestWidget(),
//     );
//   }
//
//   // void _showPopupMenu(BuildContext context) {
//   //   final RenderBox renderBox = context.findRenderObject() as RenderBox;
//   //   final position = renderBox.localToGlobal(Offset.zero);
//   //
//   //   showMenu(
//   //     context: context,
//   //     position: RelativeRect.fromLTRB(
//   //         position.dx,
//   //         position.dy + renderBox.size.height,
//   //         position.dx + renderBox.size.width,
//   //         position.dy + renderBox.size.height + 50),
//   //     items: <PopupMenuEntry>[
//   //       const PopupMenuItem(
//   //         value: 1,
//   //         child: Text('选项1'),
//   //       ),
//   //       const PopupMenuItem(
//   //         value: 2,
//   //         child: Text('选项2'),
//   //       ),
//   //       const PopupMenuItem(
//   //         value: 3,
//   //         child: Text('选项3'),
//   //       ),
//   //     ],
//   //   ).then((value) {
//   //     if (value != null)
//   //       // 根据选择的值执行相应的操作
//   //       debugPrint('选择了选项$value');
//   //   });
//   // }
// }
//
// class TestWidget extends StatelessWidget {
//   const TestWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: const Text('长按弹出菜单示例'),
//         ),
//         body: Center(
//           child: GestureDetector(
//             onLongPress: () {
//               _showPopupMenu(context);
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10.0),
//               color: Colors.blue,
//               child: const Text(
//                 '长按我',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ),
//       );
//   void _showPopupMenu(BuildContext context) {
//     final RenderBox renderBox = context.findRenderObject() as RenderBox;
//     final position = renderBox.localToGlobal(Offset.zero);
//
//     showMenu(
//       context: context,
//       position: RelativeRect.fromLTRB(
//           position.dx,
//           position.dy + renderBox.size.height,
//           position.dx + renderBox.size.width,
//           position.dy + renderBox.size.height + 50),
//       items: <PopupMenuEntry>[
//         const PopupMenuItem(
//           value: 1,
//           child: Text('选项1'),
//         ),
//         const PopupMenuItem(
//           value: 2,
//           child: Text('选项2'),
//         ),
//         const PopupMenuItem(
//           value: 3,
//           child: Text('选项3'),
//         ),
//       ],
//     ).then((value) {
//       if (value != null)
//         // 根据选择的值执行相应的操作
//         debugPrint('选择了选项$value');
//     });
//   }
// }

// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       // home: Scaffold(
//       //   appBar: AppBar(
//       //     title: Text('长按弹出菜单示例'),
//       //   ),
//       //   body: Center(
//       //     child: GestureDetector(
//       //       onLongPress: () {
//       //         _showPopupMenu(context);
//       //       },
//       //       child: Container(
//       //         padding: EdgeInsets.all(10.0),
//       //         color: Colors.blue,
//       //         child: Text(
//       //           '长按我',
//       //           style: TextStyle(color: Colors.white),
//       //         ),
//       //       ),
//       //     ),
//       //   ),
//       // ),
//       home: TestWidget(),
//     );
//   }
// }
//
// class TestWidget extends StatelessWidget {
//   const TestWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: const Text('长按弹出菜单示例'),
//         ),
//         body: Center(
//           child: GestureDetector(
//             onLongPress: () {
//               _showPopupMenu(context);
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10.0),
//               color: Colors.blue,
//               child: const Text(
//                 '长按我',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ),
//       );
//   // void _showPopupMenu(BuildContext context) {
//   //   final RenderBox renderBox = context.findRenderObject() as RenderBox;
//   //   final position =
//   //       renderBox.localToGlobal(renderBox.size.center(Offset.zero));
//   //
//   //   showMenu(
//   //     context: context,
//   //     position: RelativeRect.fromLTRB(
//   //       position.dx - 100, // 调整 X 轴位置以使菜单居中
//   //       position.dy - 50, // 调整 Y 轴位置以使菜单居中
//   //       position.dx + 100, // 调整 X 轴位置以使菜单居中
//   //       position.dy + 50, // 调整 Y 轴位置以使菜单居中
//   //     ),
//   //     items: <PopupMenuEntry>[
//   //       const PopupMenuItem(
//   //         value: 1,
//   //         child: Text('选项1'),
//   //       ),
//   //       const PopupMenuItem(
//   //         value: 2,
//   //         child: Text('选项2'),
//   //       ),
//   //       const PopupMenuItem(
//   //         value: 3,
//   //         child: Text('选项3'),
//   //       ),
//   //     ],
//   //   ).then((value) {
//   //     // 根据选择的值执行相应的操作
//   //     if (value != null) debugPrint('选择了选项$value');
//   //   });
//   // }
//
//   void _showPopupMenu(BuildContext context) {
//     final RenderBox renderBox = context.findRenderObject() as RenderBox;
//     final position =
//         renderBox.localToGlobal(renderBox.size.center(Offset.zero));
//
//     showMenu(
//       context: context,
//       position: RelativeRect.fromLTRB(
//         position.dx - 100, // 调整 X 轴位置以使菜单居中
//         position.dy - 200, // 调整 Y 轴位置以使菜单居中
//         position.dx + 100, // 调整 X 轴位置以使菜单居中
//         position.dy, // 调整 Y 轴位置以使菜单居中
//       ),
//       items: <PopupMenuEntry>[
//         PopupMenuItem(
//           enabled: false,
//           child: _buildPopupMenuGrid(context), // 禁用该项，使其仅用于显示网格
//         ),
//       ],
//     ).then((value) {
//       if (value != null) {
//         // 根据选择的值执行相应的操作
//         print('选择了选项$value');
//       }
//     });
//   }
//
//   Widget _buildPopupMenuGrid(BuildContext context) {
//     return SizedBox(
//       width: 50,
//       height: 36,
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3, // 每行显示的网格数量
//           mainAxisSpacing: 5, // 主轴间距
//           crossAxisSpacing: 5, // 横轴间距
//         ),
//         itemCount: 9, // 网格中的元素数量
//         itemBuilder: (BuildContext context, int index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.of(context).pop(index); // 关闭菜单并返回选择的值
//             },
//             child: Container(
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(color: Colors.grey),
//                 // borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: Text(
//                 '选项${index + 1}',
//                 style: const TextStyle(color: Colors.blue),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('登录示例'),
//         ),
//         body: LoginPage(),
//       ),
//     );
//   }
// }
//
// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//
//   void _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//
//       // 模拟登录过程
//       await Future.delayed(Duration(seconds: 3));
//
//       setState(() {
//         _isLoading = false;
//       });
//
//       // 登录成功后的操作
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('登录成功')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: '邮箱'),
//               validator: (value) {
//                 if (value == null || value.isEmpty || !value.contains('@')) {
//                   return '请输入有效的邮箱地址';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: '密码'),
//               obscureText: true,
//               validator: (value) {
//                 if (value == null || value.isEmpty || value.length < 6) {
//                   return '请输入至少6位的密码';
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 20),
//             _isLoading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _login,
//                     child: Text('登录'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('文字附近弹出层'),
//         ),
//         body: Center(
//           child: LongPressPopupText(),
//         ),
//       ),
//     );
//   }
// }
//
// class LongPressPopupText extends StatefulWidget {
//   @override
//   _LongPressPopupTextState createState() => _LongPressPopupTextState();
// }
//
// class _LongPressPopupTextState extends State<LongPressPopupText> {
//   final String textToCopy = '这是一个可以长按并弹出菜单的文字示例';
//   OverlayEntry? _overlayEntry;
//
//   void _showOverlay(BuildContext context, Offset position) {
//     _overlayEntry = OverlayEntry(
//       builder: (context) {
//         return Positioned(
//           left: position.dx,
//           top: position.dy - 50, // 控制弹出层的位置
//           child: Material(
//             color: Colors.transparent,
//             child: GestureDetector(
//               onTap: () {
//                 Clipboard.setData(ClipboardData(text: textToCopy));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('文字已复制到剪贴板')),
//                 );
//                 _removeOverlay();
//               },
//               child: Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.black87,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   '复制',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//
//     Overlay.of(context).insert(_overlayEntry!);
//   }
//
//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPressStart: (details) {
//         _showOverlay(context, details.globalPosition);
//       },
//       // onLongPressEnd: (_) {
//       //   _removeOverlay();
//       // },
//       child: Container(
//         padding: EdgeInsets.all(20),
//         color: Colors.grey[200],
//         child: Text(
//           textToCopy,
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
