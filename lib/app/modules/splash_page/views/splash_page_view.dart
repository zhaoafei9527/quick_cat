// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/pubspec.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../controllers/splash_page_controller.dart';

class SplashPageView extends GetView<SplashPageController> {
  const SplashPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    SplashPageController state = Get.find();
    return Scaffold(
        body: Stack(alignment: Alignment.center, children: [
      Container(
          color: theme.getColor(ThemeColor.bg),
          child: Center(
              child: Image.asset(R.assetsImgSplashPage,
                  width: screen.screenWidth,
                  height: screen.screenHeight,
                  fit: BoxFit.fitHeight))),
      Obx(() {
        var ads = state.adsCover.obs;
        return ads.value.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  AppPages.jumpRouter(path: state.adsUri.value, id: state.adId);
                },
                child: ImageLoader.withP(state.adsCover.value,
                        bgColor: theme.getColor(ThemeColor.bg),
                        fit: BoxFit.fitHeight,
                        width: screen.screenWidth,
                        height: screen.screenHeight)
                    .load(),
              )
            : const SizedBox();
      }),
      Obx(() => !state.chooseErr.value ? buildTimerButton() : const SizedBox()),
      Obx(() =>
          state.chooseLine.value ? buildChooseLineView() : const SizedBox()),
      Obx(() =>
          state.chooseErr.value ? buildChooseLineErrView() : const SizedBox()),
      Positioned(
          bottom: screen.paddingBottom,
          right: Dimens.pt25,
          child: GestureDetector(
            child: Text("当前系统版本：${Pubspec.versionFull}",
                style: TextStyle(
                    fontSize: Dimens.pt24,
                    color: theme.getColor(ThemeColor.textGrey))),
          )),
      Positioned(
          bottom: screen.paddingBottom,
          left: Dimens.pt25,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: Dimens.pt12),
            Obx(() => Text("渠道ID:${state.channel.value}",
                style: TextStyle(
                    fontSize: Dimens.pt16,
                    color: theme.getColor(ThemeColor.bg)))),
            Obx(() => Text("设备ID:${state.deviceId.value}",
                style: TextStyle(
                    fontSize: Dimens.pt16,
                    color: theme.getColor(ThemeColor.bg))))
          ]))
    ]));
  }

  Widget buildTodayClose() {
    ThemeManager theme = Get.find<ThemeManager>();
    return Positioned(
        top: Dimens.pt15 + screen.paddingTop,
        left: Dimens.pt12,
        child: GestureDetector(
          onTap: () {
            bool value = controller.checkTodayNoShow.value;
            controller.checkTodayNoShow.value = !value;
            DateTime now = DateTime.now();
            var month = now.month, day = now.day, time = "";
            if (!value) time = "$month-$day";
            controller.getTodayNoShowTime(setTime: time);
          },
          child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimens.pt10, vertical: Dimens.pt4),
              decoration: BoxDecoration(
                  color: theme.getColor(ThemeColor.bg).withOpacity(.5)),
              child: Row(children: [
                Obx(() {
                  return Icon(
                      !controller.checkTodayNoShow.value
                          ? Icons.check_box_outline_blank
                          : Icons.check_box_rounded,
                      color: Colors.white,
                      size: Dimens.pt20);
                }),
                SizedBox(width: Dimens.pt5),
                Text("今日不再提示",
                    style: TextStyle(
                        fontSize: Dimens.pt26,
                        color: theme.getColor(ThemeColor.primary),
                        fontWeight: FontWeight.bold))
              ])),
        ));
  }

  Widget buildChooseLineErrView() {
    ThemeManager theme = Get.find<ThemeManager>();
    SplashPageController logic = Get.find();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("线路选择失败",
          style: TextStyle(
              fontSize: Dimens.pt34,
              color: theme.getColor(ThemeColor.primary))),
      SizedBox(width: Dimens.pt25),
      GestureDetector(
          onTap: () => logic.startInit(),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: Dimens.pt15, vertical: Dimens.pt8),
            decoration: BoxDecoration(
                color: theme.getColor(ThemeColor.textYellow),
                borderRadius: BorderRadius.circular(Dimens.pt45)),
            child: Text("点击重试",
                style: TextStyle(
                    fontSize: Dimens.pt28,
                    color: theme.getColor(ThemeColor.bg))),
          ))
    ]);
  }

  Widget buildChooseLineView() {
    ThemeManager theme = Get.find<ThemeManager>();
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CupertinoActivityIndicator(
          radius: 18, color: theme.getColor(ThemeColor.primary)),
      SizedBox(height: Dimens.pt25),
      Text("线路检测中...",
          style: TextStyle(
              fontSize: Dimens.pt24,
              color: theme.getColor(ThemeColor.primary))),
    ]);
  }

  Widget buildTimerButton() {
    ThemeManager theme = Get.find<ThemeManager>();
    SplashPageController controller = Get.find();
    return Positioned(
        top: Dimens.pt25 + screen.paddingTop,
        right: Dimens.pt25,
        child: Obx(() {
          var timeValue = controller.countdownTime.obs;
          return GestureDetector(
            onTap: () {
              if (!controller.chooseLine.value &&
                  controller.initOk &&
                  !controller.entered &&
                  timeValue.value < 4) {
                controller.entered = true;
                Get.offAllNamed(Routes.HOME);
              }
            },
            child: Container(
                width: Dimens.pt145,
                height: Dimens.pt65,
                decoration: BoxDecoration(
                    color: timeValue.value < 4
                        ? theme.getColor(ThemeColor.textYellow)
                        : theme.getColor(ThemeColor.textGrey),
                    borderRadius: BorderRadius.circular(Dimens.pt45)),
                child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      if (timeValue.value < 4)
                        Text("跳过",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Dimens.pt28,
                                color: theme.getColor(ThemeColor.bg))),
                      timeValue.value > 0
                          ? Text(" ${timeValue}s",
                              style: TextStyle(
                                  fontSize: Dimens.pt28,
                                  color: theme.getColor(ThemeColor.bg)))
                          : const SizedBox()
                    ]))),
          );
        }));
  }
}
