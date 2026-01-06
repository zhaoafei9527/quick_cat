// 🐦 Flutter imports:
import 'dart:io';

import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/pubspec.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/modules/home/home_index_web/views/home_index_web_view.dart';
import 'package:quick_cat_client/app/modules/home/home_mine_center/views/home_mine_center_view.dart';
import 'package:quick_cat_client/app/modules/home/home_recommend_page/views/home_recommend_page_view.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/floating_ads_manager.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../controllers/home_controller.dart';
import '../home_game_page/views/home_game_page_view.dart';
import '../home_post_page/views/home_post_page_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  Future<void> _exitToDesktop() async {
    if (Platform.isAndroid) {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetX<ThemeManager>(
        builder: (ThemeManager theme) => Scaffold(
            backgroundColor: theme.getColor(ThemeColor.bg),
            body: GetX<HomeController>(builder: (HomeController ctl) {
              FloatingAdsManager.to.ensureFloatingAds(context);
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, a) async {
                  if (didPop) return; // 已被其他路由处理
                  final now = DateTime.now();
                  if (ctl.lastBackTime == null ||
                      now.difference(ctl.lastBackTime!) > ctl.gap) {
                    ctl.lastBackTime = now;
                    await showToast(msg: "3秒内再次按下返回将退出应用");
                    return;
                  }
                  await _exitToDesktop();
                },
                child: Stack(alignment: Alignment.bottomCenter, children: [
                  IndexedStack(index: ctl.tabIndex.value, children: [
                    const HomeRecommendPageView(),
                    const HomeIndexWebView(), // 首页轮播图广告
                    const HomePostPageView(),
                    const HomeGamePageView(),
                    const HomeMineCenterView() // 我的
                  ]),
                  Container(
                      width: screen.screenWidth,
                      height: screen.bottomNavBarH,
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt5),
                      decoration: BoxDecoration(
                          color: theme.getColor(ThemeColor.navBg),
                          border: Border(
                              top: BorderSide(
                                  color: theme.getColor(ThemeColor.divide),
                                  width: 1))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ...List.generate(ctl.bottomList.length, (index) {
                              final model = ctl.bottomList[index];
                              return bottomBarButton(model.title, model.icon,
                                  model.selectIcon, ctl, index, theme);
                            })
                          ])),
                  // BreathingAnimation(),
                  // BreathingAnimation(right: true),
                  if (Pubspec.debug)
                    Positioned(
                        // bottom: screen.bottomNavBarH + Dimens.pt25,
                        left: Dimens.pt25,
                        child: GestureDetector(
                            onTap: () =>
                                ctl.developer.value = !ctl.developer.value,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.pt15,
                                  vertical: Dimens.pt10),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(.1),
                                  borderRadius:
                                      BorderRadius.circular(Dimens.pt12)),
                              child: Text(
                                  "开发者：${ctl.developer.value ? "开" : "关"}",
                                  style: TextStyle(
                                      fontSize: Dimens.pt24,
                                      color: Colors.white)),
                            ))),
                  if (ctl.developer.value && Pubspec.debug) _buildDeveloper(),
                ]),
              );
            })));
  }

  Positioned _buildDeveloper() {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    return Positioned(
        top: screen.paddingTop,
        child: Container(
            width: screen.screenWidth,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(Dimens.pt25),
            decoration: BoxDecoration(
                color: AppColors.primaryRaised.withOpacity(.5),
                borderRadius: BorderRadius.circular(Dimens.pt12)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("开发者工具: 版本${Pubspec.versionFull}",
                  style: TextStyle(fontSize: Dimens.pt24, color: Colors.black)),
              Text("用户ID: ${shareKeys.userInfo.id}",
                  style: TextStyle(fontSize: Dimens.pt24, color: Colors.black)),
              FutureBuilder(
                  future: AppUtils.getDeviceId(),
                  builder: (context, snapshot) {
                    return Text("设备ID: ${snapshot.data}",
                        style: TextStyle(
                            fontSize: Dimens.pt24, color: Colors.black));
                  }),
              Text("当前线路:${shareKeys.baseUrl}",
                  style: TextStyle(fontSize: Dimens.pt24, color: Colors.black)),
              Text("日志路径:${log.logPath}",
                  style: TextStyle(fontSize: Dimens.pt24, color: Colors.black)),
            ])));
  }

  Widget bottomBarButton(text, icon, selectIcon, ctl, index, theme) {
    int tabIndex = Get.find<HomeController>().tabIndex.value;
    Color color = tabIndex == index
        ? Colors.white
        : Color(0xFF696A73);
    String showIcon = tabIndex == index ? selectIcon : icon;
    return Flexible(
        fit: FlexFit.tight,
        child: GestureDetector(
            onTap: () => ctl.changeTabIndex(index),
            child: Container(
                color: Colors.transparent,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(showIcon,
                          width: tabIndex == index ? Dimens.pt80 : Dimens.pt40),

                      SizedBox(height: Dimens.pt15),
                      Text(text,
                          style: TextStyle(
                              fontSize: Dimens.pt22,
                              fontWeight: FontWeight.w500,
                              color: color))
                    ]))));
  }
}
