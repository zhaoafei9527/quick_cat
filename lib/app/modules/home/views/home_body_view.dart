// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/dimens.dart';
import '../../../../utils/screen.dart';

Widget buildHomeBodyView(String bgPath,
    {Widget? child, double? bottom, double? paddingTop}) {
  return Stack(alignment: Alignment.center, children: [
    Image.asset(bgPath,
        width: screen.screenWidth,
        height: screen.screenHeight,
        fit: BoxFit.fill),
    Padding(
      padding: EdgeInsets.only(
          bottom: bottom ?? Dimens.pt70, top: paddingTop ?? screen.paddingTop),
      child: child,
    )
  ]);
}
