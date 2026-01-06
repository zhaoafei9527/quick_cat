// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/routes/app_pages.dart';

class CustomMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route != null && route.startsWith("insert://")) {
      print("——————————中间件打印————————————");
      print(route);
      return const RouteSettings(name: Routes.USER_TERMS_PAGE);
    }
    return null;
    //   final uri = Uri.parse(route);
    //   final page = uri.path; // 获取路径部分
    //   final params = uri.queryParameters; // 获取参数部分
    //
    //   debugPrint("=====$page====$params");
    //   return RouteSettings(name: Routes.USER_TERMS_PAGE, arguments: params);
    //
    //   // // 根据解析的内容决定跳转的路由d
    //   // if (page == '/page1') {
    //   // } else if (page == '/page2') {
    //   //   return RouteSettings(name: '/page2', arguments: params);
    //   // } else {
    //   //   return RouteSettings(name: '/notFound');
    //   // }
    // }
    // return null; // 返回 null 表示不拦截
  }
}
