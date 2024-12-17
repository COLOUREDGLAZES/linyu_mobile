import 'package:dio/dio.dart' show BaseOptions, Dio, InterceptorsWrapper;
// import 'package:flutter/foundation.dart' show kReleaseMode;
// import 'package:pretty_dio_logger/pretty_dio_logger.dart' show PrettyDioLogger;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class Http {
  static final Http _instance = Http._internal();

  factory Http() => _instance;

  late Dio dio;

  Http._internal() {
    // String ip = '114.96.70.115';
    // String ip = '47.99.61.62';
    String ip = '192.168.101.4';
    // String port = '19200';
    String port = '9200';
    dio = Dio(BaseOptions(
      baseUrl: 'http://$ip:$port',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ));
    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 从本地存储获取token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('x-token');
        if (token != null) {
          options.headers['x-token'] = token;
        }
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
