import 'package:dio/dio.dart' show BaseOptions, Dio, InterceptorsWrapper;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

late String? baseUrl;

class Http {
  // factory Http() => _instance;
  factory Http({String? url}) {
    // String ip = '47.99.61.62';
    // String defaultIp = '114.96.70.115';
    String defaultIp = '192.168.101.4';
    // String defaultPort = '19200';
    String defaultPort = '9200';
    _instance._baseUrl = url ?? 'http://$defaultIp:$defaultPort';
    _instance.dio.options.baseUrl = url ?? 'http://$defaultIp:$defaultPort';
    return _instance;
  }

  static final Http _instance = Http._internal();

  String _baseUrl = '';

  String get baseUrl => _baseUrl;

  late Dio dio;

  set baseUrl(String value) {
    _baseUrl = value;
    setBaseUrl(value);
  }

  void setBaseUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("httpUrl", value);
    dio.options.baseUrl = value;
  }

  void _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("httpUrl") != null) {
      _baseUrl = prefs.getString("httpUrl")!;
    }
  }

  Http._internal() {
    _init();
    debugPrint("ip地址=================>$baseUrl");
    // String ip = '47.99.61.62';
    // String ip = '114.96.70.115';
    // String ip = '192.168.101.4';
    // String port = '19200';
    // String port = '9200';
    dio = Dio(BaseOptions(
      // baseUrl: 'http://$ip:$port',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ));
    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 从本地存储获取token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('x-token');
        if (token != null) options.headers['x-token'] = token;
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // 处理token过期
        }
        return handler.next(error);
      },
    ));
    // if (!kReleaseMode)
    //   dio.interceptors.add(PrettyDioLogger(
    //     // requestHeader: true,
    //     // requestBody: true,
    //     // responseHeader: true,
    //     responseBody: true,
    //   ));
  }
}
