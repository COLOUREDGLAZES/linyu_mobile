import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_instance/src/get_instance.dart';
import 'package:linyu_mobile/utils/config/getx/global_data.dart';
import 'package:linyu_mobile/utils/linyu_msg.dart';
import 'package:linyu_mobile/utils/notification.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketUtil {
  static WebSocketUtil? _instance;
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _lockReconnect = false;
  bool _isConnected = false;
  final int _reconnectCountMax = 200;
  int _reconnectCount = 0;

  final GlobalData _globalData = GetInstance().find<GlobalData>();

  // 事件总线，用于消息分发
  static final eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get eventStream => eventController.stream;

  WebSocketUtil._internal();

  factory WebSocketUtil() {
    _instance ??= WebSocketUtil._internal();
    return _instance!;
  }

  Future<void> connect() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('x-token');
    // if (token == null || _isConnected) return;
    String? token = _globalData.currentToken;
    if (token == null || _isConnected) return;
    try {
      if (kDebugMode) print('WebSocket connecting...');
      //使用的内网穿透
      String wsIp = '114.96.70.115:19100';
      // String wsIp = '192.168.101.4:9100';
      // String wsIp = '114.96.70.115:9100';
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$wsIp/ws?x-token=$token'),
      );
      _channel!.stream.listen(
        _handleMessage,
        onDone: _handleClose,
        onError: _handleError,
      );
      _isConnected = true;
      _clearTimer();
      _startHeartbeat();
    } catch (e) {
      _handleClose();
    }
  }

  void _handleMessage(dynamic message) {
    if (message == null) return _handleClose();
    try {
      Map<String, dynamic> wsContent = jsonDecode(message);
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
    _isConnected = false;
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

  void dispose() {
    _clearHeartbeat();
    _clearTimer();
    _channel?.sink.close();
    eventController.close();
    _instance = null;
  }

  void sendNotification(dynamic msg) {
    dynamic msgContent = msg['msgContent'];
    String contentStr = LinyuMsgUtil.getMsgContent(msgContent);
    NotificationUtil.showNotification(
      id: 0,
      title: msgContent['formUserName'],
      body: '${msgContent['formUserName']}: $contentStr',
    );
  }
}
