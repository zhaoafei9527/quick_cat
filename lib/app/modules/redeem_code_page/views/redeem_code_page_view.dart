// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../../../utils/dimens.dart';
import '../../../widget/common_widget.dart';
import '../controllers/redeem_code_page_controller.dart';

class RedeemCodePageView extends GetView<RedeemCodePageController> {
  const RedeemCodePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<RedeemCodePageController>(
        builder: (RedeemCodePageController logic) {
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("兑换码"),
          body: Center(
              child: Padding(
                  padding: EdgeInsets.all(Dimens.pt26),
                  child: Column(children: [
                    Container(
                        height: Dimens.pt34,
                        color: theme.getColor(ThemeColor.bgGrey),
                        child: Padding(
                            padding: EdgeInsets.only(left: Dimens.pt12),
                            child: TextField(
                                controller: controller.redeemCode,
                                cursorWidth: Dimens.pt1,
                                cursorHeight: Dimens.pt14,
                                cursorColor: theme.getColor(ThemeColor.primary),
                                style: TextStyle(
                                  color: theme.getColor(ThemeColor.primary),
                                ),
                                decoration: InputDecoration(
                                  hintText: "请输入兑换码",
                                  hintStyle: TextStyle(
                                      color: theme.getColor(ThemeColor.bgGrey),
                                      fontSize: Dimens.pt12),
                                  labelStyle: TextStyle(
                                    fontSize: Dimens.pt12,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (text) {
                                  if (kDebugMode) {
                                    print("Text input: $text");
                                  }
                                }))),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            margin: EdgeInsets.only(top: Dimens.pt30),
                            child: ElevatedButton(
                                onPressed: () {
                                  controller.submitRedeemCode();
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          const Color(0xFFFEBD2B)),
                                  minimumSize: WidgetStateProperty.all<Size>(
                                      Size(Dimens.pt140, Dimens.pt44)),
                                ),
                                child: Text("确认",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: Dimens.pt14,
                                      color:
                                          theme.getColor(ThemeColor.textBlack),
                                    ))))),
                    Obx(() {
                      return controller.redeemCodeBool.value
                          ? Container(
                              width: Dimens.pt300,
                              height: Dimens.pt44,
                              margin: EdgeInsets.only(top: Dimens.pt100),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: Dimens.pt1,
                                      color: theme.getColor(ThemeColor.red)),
                                  borderRadius:
                                      BorderRadius.circular(Dimens.pt6)),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("无效的兑换码",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: Dimens.pt14,
                                            color: theme
                                                .getColor(ThemeColor.red))),
                                  ]))
                          : const SizedBox();
                    })
                  ]))));
    });
  }
}
