// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/pubspec.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/utils/screen.dart';
import '../../../../r.dart';
import '../../../../utils/dimens.dart';
import '../../../themes/app_colors.dart';
import '../../../widget/common_widget.dart';
import '../controllers/about_us_page_controller.dart';

class AboutUsPageView extends GetView<AboutUsPageController> {
  const AboutUsPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AboutUsPageController>(builder: (logic) {
      return Scaffold(
          backgroundColor: AppColors.bgColor,
          appBar: getCommonAppBar("关于91"),
          body: SizedBox(
            width: screen.screenWidth,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt23),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: Dimens.pt12),
                      Text("欢迎加入91免费版",
                          style: TextStyle(
                              fontSize: Dimens.pt16,
                              color: AppColors.textColor1B1B)),
                      SizedBox(height: Dimens.pt12),
                      Image.asset(R.assetsImgLogo,
                          width: Dimens.pt188, height: Dimens.pt188),
                      SizedBox(height: Dimens.pt18),
                      Text("91mf1.com",
                          style: TextStyle(
                              fontSize: Dimens.pt28,
                              color: AppColors.primaryColor)),
                      SizedBox(height: Dimens.pt18),
                      Text("91免费版",
                          style: TextStyle(
                              fontSize: Dimens.pt28, color: Colors.white)),
                      SizedBox(height: Dimens.pt30),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => logic.checkVersion(),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("系统版本",
                                  style: TextStyle(
                                      fontSize: Dimens.pt28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                              Text(Pubspec.versionFull,
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      color: const Color(0xFF8A8785)))
                            ]),
                      ),
                      SizedBox(height: Dimens.pt30),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        getHengLine(
                            h: Dimens.pt2,
                            w: screen.screenWidth - Dimens.pt200,
                            color: Colors.white.withOpacity(.1))
                      ])
                    ])),
          ));
    });
  }

  Widget buildRowsItem(
      {String? title,
      String? value,
      VoidCallback? onTap,
      bool checkValue = false,
      bool haveBorder = true}) {
    return InkWell(
      onTap: onTap,
      child: Container(
          height: Dimens.pt45,
          decoration: BoxDecoration(
              border: haveBorder
                  ? const Border(bottom: BorderSide(color: Colors.white))
                  : null),
          child: Row(children: [
            Text(title ?? "",
                style: TextStyle(
                    fontSize: Dimens.pt14, color: AppColors.textColorA4)),
            const Spacer(),
            if ((value ?? "").isNotEmpty)
              Text(value ?? "",
                  style: TextStyle(
                      fontSize: Dimens.pt12,
                      color: !checkValue
                          ? AppColors.textColorA4
                          : const Color(0xFF9ABBD1))),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textColorA4, size: Dimens.pt15)
          ])),
    );
  }
}
