import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Middleware extends GetMiddleware {
  @override
  int? get priority => 2;

  //重定向，当正在搜索被调用路由的页面时，将调用该函数
  @override
  RouteSettings? redirect(String? route) {
    if (kDebugMode) {
      print('redirect-----');
      print(route);
    }
    // return const RouteSettings(name: '/chat_frame');
    return super.redirect(route);
  }

  //创建任何内容之前调用此函数
  @override
  GetPage? onPageCalled(GetPage? page) {
    if (kDebugMode) {
      print('onPageCalled1----');
    }
    return super.onPageCalled(page);
  }

  //这个函数将在绑定初始化之前被调用。在这里您可以更改此页面的绑定。
  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    if (kDebugMode) {
      print('onBindingsStart1----');
    }
    return super.onBindingsStart(bindings);
    // bindings?.add(LoginBinding());
    // return bindings;
  }

//此函数将在绑定初始化后立即调用。在这里，您可以在创建绑定之后和创建页面小部件之前执行一些操作
  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    if (kDebugMode) {
      print('onPageBuildStart1----');
    }
    return super.onPageBuildStart(page);
  }

  //该函数将在调用 GetPage.page 函数后立即调用，并为您提供函数的结果。并获取将显示的小部件
  @override
  Widget onPageBuilt(Widget page) {
    if (kDebugMode) {
      print('onPageBuilt1 ----');
    }
    return super.onPageBuilt(page);
  }

  //此函数将在处理完页面的所有相关对象（控制器、视图等）后立即调用
  @override
  void onPageDispose() {
    if (kDebugMode) {
      print('onPageDispose1 ----');
    }
    super.onPageDispose();
  }
}
