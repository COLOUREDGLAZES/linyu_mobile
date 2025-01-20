import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/config/getx/global_theme_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';

class CustomVoiceRecordButton extends StatefulWidget {
  final Function(String path, int time)? onFinish;

  const CustomVoiceRecordButton({super.key, this.onFinish});

  @override
  State<CustomVoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<CustomVoiceRecordButton> {
  final AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  bool _isCanceled = false;
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  late OverlayEntry _overlayEntry;
  String? _filePath;
  Timer? _timer;
  int _recordingSeconds = 0;
  List<double> _amplitudes = List.filled(20, 0.0);

  GlobalThemeConfig theme = Get.find<GlobalThemeConfig>();

  Future<void> _startRecording() async {
    // // 请求麦克风权限
    // var status = await Permission.microphone.request();
    // // if (!status.isGranted) {
    // //   CustomFlutterToast.showErrorToast("权限申请失败，请在设置中手动开启麦克风权限");
    // //   return; // 直接返回，避免后续操作
    // // }
    //
    // if (status.isGranted) {
    //   if (kDebugMode) print("麦克风权限已授予");
    // } else if (status.isDenied) {
    //   if (kDebugMode) print("麦克风权限被拒绝");
    // } else if (status.isPermanentlyDenied) {
    //   // 如果权限永久被拒绝，跳转到系统设置页面
    //   CustomFlutterToast.showErrorToast("权限申请失败，请在设置中手动开启麦克风权限");
    //   openAppSettings();
    // }

    // if (await Vibration.hasVibrator() ?? false) Vibration.vibrate(duration: 50);

    try {
      if (!await _record.hasPermission()) {
        CustomFlutterToast.showErrorToast("权限申请失败，请在设置中手动开启麦克风权限");
        return;
      }
      final directory = await getTemporaryDirectory();
      _filePath = '${directory.path}/voice.wav';

      // 开始录音
      await _record.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
        ),
        path: _filePath!,
        // encoder: AudioEncoder.wav,
        // bitRate: 128000,
        // samplingRate: 44100,
      );

      _startTimer();
      _updateAmplitude();
    } catch (e) {
      // 捕捉异常并处理
      if (kDebugMode) print("录音失败: $e");
      CustomFlutterToast.showErrorToast("录音失败: $e");
    }
  }

  // void startRecording() async {
  //   var status = await Permission.microphone.request();
  //   // status.isLimited
  //   // if (!status.isGranted) {
  //   if (!await _record.hasPermission()) {
  //     CustomFlutterToast.showErrorToast("权限申请失败，请在设置中手动开启麦克风权限");
  //   }
  //   if (await Vibration.hasVibrator() ?? false) {
  //     Vibration.vibrate(duration: 50);
  //   }
  //   final directory = await getTemporaryDirectory();
  //   _filePath = '${directory.path}/voice.wav';
  //   if (await _record.hasPermission()) {
  //     await _record.start(
  //       path: _filePath,
  //       encoder: AudioEncoder.wav,
  //       bitRate: 128000,
  //       samplingRate: 44100,
  //     );
  //   }
  //   _startTimer();
  //   _updateAmplitude();
  // }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordingSeconds >= 60) {
        _stopRecording(autoStop: true);
      } else {
        setState(() {
          _recordingSeconds++;
        });
        _overlayEntry.markNeedsBuild();
      }
    });
  }

  Future<void> _updateAmplitude() async {
    while (_isRecording) {
      try {
        final amplitude = await _record.getAmplitude();
        // 将 dB 转换为 0-1 的值，并调整范围
        double normalizedAmplitude = 0.0;
        // 调整 dB 范围
        normalizedAmplitude = (amplitude.current + 50) / 50;
        normalizedAmplitude = normalizedAmplitude.clamp(0.0, 1.0);
        setState(() {
          // 将现有的振幅值向左移动
          for (int i = 0; i < _amplitudes.length - 1; i++) {
            _amplitudes[i] = _amplitudes[i + 1];
          }
          // 在最右端添加新的振幅值
          _amplitudes[_amplitudes.length - 1] = normalizedAmplitude;
        });
        _overlayEntry.markNeedsBuild();
      } catch (e) {
        if (kDebugMode) print(e);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _stopRecording({bool autoStop = false}) async {
    _timer?.cancel();
    final filePath = await _record.stop();
    _overlayEntry.remove();
    if (!_isCanceled && !autoStop && filePath != null) {
      widget.onFinish?.call(filePath, _recordingSeconds);
    } else if (autoStop && filePath != null) {
      widget.onFinish?.call(filePath, _recordingSeconds);
    }
    if (_isCanceled) {
      widget.onFinish?.call('', 0);
    }
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
      _amplitudes = List.filled(20, 0.0);
    });
  }

  void _showRecordDialog(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: 100,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 200,
              height: 160,
              decoration: BoxDecoration(
                color: _isCanceled
                    ? theme.errorColor.withOpacity(0.9)
                    : Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCanceled ? Icons.delete : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(20, (index) {
                        double height =
                            _isRecording ? 5 + (_amplitudes[index] * 10) : 5;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 50),
                            width: 3,
                            height: height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isCanceled ? "松开手指，取消发送" : "上滑取消，松开发送",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${_recordingSeconds}s",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry);
  }

  void _permissionRequest() async {
    // 请求麦克风权限
    if (Platform.isAndroid) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        if (kDebugMode) print("麦克风权限已授予");
      } else if (status.isDenied) {
        if (kDebugMode) print("麦克风权限被拒绝");
      } else if (status.isPermanentlyDenied) {
        // 如果权限永久被拒绝，跳转到系统设置页面
        CustomFlutterToast.showErrorToast("权限申请失败，请在设置中手动开启麦克风权限");
        openAppSettings();
      } else {
        await _record.hasPermission();
      }
    }
  }

  @override
  void initState() {
    _permissionRequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async => _permissionRequest(),
      onLongPressStart: (details) {
        _startRecording();
        setState(() {
          _isRecording = true;
          _isCanceled = false;
          _startPosition = details.globalPosition;
          _currentPosition = _startPosition;
        });
        _showRecordDialog(context);
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _currentPosition = details.globalPosition;
          if (_currentPosition.dy < _startPosition.dy - 50) {
            if (!_isCanceled) {
              _isCanceled = true;
              Vibration.vibrate(duration: 50);
            }
          } else {
            if (_isCanceled) {
              _isCanceled = false;
            }
          }
        });
        _overlayEntry.markNeedsBuild();
      },
      onLongPressEnd: (details) {
        _stopRecording();
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "按住 说话",
            style: TextStyle(
              fontSize: 14,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
