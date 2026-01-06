// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/dimens.dart';
import '../themes/app_colors.dart';

/// 基础的部底弹出
Future baseActionSheet(BuildContext context,
    {Widget? child,
    String? uniqueId,
    Color? backgroundColor,
    double? topRadius,
    bool? isScrollControlled,
    EdgeInsets? padding}) {
  return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: isScrollControlled ?? false,
      backgroundColor: Colors.transparent,
      // shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //   topLeft: Radius.circular(Dimens.pt20),
      //   topRight: Radius.circular(Dimens.pt20),
      // )),
      builder: (c) => Container(
          padding: padding ??
              EdgeInsets.only(
                  // left: Dimens.pt10,
                  // right: Dimens.pt10,
                  top: Dimens.pt10,
                  bottom: Dimens.pt10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topRadius ?? Dimens.pt5),
                  topRight: Radius.circular(topRadius ?? Dimens.pt5)),
              color: backgroundColor ?? AppColors.bgColor),
          child: child));
}
