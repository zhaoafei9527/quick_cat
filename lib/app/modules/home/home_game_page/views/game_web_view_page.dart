// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/modules/home/home_game_page/controllers/game_web_view_controller.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';

class GameWebViewPage extends GetView<GameWebViewPageController> {
  const GameWebViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GameWebViewPageController logic = Get.find<GameWebViewPageController>();
    return Obx(() => logic.webViewUri.value.isNotEmpty
        ? Stack(children: [
            InAppWebView(
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                  transparentBackground: true, // 设置透明背景
                )),
                onLoadStart: (InAppWebViewController c, w) {
                  logic.webViewLoading.value = true;
                  logic.webViewController = c;
                },
                onLoadStop: (c, w) {
                  Future.delayed(Durations.medium2, () {
                    logic.webViewLoading.value = false;
                  });
                },
                initialUrlRequest:
                    URLRequest(url: WebUri(logic.webViewUri.value))),
            Obx(() => Positioned(
                left: logic.floatingPosition.value.dx,
                top: logic.floatingPosition.value.dy,
                child: Draggable(
                    feedback: _buildSystemUtils(),
                    onDragEnd: (details) {
                      logic.floatingPosition.value = details.offset;
                    },
                    childWhenDragging: Container(),
                    child: _buildSystemUtils()))),
          ])
        : _buildLoadingWidget());
  }

  Widget _buildSystemUtils() {
    GameWebViewPageController logic = Get.find<GameWebViewPageController>();
    double dx = logic.floatingPosition.value.dy;
    double mid = screen.screenHeight / 2;
    return Transform.rotate(
        angle: pi / 2,
        child: PointerInterceptor(
            child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
              SizedBox(width: Dimens.pt280, height: Dimens.pt330),
              Positioned(
                  right: dx > mid ? 0 : null,
                  left: dx < mid ? 0 : null,
                  child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: AnimatedContainer(
                          duration: Durations.short3,
                          width: logic.openGameUtils.value
                              ? Dimens.pt280
                              : Dimens.pt108,
                          height: logic.openGameUtils.value
                              ? Dimens.pt330
                              : Dimens.pt108,
                          child: Stack(alignment: Alignment.center, children: [
                            Positioned(
                                right: dx < mid ? 0 : null,
                                left: dx > mid ? 0 : null,
                                child: _buildUtilsItem(
                                    onTap: () {
                                      logic.webViewController?.reload();
                                    },
                                    icon: R.assetsImgIconGameRefresh,
                                    text: "刷新")),
                            Positioned(
                                top: 0,
                                child: _buildUtilsItem(
                                    icon: R.assetsImgIconGameMoney,
                                    onTap: () =>
                                        Get.toNamed(Routes.VIP_CENTER_PAGE),
                                    text: "充值")),
                            _buildExitBtn(logic)
                          ])))),
              Positioned(
                  right: dx > mid ? 0 : null,
                  left: dx < mid ? 0 : null,
                  child: GestureDetector(
                      onTap: () async {
                        logic.openGameUtils.value = !logic.openGameUtils.value;
                      },
                      child: Container(
                          width: Dimens.pt108,
                          height: Dimens.pt108,
                          decoration: BoxDecoration(
                              color: AppColors.textYellowColor,
                              borderRadius:
                                  BorderRadius.circular(Dimens.pt108)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(R.assetsImgIconGameUtils,
                                    width: Dimens.pt45,
                                    height: Dimens.pt45,
                                    color: Colors.black),
                                SizedBox(height: Dimens.pt5),
                                Text("更多",
                                    style: TextStyle(
                                        fontSize: Dimens.pt22,
                                        color: Colors.black))
                              ]))))
            ])));
  }

  Positioned _buildExitBtn(GameWebViewPageController logic) {
    return Positioned(
        bottom: 0,
        child: _buildUtilsItem(
            icon: R.assetsImgIconGameBack,
            onTap: () => logic.quiteExitGame(),
            text: "退出"));
  }

  Widget _buildUtilsItem(
      {String icon = "", String text = "", VoidCallback? onTap}) {
    return GestureDetector(
        onTap: () => onTap?.call(),
        child: Container(
            width: Dimens.pt80,
            height: Dimens.pt80,
            decoration: BoxDecoration(
                color: AppColors.textYellowColor,
                borderRadius: BorderRadius.circular(Dimens.pt45)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(icon,
                  width: Dimens.pt30, height: Dimens.pt30, color: Colors.black),
              SizedBox(height: Dimens.pt5),
              Text(text,
                  style: TextStyle(fontSize: Dimens.pt18, color: Colors.black))
            ])));
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: screen.screenWidth,
      height: screen.screenHeight,
      color: AppColors.bgColor,
      child: Center(
          child: Transform.rotate(
              angle: pi / 2,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CupertinoActivityIndicator(
                        color: AppColors.primaryColor),
                    SizedBox(height: Dimens.pt12),
                    Text("加载中",
                        style: TextStyle(
                            fontSize: Dimens.pt22, color: Colors.white))
                  ]))),
    );
  }
}
