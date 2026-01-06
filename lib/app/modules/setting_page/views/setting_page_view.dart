// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/r.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/dialog/accont_qr_dialog.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/text_field.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../utils/dimens.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_colors.dart';
import '../../../widget/common_widget.dart';
import '../controllers/setting_page_controller.dart';

class SettingPageView extends GetView<SettingPageController> {
  const SettingPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetBuilder<SettingPageController>(builder: (logic) {
      UserInfo userInfo = logic.userInfo.value;
      String phone =
          (userInfo.mobile ?? "").isNotEmpty ? userInfo.mobile! : "前往绑定";
      String gender = userInfo.gender == 1 ? "男" : "女";
      if (userInfo.gender == 0) gender = "请选择";
      return Stack(alignment: Alignment.topCenter, children: [
        Container(
            width: screen.screenWidth,
            height: screen.screenHeight,
            color: AppColors.bgColor),
        Image.asset(R.assetsImgBgSetting, width: screen.screenWidth),
        Scaffold(
            appBar: getCommonAppBar("设置"),
            backgroundColor: Colors.transparent,
            body: SizedBox(
              width: screen.screenWidth,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: Dimens.pt20),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.SET_USER_AVATAR_PAGE);
                      },
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.pt75),
                          child: Stack(alignment: Alignment.center, children: [
                            ImageLoader.withP(userInfo.avatarUrl,
                                    width: Dimens.pt150, height: Dimens.pt150)
                                .load(),
                            Container(
                                width: Dimens.pt150,
                                height: Dimens.pt150,
                                color: Colors.black.withOpacity(.6)),
                            Image.asset(R.assetsImgIconChangeAvtar,
                                height: Dimens.pt60)
                          ])),
                    ),
                    SizedBox(height: Dimens.pt25),
                    Text("点击更换头像",
                        style: TextStyle(
                            fontSize: Dimens.pt26,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    SizedBox(height: Dimens.pt25),
                    buildRowsItem(
                        title: "昵称   |   ${userInfo.nickName}",
                        value: "${userInfo.nickName?.length}/10",
                        onTap: () => logic.openPanel("openNamePanel")),
                    buildRowsItem(
                        title: "手机号",
                        value: phone,
                        onTap: () {
                          Get.toNamed(Routes.BIND_MOBILE_PAGE);
                        }),
                    buildRowsItem(
                        title: "账号ID",
                        value: (userInfo.id ?? 0).toString(),
                        goBuildWidget: Container(
                            width: Dimens.pt78,
                            height: Dimens.pt40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius:
                                    BorderRadius.circular(Dimens.pt40)),
                            child: Text("复制",
                                style: TextStyle(
                                    fontSize: Dimens.pt20,
                                    color: Colors.white))),
                        onTap: () {
                          logic.copyShareText();
                        }),
                    buildRowsItem(
                        title: "找回账号",
                        value: "极速找回，丢失账号",
                        onTap: () {
                          Get.toNamed(Routes.SET_ACCOUNT_FIND);
                        }),
                    // buildRowsItem(
                    //     title: "邀请码",
                    //     value: "绑定邀请",
                    //     onTap: () =>
                    //         logic.openPanel("openInvitePanel")),
                    // buildRowsItem(
                    //     title: "关于吃瓜",
                    //     value: " ",
                    //     onTap: () {
                    //       Get.toNamed(Routes.ABOUT_US_PAGE);
                    //     }),
                  ]),
            )),
        Obx(() => logic.openMask.value
            ? GestureDetector(
                onTap: () => logic.closePanel(),
                child: Container(
                    width: screen.screenWidth,
                    height: screen.screenHeight,
                    color: Colors.black.withOpacity(.5)))
            : const SizedBox()),
        _buildNameFieldPanel(),
        _buildGenderPanel(),
        _buildInvitePanel(),
      ]);
      // return Scaffold(
      //     backgroundColor: theme.getColor(ThemeColor.bg),
      //     appBar: getCommonAppBar("个人资料"),
      //     body: Stack(children: [
      //       SingleChildScrollView(
      //           child: Padding(
      //               padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
      //               child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     SizedBox(height: Dimens.pt12),
      //                     Container(
      //                         margin: EdgeInsets.only(top: Dimens.pt12),
      //                         padding: EdgeInsets.symmetric(
      //                             horizontal: Dimens.pt12,
      //                             vertical: Dimens.pt5),
      //                         decoration: BoxDecoration(
      //                             borderRadius:
      //                                 BorderRadius.circular(Dimens.pt8)),
      //                         child: Column(children: [
      //                           buildRowsItem(
      //                               title: "头像",
      //                               cover: userInfo.avatarUrl,
      //                               insertPadding: Dimens.pt20,
      //                               onTap: () {
      //                                 Get.toNamed(Routes.SET_USER_AVATAR_PAGE);
      //                               }),
      //                           buildRowsItem(
      //                               title: "昵称",
      //                               value: userInfo.nickName,
      //                               onTap: () =>
      //                                   logic.openPanel("openNamePanel")),
      //                           buildRowsItem(
      //                               title: "性别",
      //                               value: gender,
      //                               onTap: () =>
      //                                   logic.openPanel("openGenderPanel")),
      //                           buildRowsItem(
      //                               title: "手机号",
      //                               value: phone,
      //                               onTap: () {
      //                                 Get.toNamed(Routes.BIND_MOBILE_PAGE);
      //                               }),
      //                           buildRowsItem(
      //                               title: "账号ID",
      //                               value: (userInfo.id ?? 0).toString(),
      //                               goBuildWidget: Container(
      //                                   width: Dimens.pt78,
      //                                   height: Dimens.pt40,
      //                                   alignment: Alignment.center,
      //                                   color: theme
      //                                       .getColor(ThemeColor.textYellow),
      //                                   child: Text("复制",
      //                                       style: TextStyle(
      //                                           fontSize: Dimens.pt20,
      //                                           color: theme
      //                                               .getColor(ThemeColor.bg)))),
      //                               onTap: () {
      //                                 logic.copyShareText();
      //                               }),
      //                           buildRowsItem(
      //                               title: "账号凭证",
      //                               value: " ",
      //                               onTap: () => showAccountQrDialog(context)),
      //                           buildRowsItem(
      //                               title: "找回账号",
      //                               value: "极速找回，丢失账号",
      //                               onTap: () {
      //                                 Get.toNamed(Routes.SET_ACCOUNT_FIND);
      //                               }),
      //                           // buildRowsItem(
      //                           //     title: "邀请码",
      //                           //     value: "绑定邀请",
      //                           //     onTap: () =>
      //                           //         logic.openPanel("openInvitePanel")),
      //                           buildRowsItem(
      //                               title: "关于91漫画",
      //                               value: " ",
      //                               onTap: () {
      //                                 Get.toNamed(Routes.ABOUT_US_PAGE);
      //                               }),
      //                         ]))
      //                   ]))),
      //       Obx(() => logic.openMask.value
      //           ? GestureDetector(
      //               onTap: () => logic.closePanel(),
      //               child: Container(
      //                   width: screen.screenWidth,
      //                   height: screen.screenHeight,
      //                   color: Colors.black.withOpacity(.5)))
      //           : const SizedBox()),
      //       _buildNameFieldPanel(),
      //       _buildGenderPanel(),
      //       _buildInvitePanel(),
      //     ]));
    });
  }

  Widget _buildInvitePanel() {
    ThemeManager theme = Get.find<ThemeManager>();
    SettingPageController logic = Get.find<SettingPageController>();
    return Obx(() => buildSettingPanel(
        title: "绑定邀请码",
        panel: logic.openInvitePanel.value,
        onDone: () => logic.inviteCode(),
        onClose: () => logic.closePanel(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: Dimens.pt80,
              margin: EdgeInsets.only(bottom: Dimens.pt10),
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              decoration: BoxDecoration(
                  color: const Color(0xFF1D1A19),
                  borderRadius: BorderRadius.circular(Dimens.pt12)),
              child: Row(children: [
                Expanded(
                    child: GetCommonTextField(
                        focusNode: logic.inviteFocusNode,
                        controller: logic.inviteField,
                        maxLength: 20,
                        hintText: "请输入邀请码",
                        onSubmitted: (String text) => {}))
              ])),
          SizedBox(height: Dimens.pt10),
          Text("只能绑定一次，且绑定后不能修改，请核对输入是否正确",
              style: TextStyle(
                  fontSize: Dimens.pt22,
                  color: theme.getColor(ThemeColor.primary)))
        ])));
  }

  Widget _buildGenderPanel() {
    SettingPageController logic = Get.find<SettingPageController>();

    return Obx(() => buildSettingPanel(
        title: "设置性别",
        panel: logic.openGenderPanel.value,
        onClose: () => logic.closePanel(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.only(bottom: Dimens.pt10),
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: Row(children: [
                _buildGenderItem(1),
                const Spacer(),
                _buildGenderItem(2)
              ]))
        ])));
  }

  GestureDetector _buildGenderItem(int type) {
    ThemeManager theme = Get.find<ThemeManager>();
    SettingPageController logic = Get.find<SettingPageController>();
    UserInfo userInfo = logic.userInfo.value;
    bool? isMan = userInfo.gender == type;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        logic.changeGenderDown(type);
        logic.closePanel();
      },
      child: Container(
          width: Dimens.pt258,
          height: Dimens.pt80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: isMan
                  ? theme.getColor(ThemeColor.textYellow).withOpacity(.1)
                  : theme.getColor(ThemeColor.bgGrey),
              border: Border.all(
                  color: isMan
                      ? theme.getColor(ThemeColor.textYellow)
                      : Colors.transparent)),
          child: Text(type == 1 ? "男" : "女",
              style: TextStyle(
                  fontSize: Dimens.pt26,
                  color: theme.getColor(ThemeColor.textGrey)))),
    );
  }

  Widget _buildNameFieldPanel() {
    ThemeManager theme = Get.find<ThemeManager>();
    SettingPageController logic = Get.find<SettingPageController>();

    return Obx(
      () => buildSettingPanel(
          title: "设置昵称",
          panel: logic.openNamePanel.value,
          onDone: () => logic.changeNameDown(),
          onClose: () => logic.closePanel(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                height: Dimens.pt80,
                margin: EdgeInsets.only(bottom: Dimens.pt10),
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                color: theme.getColor(ThemeColor.bgGrey),
                child: Row(children: [
                  Expanded(
                    child: GetCommonTextField(
                        focusNode: logic.nameFocusNode,
                        controller: logic.nameField,
                        maxLength: 6,
                        hintText: "请输入昵称",
                        onChanged: (String text) =>
                            logic.textLen.value = text.length,
                        onSubmitted: (String text) => {}),
                  ),
                  Obx(() => Text("${logic.textLen.value}/7",
                      style: TextStyle(
                          fontSize: Dimens.pt26,
                          color: const Color(0xFF8A8785))))
                ])),
            SizedBox(height: Dimens.pt10),
            Text("禁止输入任何违规广告信息,否则永久封禁！",
                style: TextStyle(
                    fontSize: Dimens.pt22, color: AppColors.primaryColor))
          ])),
    );
  }

  Widget buildSettingPanel(
      {String? title,
      Widget? child,
      bool? panel,
      Function()? onDone,
      Function()? onClose}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return AnimatedPositioned(
        bottom: (panel ?? false) ? 0 : -300,
        duration: Durations.medium2,
        child: Container(
            height: Dimens.pt300,
            color: theme.getColor(ThemeColor.bg),
            width: screen.screenWidth,
            padding: EdgeInsets.all(Dimens.pt25),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(
                  onTap: () => onDone?.call(),
                  child: Text((title == '设置性别' ? '' : '完成'),
                      style: TextStyle(
                          fontSize: Dimens.pt26, color: Colors.white)),
                ),
                Text(title ?? "",
                    style:
                        TextStyle(color: Colors.white, fontSize: Dimens.pt30)),
                GestureDetector(
                    onTap: () => onClose?.call(),
                    child: Icon(Icons.close,
                        size: Dimens.pt28, color: Colors.white))
              ]),
              SizedBox(height: Dimens.pt30),
              child ?? const SizedBox()
            ])));
  }

  Widget buildRowsItem(
      {String? title,
      String? value,
      String? cover,
      Function? onTap,
      double? insertPadding,
      Widget? goBuildWidget,
      bool haveBorder = true}) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap?.call(),
        child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: Dimens.pt40, vertical: Dimens.pt30),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(
                  width: Dimens.pt187,
                  child: Text(title ?? "",
                      style: TextStyle(
                          fontSize: Dimens.pt26, color: Colors.white))),
              Expanded(
                  child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if ((value ?? "").isNotEmpty)
                    Text(value ?? "",
                        style: TextStyle(
                            fontSize: Dimens.pt24, color: Colors.white)),
                  if ((cover ?? "").isNotEmpty)
                    ImageLoader.withP(cover,
                            width: Dimens.pt90,
                            radius: Dimens.pt45,
                            height: Dimens.pt90)
                        .load(),
                  SizedBox(width: Dimens.pt15),
                  goBuildWidget ??
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: Dimens.pt25)
                ]),
              ]))
            ])));
  }
}
