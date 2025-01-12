import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart'
    show Get, GetMaterialApp, GetNavigation, Inst, SmartManagement, Transition;
// import 'package:linyu_mobile/components/CustomDialog/index.dart';
// import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/config/getx/controller_binding.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linyu_mobile/utils/config/network/http.dart' as http;
import 'package:linyu_mobile/utils/config/network/web_socket.dart' as websocket;

// import 'audio_player.dart';
// import 'components/custom_voice_record_button/index.dart';

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
        home: initialPage,
        // home: CustomVoiceRecordButton(
        //   onFinish: (path, time) {
        //     CustomFlutterToast.showSuccessToast('录音已保存至$path');
        //     if (kDebugMode) print('录音已保存至$path');
        //     CustomDialog.showTipDialog(Get.context!, text: '录音已保存至$path',
        //         onOk: () {
        //       CustomFlutterToast.showSuccessToast('录音已保存至$path');
        //     },
        //         child: Container(
        //           height: 100,
        //           width: 100,
        //           color: Colors.white,
        //           child: AudioPlayer(
        //             source: path,
        //             onDelete: () {
        //               Get.back();
        //             },
        //           ),
        //         ));
        //   },
        // ),
      );
}

// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
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
//
//         await _audioRecorder.start();
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
