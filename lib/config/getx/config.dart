import 'package:flutter/cupertino.dart'
    show BuildContext, Key, StatelessElement, StatelessWidget, Widget;
import 'package:flutter/foundation.dart' show Key, kDebugMode;
import 'package:get/get.dart'
    show
        Get,
        GetBuilder,
        GetBuilderState,
        GetInstance,
        GetNavigation,
        GetPage,
        GetView,
        GetxController,
        Obx;
import 'package:linyu_mobile/config/getx/global_data.dart' show GlobalData;
import 'package:linyu_mobile/config/getx/global_theme_config.dart'
    show GlobalThemeConfig;
import 'package:linyu_mobile/config/getx/route.dart' show AppRoutes;
import 'package:linyu_mobile/config/getx/sqflite_helper.dart';
import 'package:linyu_mobile/config/network/web_socket.dart';
import 'package:shared_preferences/shared_preferences.dart';

//路由配置
List<GetPage> get pageRoute => AppRoutes.routeConfig;

//路由监听
void routingCallback(router) {
  if (kDebugMode) print("enter>>>>>>>>>>>>>>>>${router.current}");
}

/// 通过内置GetBuilder来构建，配合GetView使用
/// 与业务逻辑绑定，通过GetX实现状态管理，这样页面只负责渲染，业务逻辑全部在控制器中实现
abstract class CustomWidget<T extends GetxController> extends StatelessWidget {
  /// 构造函数
  CustomWidget({
    this.key,
  }) : super(key: key);

  /// 当传入key的时候，若更新widget需使用controller.update([key],)
  @override
  final Key? key;

  /// 传入的参数
  final dynamic arguments = Get.arguments;

  /// 控制器的tag
  final String? tag = null;

  /// 获取控制器
  T get controller => GetInstance().find<T>(tag: tag);

  GlobalThemeConfig get theme =>
      GetInstance().find<GlobalThemeConfig>(tag: tag);

  GlobalData get globalData => GetInstance().find<GlobalData>(tag: tag);

  /// 初始化
  void init(BuildContext context) {
    if (kDebugMode) print("init>$runtimeType");
  }

  /// 依赖发生变化
  void didChangeDependencies(BuildContext context) =>
      print("change>$runtimeType");

  /// 更新Widget
  void didUpdateWidget(
    GetBuilder oldWidget,
    GetBuilderState<T> state,
  ) =>
      print("update>$runtimeType");

  /// 构建widget
  Widget buildWidget(BuildContext context);

  /// 关闭
  void close(BuildContext context) => print("close>$runtimeType");

  /// 创建上下文
  @override
  StatelessElement createElement() => StatelessElement(this);

  /// 构建
  @override
  Widget build(BuildContext context) => GetBuilder<T>(
        id: this.key,
        assignId: true,
        initState: (GetBuilderState<T> state) => this.init(context),
        didChangeDependencies: (GetBuilderState<T> state) =>
            this.didChangeDependencies(context),
        didUpdateWidget: this.didUpdateWidget,
        builder: (controller) {
          return this.buildWidget(context);
        },
        dispose: (GetBuilderState<T> state) => this.close(context),
      );
}

/// 视图业务逻辑基类
abstract class Logic extends GetxController {
  //路由参数
  dynamic get arguments => Get.arguments;

  //主题配置
  GlobalThemeConfig get theme =>
      GetInstance().find<GlobalThemeConfig>(tag: null);

  //全局数据
  GlobalData get globalData => GetInstance().find<GlobalData>(tag: null);

  //websocket管理
  WebSocketUtil get wsManager => GetInstance().find<WebSocketUtil>(tag: null);

  //数据存储（本地存储）
  SharedPreferences get sharedPreferences =>
      GetInstance().find<SharedPreferences>(tag: null);

  //数据库管理
  SqfliteHelper get sqfliteHelper => GetInstance().find<SqfliteHelper>();
}

/// 自定义的视图基类
/// 通过内置GetBuilder来构建
/// 与业务逻辑绑定，通过GetX实现状态管理，这样页面只负责渲染，业务逻辑全部在控制器中实现
abstract class CustomView<T extends Logic> extends StatelessWidget {
  /// 构造函数
  /// 当传入key的时候，若更新widget需使用controller.update([key],)
  CustomView({
    super.key,
    this.tag,
  });

  /// 传入的参数
  final dynamic arguments = Get.arguments;

  /// 控制器的tag
  final String? tag;

  /// 获取控制器
  T get controller => GetInstance().find<T>(tag: tag);

  GlobalThemeConfig get theme =>
      GetInstance().find<GlobalThemeConfig>(tag: tag);

  GlobalData get globalData => GetInstance().find<GlobalData>(tag: tag);

  /// 初始化
  void init(BuildContext context) {
    if (kDebugMode) print("init>$runtimeType");
  }

  /// 依赖发生变化
  void didChangeDependencies(BuildContext context) {
    if (kDebugMode) print("change>$runtimeType");
  }

  /// 更新Widget
  void didUpdateWidget(GetBuilder oldWidget, GetBuilderState<T> state,
      {BuildContext? context}) {
    if (kDebugMode) print("update>$runtimeType");
  }

  /// 构建widget
  Widget buildView(BuildContext context);

  /// 关闭
  void close(BuildContext context) {
    if (kDebugMode) print("close>$runtimeType");
  }

  /// 创建上下文
  @override
  StatelessElement createElement() => StatelessElement(this);

  /// 构建
  @override
  Widget build(BuildContext context) => GetBuilder<T>(
        id: super.key,
        // 开启控制器随着view的生命周期一起销毁
        assignId: true,
        key: Key("${context.widget.hashCode}_builder"),
        initState: (GetBuilderState<T> state) => this.init(context),
        didChangeDependencies: (GetBuilderState<T> state) =>
            this.didChangeDependencies(context),
        didUpdateWidget: (GetBuilder oldWidget, GetBuilderState<T> state) =>
            this.didUpdateWidget(oldWidget, state, context: context),
        builder: (_) => this.buildView(context),
        dispose: (GetBuilderState<T> state) => this.close(context),
      );
}

/// 主题配置基类
abstract class StatelessThemeWidget extends StatelessWidget {
  const StatelessThemeWidget({super.key});

  GlobalThemeConfig get theme => GetInstance().find<GlobalThemeConfig>();

  GlobalData get globalData => GetInstance().find<GlobalData>();
}

/// 继承自GetView
/// 适用于局部
abstract class CustomWidgetObx<T extends GetxController> extends GetView<T> {
  const CustomWidgetObx({required Key key}) : super(key: key);

  dynamic get arguments => Get.arguments;

  Widget buildWidget(BuildContext context);

  @override
  Widget build(BuildContext context) => Obx(() => buildWidget(context));
}
