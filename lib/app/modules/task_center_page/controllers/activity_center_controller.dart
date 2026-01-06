// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

// 🌎 Project imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/dialog/common_dialog.dart';
import 'package:acgn_client/app/model/home/user_info_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import '../../../../conf/api_res.dart';
import '../../../model/activity_model.dart';
import '../../../model/home/gold_task_model.dart';

class ActivityCenterController extends GetxController {
  RxBool todayChecked = false.obs;
  RxBool todayReceive = false.obs;
  RxString webViewTitle = "".obs;
  RxString webViewUri = "".obs;
  RxBool webViewLoading = true.obs;
  late InAppWebViewController webViewController;
  RxList<ActivityModel> activityList = <ActivityModel>[].obs;
  late RxList<GoldTaskModel> taskList = <GoldTaskModel>[].obs;
  final FocusNode webViewFocusNode = FocusNode();
  UserInfo userInfo = UserInfo();

  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo = shareKeys.userInfo;
    htmlListener();
    await getActivityCenterNetData();
  }

  htmlListener() {
    if (kIsWeb) {
      html.window.onMessage.listen((event) {
        if (event.data is String) {
          try {
            final data = jsonDecode(event.data);
            if (data != null) {
              if (data['type'] == 'onAppRouteJump' && data['route'] is String) {
                final route = data['route'] as String;
                AppPages.jumpRouter(path: route);
              }
            }
          } catch (e) {
            print('解析消息失败: $e');
          }
        }
      });
    }
  }

  initWebViewPage() async {
    webViewLoading.value = true;
    webViewTitle.value = Get.arguments?['title'] ?? "";
    webViewUri.value = Get.arguments?['uri'] ?? "";
  }

  Future getActivityCenterNetData() async {
    ActivityModel? model = await ApiRes.getActivityList();
    if (model != null) activityList.value = model.list ?? [];
    update();
  }

  Future addJavaScriptHandler() async {
    if (!kIsWeb) {
      await webViewController.evaluateJavascript(source: """
            // 调用 FlutterHandler，并传递参数
            window.web_view.callBack('AppRouteJump', 'Hello from JavaScript').then(function(result) {
              console.log('Flutter 返回的结果:', result);
            });
          """);
    }
  }

  javaScriptAddListener() {
    if (kIsWeb) return;
    webViewController.addJavaScriptHandler(
      handlerName: 'onAppRouteJump',
      callback: (List<dynamic> args) {
        if (args.isNotEmpty) AppPages.jumpRouter(path: args[0]);
        return "Flutter onSuccess";
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'onAppDialog',
      callback: (List<dynamic> args) async {
        if (args.isNotEmpty) {
          Map<String, String> argMap = AppPages.getArgsInPath(args[0]);
          String btnStr = argMap["btnList"] ?? "";
          List<String> btnList = btnStr.split(",");
          String callStr = argMap["btnCall"] ?? "";
          List<String> callList = callStr.split(",");
          List<Function> btnCall = [];
          if (callList.isNotEmpty) {
            for (String path in callList) {
              if (path == "" || path == "back") {
                btnCall.add(() => Get.back());
              } else {
                btnCall.add(() => AppPages.jumpRouter(path: path));
              }
            }
          }

          await showPlayerCommonDialog(Get.context!,
              title: argMap["title"] ?? "",
              content: argMap["content"] ?? "",
              btnList: btnList,
              btnCall: btnCall);
        }
        // webViewController.reload();
        return "Flutter onSuccess";
      },
    );
  }


}
