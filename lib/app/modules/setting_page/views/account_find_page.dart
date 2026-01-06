// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:acgn_client/app/dialog/base_actionsheet.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/utils/app_util.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/model/home/user_info_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/screen.dart';
import '../../../../utils/dimens.dart';
import '../../../model/home/services_model.dart';
import '../../../themes/app_colors.dart';
import '../controllers/setting_page_controller.dart';

class AccountFindPage extends GetView<SettingPageController> {
  const AccountFindPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingPageController>(builder: (logic) {
      return Scaffold(
          backgroundColor: AppColors.bgColor,
          appBar: getCommonAppBar("找回账号"),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: Dimens.pt20),
              _buildTip("账号丢失，请使用以下方法找回",
                  fontSize: Dimens.pt28, fontWeight: FontWeight.w600),
              SizedBox(height: Dimens.pt20),
              _buildTip("1.使用您已经保存的账号凭证"),
              _buildTip("2.输入您已经绑定的手机号，接收验证码找回"),
              Row(children: [
                _buildTip("3.联系 "),
                _buildTip("在线客服",
                    fontWeight: FontWeight.w600, color: AppColors.primaryColor)
              ]),
              SizedBox(height: Dimens.pt50),
              _buildTip("请选择以下找回方式",
                  fontSize: Dimens.pt28, fontWeight: FontWeight.w600),
              _buildFindTextItem(
                  icon: R.assetsImgIconFindQr,
                  onTap: () => showFindAccountPanel(),
                  title: "使用账号凭证找回"),
              _buildFindTextItem(
                  icon: R.assetsImgIconFindPhone,
                  onTap: () => Get.toNamed(Routes.BIND_MOBILE_PAGE,
                      arguments: {"type": "find"}),
                  title: "使用手机号找回"),
              _buildFindTextItem(
                  icon: R.assetsImgIconFindCustom,
                  onTap: () => AppUtils.goToCustomServicePage(),
                  title: "联系客服找回"),
            ]),
          ));
    });
  }

  Text _buildTip(String text,
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    return Text(text,
        style: TextStyle(
            fontSize: fontSize ?? Dimens.pt26,
            fontWeight: fontWeight ?? FontWeight.w400,
            color: color ?? Colors.white));
  }

  Widget _buildFindTextItem(
      {String? icon, String? title, VoidCallback? onTap}) {
    return GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap?.call(),
        child: Container(
            height: Dimens.pt120,
            margin: EdgeInsets.only(top: Dimens.pt25),
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt40),
            decoration: BoxDecoration(
                color: Color(0xFF222433),
                borderRadius: BorderRadius.circular(Dimens.pt8)),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Image.asset(icon ?? "", width: Dimens.pt64),
              SizedBox(width: Dimens.pt25),
              Text(title ?? "",
                  style: TextStyle(fontSize: Dimens.pt30, color: Colors.white)),
              Spacer(),
              Icon(Icons.arrow_forward_ios,
                  size: Dimens.pt32, color: Colors.white)
            ])));
  }

  showFindAccountPanel() {
    ThemeManager theme = Get.find<ThemeManager>();
    SettingPageController logic = Get.find<SettingPageController>();
    return baseActionSheet(Get.context!,
        backgroundColor: Colors.white,
        topRadius: Dimens.pt20,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.toNamed(Routes.SCAN_QR_CODE),
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimens.pt20),
                    child: Text("扫描凭证",
                        style: TextStyle(
                            fontSize: Dimens.pt40,
                            fontWeight: FontWeight.w600,
                            color: Colors.black))),
              ),
              SizedBox(height: Dimens.pt25),
              getHengLine(color: Colors.black, h: Dimens.pt2),
              SizedBox(height: Dimens.pt25),
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => logic.scanQRCodeFromImage(),
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: Dimens.pt20),
                      child: Text("上传凭证",
                          style: TextStyle(
                              fontSize: Dimens.pt36,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)))),
              SizedBox(height: screen.paddingBottom)
            ]));
    // return Obx(
    //   () => Positioned(
    //       left: Dimens.pt25,
    //       top: logic.position.value.dy - Dimens.pt45,
    //       child: AnimatedOpacity(
    //           duration: Durations.short4,
    //           opacity: logic.openFindAccountPanel.value ? 1 : 0,
    //           child: Container(
    //               width: Dimens.pt385,
    //               padding: EdgeInsets.all(Dimens.pt25),
    //               decoration:
    //                   BoxDecoration(color: theme.getColor(ThemeColor.primary)),
    //               child: Column(children: [
    //                 GestureDetector(
    //                   behavior: HitTestBehavior.opaque,
    //                   onTap: () => Get.toNamed(Routes.SCAN_QR_CODE),
    //                   child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text("拍照",
    //                             style: TextStyle(
    //                                 fontSize: Dimens.pt25,
    //                                 color: Colors.black)),
    //                         Image.asset(R.assetsImgIconCamera,
    //                             width: Dimens.pt35)
    //                       ]),
    //                 ),
    //                 SizedBox(height: Dimens.pt25),
    //                 getHengLine(
    //                     color: theme.getColor(ThemeColor.primary),
    //                     h: Dimens.pt2),
    //                 SizedBox(height: Dimens.pt25),
    //                 GestureDetector(
    //                   behavior: HitTestBehavior.opaque,
    //                   onTap: () => logic.scanQRCodeFromImage(),
    //                   child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text("照片图库",
    //                             style: TextStyle(
    //                                 fontSize: Dimens.pt25,
    //                                 color: Colors.black)),
    //                         Image.asset(R.assetsImgIconImage,
    //                             width: Dimens.pt35)
    //                       ]),
    //                 )
    //               ])))),
    // );
  }
}
