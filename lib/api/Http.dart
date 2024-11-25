import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

late String? baseUrl;

class Http {
  static final Http _instance = Http._internal();

  factory Http({String? url})  {
    _instance.dio.options.baseUrl = url??'http://192.168.101.4:9200';
  return _instance;
  }

  late Dio dio;

  String _baseUrl = 'http://192.168.101.4:9200';

  String get baseUrl => this._baseUrl;

  set baseUrl(String value) {
    this._baseUrl = value;
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

    print("ip地址=================>$baseUrl");

    dio = Dio(BaseOptions(
      // baseUrl: 'http://192.168.1.17:9200',
      // baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ));
    // 添加拦截器
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      // 从本地存储获取token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-token');
      if (token != null) {
        options.headers['x-token'] = token;
      }
      return handler.next(options);
    }, onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        // 处理token过期
      }
      return handler.next(error);
    }));
  }
}
