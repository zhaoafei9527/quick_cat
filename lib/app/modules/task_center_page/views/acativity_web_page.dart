// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/utils/screen.dart';
import '../../../../utils/dimens.dart';
import '../controllers/activity_center_controller.dart';

class ActivityWebPageView extends GetView<ActivityCenterController> {
  const ActivityWebPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityCenterController logic = Get.find<ActivityCenterController>();
    logic.initWebViewPage();
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: getCommonAppBar(logic.webViewTitle.value, onBack: () {
          Get.back();
        }),
        body: Stack(children: [
          InAppWebView(
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    transparentBackground: false, // 设置透明背景
                  ),
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  )),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                disableHorizontalScroll: false,
                disableVerticalScroll: false,
                useWideViewPort: true,
                // useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
              ),
              onWebViewCreated: (controller) async {
                logic.webViewController = controller;
                // await logic.addJavaScriptHandler();
                logic.javaScriptAddListener();
              },
              onLoadStart: (InAppWebViewController c, w) {
                // logic.webViewLoading.value = true;
              },
              // focusNode: webViewFocusNode, // 关联 FocusNode 到 WebView
              onLoadStop: (c, w) {
                Future.delayed(Durations.medium2, () {
                  logic.webViewLoading.value = false;
                });
              },
              initialUrlRequest:
                  URLRequest(url: WebUri(logic.webViewUri.value))),
          Obx(() {
            return logic.webViewLoading.value
                ? _buildLoadingWidget()
                : const SizedBox();
          })
        ]));
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: screen.screenWidth,
      height: screen.screenHeight,
      color: AppColors.bgColor,
      child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CupertinoActivityIndicator(color: AppColors.primaryColor),
        SizedBox(height: Dimens.pt12),
        Text("加载中",
            style: TextStyle(fontSize: Dimens.pt22, color: Colors.white))
      ])),
    );
  }
}
