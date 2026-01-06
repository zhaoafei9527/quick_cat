// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/model/home/user_info_model.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/text_field.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/screen.dart';
import '../../../../utils/dimens.dart';
import '../../../themes/app_colors.dart';
import '../controllers/setting_page_controller.dart';

class PhoneBindingPage extends GetView<SettingPageController> {
  const PhoneBindingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingPageController>(builder: (logic) {
      logic.cleanSettingPage();
      String type = Get.arguments?['type'] ?? "";
      if (type == "find") logic.isFindPage.value = true;
      UserInfo userInfo = logic.userInfo.value;
      ThemeManager theme = Get.find<ThemeManager>();
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(Get.context!).unfocus(),
          child: Scaffold(
              backgroundColor: theme.getColor(ThemeColor.bg),
              appBar:
                  getCommonAppBar(logic.isFindPage.value ? "手机账号找回" : "绑定手机"),
              body: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt65),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: Dimens.pt12),
                            Row(children: [
                              Container(
                                  width: Dimens.pt122,
                                  height: Dimens.pt86,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white,
                                              width: Dimens.pt1))),
                                  child: Text("+86",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFA9A9A9)))),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.pt8),
                                  child: getHengLine(
                                      w: Dimens.pt1,
                                      h: Dimens.pt29,
                                      color: Colors.white)),
                              Expanded(
                                  child: Container(
                                      height: Dimens.pt86,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.white,
                                                  width: Dimens.pt1))),
                                      child: GetCommonTextField(
                                          focusNode: logic.phoneFocusNode,
                                          controller: logic.phoneField,
                                          maxLength: 15,
                                          hintStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: Dimens.pt28),
                                          inputType: TextInputType.number,
                                          hintText: "请输入您的手机号",
                                          onSubmitted: (String text) => {})))
                            ]),
                            SizedBox(height: Dimens.pt62),
                            Row(children: [
                              Container(
                                  width: Dimens.pt122,
                                  height: Dimens.pt86,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white,
                                              width: Dimens.pt1))),
                                  child: Text("验证码",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFA9A9A9)))),
                              Expanded(
                                  child: Container(
                                      height: Dimens.pt86,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.white,
                                                  width: Dimens.pt1))),
                                      child: Row(children: [
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimens.pt8),
                                            child: getHengLine(
                                                w: Dimens.pt1,
                                                h: Dimens.pt29,
                                                color: Colors.white)),
                                        Expanded(
                                            child: GetCommonTextField(
                                                focusNode: logic.codeFocusNode,
                                                controller: logic.codeField,
                                                maxLength: 6,
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: Dimens.pt28),
                                                inputType: TextInputType.number,
                                                hintText: "请输入您的验证码",
                                                onSubmitted: (String text) =>
                                                    {})),
                                        GestureDetector(
                                            onTap: () {
                                              if (logic.chapterTime.value >=
                                                  60) {
                                                logic.sendCaptchaCode();
                                              }
                                            },
                                            child: Obx(() => Container(
                                                width: Dimens.pt180,
                                                height: Dimens.pt60,
                                                decoration: BoxDecoration(
                                                    color: AppColors.mainRed,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimens.pt60)),
                                                alignment: Alignment.center,
                                                child: Text(
                                                    logic.chapterTime.value >=
                                                            60
                                                        ? "获取验证码"
                                                        : "${logic.chapterTime.value}S",
                                                    style: TextStyle(
                                                        fontSize: Dimens.pt26,
                                                        color: logic.chapterTime
                                                                    .value >=
                                                                60
                                                            ? Colors.white
                                                            : Colors.grey)))))
                                      ])))
                            ]),
                            SizedBox(height: Dimens.pt180),
                            GestureDetector(
                                onTap: () => logic.isFindPage.value
                                    ? logic.loginByPhone()
                                    : logic.bindingPhone(),
                                child: Container(
                                    width: screen.screenWidth,
                                    height: Dimens.pt84,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: AppColors.mainRed,
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt84)),
                                    child: Text(
                                        logic.isFindPage.value ? "确定" : "立即绑定",
                                        style: TextStyle(
                                            fontSize: Dimens.pt32,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white))))
                          ])))));
    });
  }
}
