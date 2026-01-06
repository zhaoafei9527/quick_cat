// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../r.dart';

/// 获取统一通用的appbar
PreferredSizeWidget getCommonAppBar(String title,
    {VoidCallback? onBack,
    bool centerTitle = true,
    Widget? leading,
    Color? bgColor,
    Color? titleColor,
    List<Widget>? actions,
    bool hideBackTitle = false,
    bool hideBack = false}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return AppBar(
      centerTitle: centerTitle,
      backgroundColor: bgColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      titleSpacing: .0,
      title: Stack(alignment: Alignment.center, children: [
        // hideBackTitle
        //     ? Container()
        //     : Row(children: [
        //         Text('BACK TO PAGE',
        //             style: TextStyle(
        //                 fontSize: AppFontSize.fontSize8, letterSpacing: 1))
        //       ]),
        Container(
            constraints: BoxConstraints(maxWidth: Dimens.pt400),
            child: Text(title,
                style: TextStyle(
                    fontSize: Dimens.pt34,
                    color: titleColor ?? Colors.white,
                    fontWeight: FontWeight.w500))),
      ]),
      leading: leading ??
          (hideBack
              ? Container()
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(Dimens.pt15),
                      margin: EdgeInsets.only(left: Dimens.pt0),
                      child: Image.asset(R.assetsImgNavBack,
                          width: Dimens.pt40,
                          height: Dimens.pt40,
                          color: titleColor ?? Colors.white,
                          fit: BoxFit.fill)),
                  onTap: () {
                    if (onBack == null) {
                      Get.back();
                    } else {
                      onBack.call();
                    }
                  })),
      actions: actions);
}

/// 透明的appbar
Widget transparentAppbar(String title,
    {VoidCallback? onBack,
    List<Widget>? action,
    bool isShowIconBg = false,
    Color? titleColor,
    Color? backBgColor,
    Color? backColor}) {
  return Container(
      width: screen.screenWidth,
      height: kToolbarHeight + screen.paddingTop,
      padding: EdgeInsets.only(
          right: Dimens.pt10, top: screen.paddingTop, left: Dimens.pt10),
      child: Stack(alignment: Alignment.center, children: <Widget>[
        Positioned(
            left: 0,
            child: IconButton(
                onPressed: onBack ??
                    () {
                      Get.back();
                    },
                icon: isShowIconBg
                    ? Container(
                        width: Dimens.pt25,
                        height: Dimens.pt25,
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimens.pt7, vertical: Dimens.pt5),
                        decoration: BoxDecoration(
                            color: backBgColor ?? AppColors.mainTextColor79,
                            borderRadius: BorderRadius.circular(Dimens.pt25)),
                        child: Image.asset(R.assetsImgNavBack,
                            width: Dimens.pt30,
                            fit: BoxFit.fill,
                            color: titleColor ?? AppColors.textColorWhite))
                    : Image.asset(R.assetsImgNavBack,
                        width: Dimens.pt30,
                        fit: BoxFit.fill,
                        color: titleColor ?? AppColors.textColorWhite))),
        Text(title,
            style: TextStyle(
                fontSize: Dimens.pt32,
                color: titleColor ?? AppColors.textColorWhite,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none)),
        Positioned(right: 0, child: Row(children: action ?? []))
      ]));
}
