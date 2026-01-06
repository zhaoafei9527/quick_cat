// 🐦 Flutter imports:

import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../utils/screen.dart';

/// 自己定义的通用背景
class PageBg extends StatelessWidget {
  final Widget? child;
  final String? bgImage;
  final Color? bgColor;
  final bool? isTransparent;

  const PageBg(
      {super.key,
      @required this.child,
      this.bgImage,
      this.bgColor,
      this.isTransparent});

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: getBgImgView(bgImage ?? "",
            width: screen.screenWidth,
            height: screen.screenHeight,
            isTransparent: isTransparent ?? false,
            child: Container(
                width: screen.screenWidth,
                height: screen.screenHeight,
                decoration: BoxDecoration(color: bgColor ?? Colors.transparent),
                child: child)));
  }

  Widget getBgImgView(String? image,
      {BoxFit fit = BoxFit.fill,
      margin,
      double? width,
      double? height,
      Widget? child,
      double? scale,
      bool isTransparent = false,
      double? radius}) {
    return Stack(children: [
      Container(
          margin: margin,
          child: Image.asset(R.assetsImgPageBg,
              width: width,
              height: height,
              scale: scale,
              fit: fit,
              color: isTransparent ? Colors.transparent : null)),
      SizedBox(width: width, height: height, child: child)
    ]);
  }
}

Widget buildEditPageUtilView(bool isEdit,
    {bool isAllSelect = false,
    bool haveSel = false,
    Function? onToggleAll,
    Function? onDelete}) {
  ThemeManager theme = Get.find<ThemeManager>();
  double editHeight = Dimens.pt100 + screen.paddingBottom;
  return AnimatedPositioned(
      bottom: isEdit ? 0 : -editHeight,
      duration: Durations.medium2,
      child: Container(
          width: screen.screenWidth,
          height: editHeight,
          padding: EdgeInsets.only(bottom: screen.paddingBottom),
          color: theme.getColor(ThemeColor.bg),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: GestureDetector(
                    onTap: () => onToggleAll?.call(),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                              isAllSelect
                                  ? R.assetsImgIconEditChecked
                                  : R.assetsImgIconEditCheckbox,
                              width: Dimens.pt40,
                              height: Dimens.pt40),
                          SizedBox(width: Dimens.pt10),
                          Text(isAllSelect ? "取消全选" : "全选",
                              style: TextStyle(
                                  fontSize: Dimens.pt28,
                                  color: theme.getColor(ThemeColor.primary)))
                        ]))),
            getHengLine(
                w: Dimens.pt1, h: Dimens.pt100, color: Color(0xFF171717)),
            Expanded(
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDelete?.call(),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(R.assetsImgIconDelete,
                              width: Dimens.pt40,
                              height: Dimens.pt40,
                              color: theme.getColor(haveSel
                                  ? ThemeColor.textYellow
                                  : ThemeColor.textGrey)),
                          SizedBox(width: Dimens.pt10),
                          Text("删除",
                              style: TextStyle(
                                  fontSize: Dimens.pt28,
                                  color: theme.getColor(haveSel
                                      ? ThemeColor.textYellow
                                      : ThemeColor.textGrey)))
                        ])))
          ])));
}
