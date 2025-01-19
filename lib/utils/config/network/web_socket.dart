import 'dart:async' show Future, Stream, StreamController, Timer;
import 'dart:convert' show jsonDecode;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart' show GetInstance, GetxController;
import 'package:linyu_mobile/utils/config/getx/global_data.dart';
import 'package:linyu_mobile/utils/linyu_msg.dart';
import 'package:linyu_mobile/utils/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart'
    show WebSocketChannel;

// 全局websocket实例
late String? websocketUrl;

class WebSocketUtil extends GetxController {
  final SharedPreferences _preferences =
      GetInstance().find<SharedPreferences>();
  static WebSocketUtil? _instance;
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _lockReconnect = false;
  bool isConnected = false;
  final int _reconnectCountMax = 200;
  int _reconnectCount = 0;

  String _websocketIp = '';
  String get websocketIp => _websocketIp;
  set websocketIp(String value) {
    _websocketIp = value;
    _preferences.setString('websocket_ip', value);
    isConnected = false;
  }

  final GlobalData _globalData = GetInstance().find<GlobalData>();

  // 事件总线，用于消息分发
  static final eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get eventStream => eventController.stream;

  WebSocketUtil._internal() {
    //使用的内网穿透
    // String wsIp = '114.96.70.115';
    String wsIp = '192.168.101.4';
    // String wsIp = '47.99.61.62';
    String port = '9100';
    // String port = '19100';
    // _websocketIp =
    //     _preferences.getString('websocket_ip') ?? 'ws://$wsIp:$port';
    _websocketIp = websocketUrl ?? 'ws://$wsIp:$port';
  }

  factory WebSocketUtil() {
    _instance ??= WebSocketUtil._internal();
    return _instance!;
  }

  Future<void> connect() async {
    String? token = _globalData.currentToken;
    if (token == null || isConnected) {
      if (isConnected) if (kDebugMode) print('WebSocket has connected');
      return;
    }
    try {
      if (kDebugMode) print('WebSocket connecting...');
      _channel = WebSocketChannel.connect(
        Uri.parse('$_websocketIp/ws?x-token=$token'),
      );
      if (_channel == null) {
        isConnected = false;
        return;
      }
      _channel!.stream.listen(
        _handleMessage,
        onDone: _handleClose,
        onError: _handleError,
      );
      isConnected = true;
      _clearTimer();
      _startHeartbeat();
    } catch (e) {
      _handleClose();
    }
  }

  void _handleMessage(dynamic message) {
    if (kDebugMode) print('WebSocket receive message: $message');
    if (message == null) return _handleClose();
    try {
      Map<String, dynamic> wsContent = jsonDecode(message);
      if (kDebugMode) print('WebSocket receive content: $wsContent');
      if (wsContent.containsKey('type')) {
        if (wsContent['data']?['code'] == -1) return _handleClose();
        String contentType = wsContent['type'];
        if (['msg', 'notify', 'video'].contains(contentType)) {
          eventController.add({
            'type': 'on-receive-$contentType',
            'content': wsContent['content']
          });
          if (contentType == 'msg') sendNotification(wsContent['content']);
        }
      }
    } catch (e) {
      _handleClose();
    }
  }

  void send(String message) => _channel?.sink.add(message);

  void _startHeartbeat() {
    _clearHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(milliseconds: 9900),
      (_) => send('heart'),
    );
  }

  void _handleClose() {
    _clearHeartbeat();
    _channel?.sink.close();
    _channel = null;
    isConnected = false;
    _reconnect();
  }

  void _handleError(dynamic error) => _handleClose();

  void _reconnect() {
    if (_lockReconnect || _reconnectCount >= _reconnectCountMax) return;
    _lockReconnect = true;
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

  void sendNotification(dynamic msg) {
    if (kDebugMode) print('发送通知 $msg');
    dynamic msgContent = msg['msgContent'];
    String contentStr = LinyuMsgUtil.getMsgContent(msgContent);
    NotificationUtil.showNotification(
      id: 0,
      title: msgContent['formUserName'],
      body: '${msgContent['formUserName']}: $contentStr',
    );
  }

  void disconnect() {
    _clearHeartbeat();
    _channel?.sink.close();
    _channel = null;
    isConnected = false;
  }

  @override
  void onReady() {
    if (!isConnected) connect();
    super.onReady();
  }

  @override
  void dispose() {
    _clearHeartbeat();
    _clearTimer();
    _channel?.sink.close();
    eventController.close();
    _instance = null;
    super.dispose();
  }
}
