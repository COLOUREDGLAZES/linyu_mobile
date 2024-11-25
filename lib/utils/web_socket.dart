import 'dart:async';
import 'dart:convert';
import 'package:get/utils.dart';
import 'package:linyu_mobile/utils/date.dart';
import 'package:linyu_mobile/utils/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

late String? websocketIp;

class WebSocketUtil {
  static WebSocketUtil? _instance;
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _lockReconnect = false;
  bool _isConnected = false;
  String? _token;
  final int _reconnectCountMax = 200;
  int _reconnectCount = 0;

  String _websocketIp = "ws://192.168.101.4:9100";

  String get websocketIp => _websocketIp;

  set websocketIp(String value) {
    _websocketIp = value;
    setWsIp(value);
  }

  void setWsIp(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("websocketIp", value);
  }

  // 事件总线，用于消息分发
  static final _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  factory WebSocketUtil({String? websocketUrl}) {
    _instance ??= WebSocketUtil._internal();
    _instance?._websocketIp = websocketUrl??'ws://192.168.101.4:9100';
    return _instance!;
  }

  WebSocketUtil._internal();

  Future<void> connect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("websocketIp") != null) {
      _websocketIp = prefs.getString("websocketIp")!;
    }
    String? token = prefs.getString('x-token');
    if (token == null) return;
    if (_isConnected || _channel != null) return;
    _isConnected = true;

    try {
      print('WebSocket connecting...');
      // String wsIp = 'ws://249ansm92588.vicp.fun';
      // String wsIp = 'ws://192.168.101.4:9100';

      _channel = WebSocketChannel.connect(
        // Uri.parse('$wsIp/ws?x-token=$token'),
        Uri.parse('$_websocketIp/ws?x-token=$token'),
      );

      _channel!.stream.listen(
        _handleMessage,
        onDone: _handleClose,
        onError: _handleError,
        cancelOnError: true,
      );

      _clearTimer();
      _startHeartbeat();
    } catch (e) {
      _handleClose();
    }
  }

  void _handleMessage(dynamic message) {
    if (message == null) {
      _handleClose();
      return;
    }

    Map<String, dynamic> wsContent;
    try {
      wsContent = jsonDecode(message);
    } catch (e) {
      _handleClose();
      return;
    }

    if (wsContent.containsKey('type')) {
      if (wsContent['data'] != null && wsContent['data']['code'] == -1) {
        _handleClose();
      } else {
        switch (wsContent['type']) {
          case 'msg':
            sendNotification(wsContent['content']);
            _eventController.add(
                {'type': 'on-receive-msg', 'content': wsContent['content']});
            break;
          case 'notify':
            _eventController.add(
                {'type': 'on-receive-notify', 'content': wsContent['content']});
            break;
          case 'video':
            // 处理视频消息
            break;
        }
      }
    } else {
      _handleClose();
    }
  }

  void send(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(milliseconds: 9900),
      (_) => send('heart'),
    );
  }

  void _handleClose() {
    _clearHeartbeat();
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
    _reconnect();
  }

  void _handleError(dynamic error) {
    _handleClose();
  }

  void _reconnect() {
    if (_lockReconnect) return;
    _lockReconnect = true;

    _reconnectTimer?.cancel();

    if (_reconnectCount >= _reconnectCountMax) {
      _reconnectCount = 0;
      return;
    }

    _reconnectTimer = Timer(
      const Duration(seconds: 5),
      () {
        connect();
        _reconnectCount++;
        _lockReconnect = false;
      },
    );
  }

  void _clearHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _clearTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void dispose() {
    _clearHeartbeat();
    _clearTimer();
    _channel?.sink.close();
    _eventController.close();
    _instance = null;
  }

  void sendNotification(dynamic msg) {
    dynamic msgContent = msg['msgContent'];
    try {
      String contentStr = '';
      switch (msgContent['type']) {
        case "text":
          contentStr = msgContent['content'];
          break;
        case "file":
          var content = jsonDecode(msgContent['content']);
          contentStr = '[文件] ${content['name']}';
          break;
        case "img":
          contentStr = '[图片]';
          break;
        case "retraction":
          contentStr = '[消息被撤回]';
          break;
        case "voice":
          var content = jsonDecode(msgContent['content']);
          contentStr = '[语音] ${content['time']}';
          break;
        case "call":
          var content = jsonDecode(msgContent['content']);
          contentStr =
              '[通话] ${content['time'] > 0 ? DateUtil.formatTimingTime(content['time']) : "未接通"}';
          break;
        case "system":
          contentStr = '[系统消息]';
          break;
        case "quit":
          contentStr = '[系统消息]';
          break;
      }
      NotificationUtil.showNotification(
        id: 0,
        title: msgContent['formUserName'],
        body: '${msgContent['formUserName']}: $contentStr',
      );
    } catch (e) {
      e.printError();
    }
  }
}
