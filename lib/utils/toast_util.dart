// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/r.dart';
import '../app/data/enum.dart';
import 'dimens.dart';
import 'text_util.dart';

/// 显示统一的toast 无context
Future<bool?> showToast(
    {@required String? msg,
    Toast toastLength = Toast.LENGTH_LONG,
    ToastGravity gravity = ToastGravity.CENTER}) {
  if (TextUtil.isEmpty(msg ?? "")) return Future.value(false);
  return Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: const Color(0xFF333333).withOpacity(.9),
      msg: msg ?? "",
      fontSize: Dimens.pt28,
      gravity: gravity,
      webPosition: "center",
      toastLength: toastLength);
}

Future showTypeToast(
    {required String msg, ToastType toastType = ToastType.Error}) {
  ThemeManager theme = Get.find<ThemeManager>();
  Timer? timer;
  int showTimer = 3;
  const oneSec = Duration(seconds: 1);
  if (showTimer >= 3) {
    timer = Timer.periodic(oneSec, (time) {
      showTimer -= 1;
      if (showTimer <= 1) {
        timer?.cancel();
        Get.back();
      }
    });
  }
  return showDialog(
      context: Get.context!,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) {
        return IntrinsicWidth(
            child: Align(
                alignment: Alignment.center,
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimens.pt40, vertical: Dimens.pt20),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.8),
                        borderRadius:
                            BorderRadius.all(Radius.circular(Dimens.pt16))
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Image.asset(
                          toastType == ToastType.SUCCESS
                              ? R.assetsImgIconSuccess
                              : R.assetsImgIconError,
                          color: toastType == ToastType.SUCCESS
                              ? AppColors.mainRed
                              : AppColors.textColorWhite,
                          width: Dimens.pt50,
                          height: Dimens.pt50),
                      SizedBox(height: Dimens.pt15),
                      Text(msg,
                          style: TextStyle(
                              fontSize: Dimens.pt26,
                              color:toastType ==ToastType.SUCCESS
                                  ? Colors.white
                                  : AppColors.textYellowColor))
                    ]))));
      });
}
