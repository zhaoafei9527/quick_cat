// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:acgn_client/app/model/home/user_info_model.dart';
import 'package:acgn_client/app/model/vip_card_list_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:acgn_client/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/utils/app_util.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../plugins_utils/VideoPlayer/fijk_player.dart';
import '../../r.dart';
import '../../utils/dimens.dart';
import '../data/ads_type.dart';
import '../model/home/config_model_model.dart';

//未登陆底部弹出框

Future showPayActionSheet(CardInfoList? cardInfo,
    {Function(int, int, int)? onTap}) {
  ThemeManager theme = Get.find<ThemeManager>();
  String title = cardInfo?.title ?? "";
  int price = (cardInfo?.money ?? 0) ~/ 100;
  int checkIndex = 0;

  return Get.bottomSheet(
      Stack(alignment: Alignment.topRight, children: [
        Container(
            width: screen.screenWidth,
            height: Dimens.pt282 + Dimens.pt600,
            color: theme.getColor(ThemeColor.bg),
            padding: EdgeInsets.symmetric(
                horizontal: Dimens.pt25, vertical: Dimens.pt25),
            child: Column(children: [
              Text("请选择支付方式",
                  style: TextStyle(
                      fontSize: Dimens.pt36,
                      color: theme.getColor(ThemeColor.primary))),
              Container(
                  color: theme.getColor(ThemeColor.textYellow).withOpacity(.5),
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  child: Text("$title$price 元",
                      style: TextStyle(
                          fontSize: Dimens.pt22,
                          color: theme.getColor(ThemeColor.textYellow)))),
              getHengLine(
                  color: Color(0xFF171717),
                  paddingTop: Dimens.pt25,
                  paddingBottom: Dimens.pt40),
              Expanded(child: StatefulBuilder(builder: (context, setState) {
                return ListView.separated(
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => checkIndex = index),
                          child: Row(children: [
                            Image.asset(
                                width: Dimens.pt45,
                                getPayTypeIcon(
                                    cardInfo?.rchgType?[index].rechargeType)),
                            SizedBox(width: Dimens.pt25),
                            Text(cardInfo?.rchgType?[index].typeName ?? "",
                                style: TextStyle(
                                    fontSize: Dimens.pt28,
                                    color: theme.getColor(ThemeColor.primary))),
                            const Spacer(),
                            Image.asset(
                                checkIndex == index
                                    ? R.assetsImgIconRadioCheck
                                    : R.assetsImgIconRadio,
                                width: Dimens.pt42,
                                color: theme.getColor(checkIndex == index
                                    ? ThemeColor.textYellow
                                    : ThemeColor.textGrey),
                                height: Dimens.pt42)
                          ]));
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: Dimens.pt30),
                    itemCount: (cardInfo?.rchgType ?? []).length);
              })),
              Row(children: [
                Text("温馨提示",
                    style: TextStyle(
                        fontSize: Dimens.pt38,
                        color: theme.getColor(ThemeColor.primary)))
              ]),
              SizedBox(height: Dimens.pt20),
              Text(
                  "1.支付前请先绑定手机号,避免重新安装时用户权益遗失！\n"
                  "2.支付前先选择支付方式再点“立即支付”,跳转后请及时付款,超时支付无法到账,需重新发起！\n"
                  "3.若支付时出现任何风险的提示请不要担心,重新支付一次即可,并不会重复付款！\n"
                  "4.付款如遇到其他问题,可咨询在线客服",
                  style: TextStyle(
                      fontSize: Dimens.pt24,
                      color: theme.getColor(ThemeColor.textGrey))),
              SizedBox(height: Dimens.pt30),
              getHengLine(
                  color: Color(0xFF171717),
                  paddingTop: Dimens.pt30,
                  paddingBottom: Dimens.pt20),
              GestureDetector(
                onTap: () {
                  onTap?.call(
                      cardInfo?.money ?? 0,
                      cardInfo?.rchgType?[checkIndex].rechargeType ?? 0,
                      cardInfo?.id ?? 0);
                },
                child: Container(
                    width: screen.screenWidth,
                    height: Dimens.pt80,
                    alignment: Alignment.center,
                    color: theme.getColor(ThemeColor.textYellow),
                    child: Text("立即支付",
                        style: TextStyle(
                            fontSize: Dimens.pt26,
                            fontWeight: FontWeight.w600,
                            color: theme.getColor(ThemeColor.bg)))),
              ),
              SizedBox(height: screen.paddingBottom)
            ])),
        GestureDetector(
            onTap: () => Get.back(),
            child: Container(
                margin: EdgeInsets.only(top: Dimens.pt15),
                child: Image.asset(R.assetsImgIconClose,
                    width: Dimens.pt60,
                    color: theme.getColor(ThemeColor.primary))))
      ]),
      elevation: .5,
      isDismissible: true);
}

String getPayTypeIcon(rechargeType) {
  String icon = R.assetsImgIconPayWechat;
  if (rechargeType == 1) {
    icon = R.assetsImgIconPayWechat;
  } else if (rechargeType == 2) {
    icon = R.assetsImgIconPayAli;
  } else if (rechargeType == 3) {
    icon = R.assetsImgIconPayUnion;
  } else if (rechargeType == 4) {
    icon = R.assetsImgIconPaySzrmb;
  } else if (rechargeType == 5) {
    icon = R.assetsImgIconPayQq;
  } else if (rechargeType == 6) {
    icon = R.assetsImgIconPayUsdt;
  }
  return icon;
}

Future showLoadingDialog({double? size}) {
  return Get.dialog(
      Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          // insetPadding: EdgeInsets.symmetric(horizontal: screen.screenWidth / 2),
          child: Align(
            alignment: Alignment.center,
            child: Container(
                width: Dimens.pt200,
                height: Dimens.pt130,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(Dimens.pt12)),
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      getLoadingWidget(size: size, color: Colors.white),
                      SizedBox(height: Dimens.pt12),
                      Text("加载中...",
                          style: TextStyle(
                              fontSize: Dimens.pt28, color: Colors.white))
                    ]))),
          )),
      barrierColor: Colors.transparent);
}

GlobalKey shareBoundaryKey = GlobalKey();

Future showShareAccountDialog() {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  UserInfo userInfo = shareKeys.userInfo;
  ThemeManager theme = Get.find<ThemeManager>();
  return Get.bottomSheet(
      backgroundColor: Color(0xFF2C2C34),
      Container(
          height: Dimens.pt800,
          padding: EdgeInsets.symmetric(
              horizontal: Dimens.pt30, vertical: Dimens.pt30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimens.pt36),
                  topRight: Radius.circular(Dimens.pt36))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: Dimens.pt30),
            Row(children: [
              Text("分享视频给好友,一起吃瓜",
                  style: TextStyle(fontSize: Dimens.pt28, color: Colors.white)),
              Spacer(),
              GestureDetector(
                  onTap: () => Get.back(),
                  child:
                      Icon(Icons.close, color: Colors.white, size: Dimens.pt36))
            ]),
            SizedBox(height: Dimens.pt60),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                            ClipboardData(text: userInfo.inviteUrl ?? ""))
                        .then((_) {
                      ApiRes.addTaskRecord();
                      showToast(msg: "文本已复制到剪切板");
                    });
                    Get.back();
                  },
                  child: Column(children: [
                    Image.asset(R.assetsImgIconShareLink, width: Dimens.pt120),
                    SizedBox(height: Dimens.pt10),
                    Row(children: [
                      Text("下载地址",
                          style: TextStyle(
                              fontSize: Dimens.pt28, color: Colors.white)),
                      Image.asset(R.assetsImgIconShareVideo, width: Dimens.pt40)
                    ])
                  ]))
            ]),
            SizedBox(height: Dimens.pt60),
            Text("分享APP给好友,每邀请10人,送3天VIP",
                style: TextStyle(fontSize: Dimens.pt28, color: Colors.white)),
            SizedBox(height: Dimens.pt60),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                            ClipboardData(text: userInfo.inviteUrl ?? ""))
                        .then((_) {
                      ApiRes.addTaskRecord();
                      showToast(msg: "文本已复制到剪切板");
                    });
                    Get.back();
                  },
                  child: Column(children: [
                    Image.asset(R.assetsImgIconShareLinkEn,
                        width: Dimens.pt120),
                    SizedBox(height: Dimens.pt10),
                    Text("备用下载链接",
                        style: TextStyle(
                            fontSize: Dimens.pt28, color: Colors.white))
                  ]))
            ])
          ])),
      // Dialog(
      //     elevation: .5,
      //     backgroundColor: Colors.transparent,
      //     // insetPadding: EdgeInsets.symmetric(horizontal: screen.screenWidth / 2),
      //     child: SizedBox(
      //         width: Dimens.pt630,
      //         height: Dimens.pt500 + Dimens.pt230,
      //         child: Column(children: [
      //           RepaintBoundary(
      //               key: shareBoundaryKey,
      //               child: Stack(alignment: Alignment.bottomCenter, children: [
      //                 Image.asset(R.assetsImgBgDialogShare,
      //                     width: Dimens.pt630),
      //                 Container(
      //                     width: Dimens.pt630,
      //                     height: Dimens.pt132,
      //                     alignment: Alignment.bottomCenter,
      //                     decoration: BoxDecoration(
      //                         gradient: LinearGradient(
      //                             begin: Alignment.topCenter,
      //                             end: Alignment.bottomCenter,
      //                             colors: [
      //                           Colors.transparent,
      //                           theme.getColor(ThemeColor.bg).withOpacity(.4)
      //                         ])),
      //                     child: Row(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         children: [
      //                           Text("立即分享好基友！分享成功",
      //                               style: TextStyle(
      //                                   fontSize: Dimens.pt28,
      //                                   color: theme
      //                                       .getColor(ThemeColor.primary))),
      //                           Text("送一天VIP！",
      //                               style: TextStyle(
      //                                   fontSize: Dimens.pt28,
      //                                   color: theme
      //                                       .getColor(ThemeColor.textYellow)))
      //                         ])),
      //                 Obx(() => Positioned(
      //                     bottom: Dimens.pt55,
      //                     child: QrImageView(
      //                         data: userInfo.inviteUrl ?? "",
      //                         version: QrVersions.auto,
      //                         size: Dimens.pt175,
      //                         backgroundColor:
      //                             theme.getColor(ThemeColor.primary),
      //                         padding: const EdgeInsets.all(10))))
      //               ])),
      //           Expanded(
      //               child: Container(
      //                   alignment: Alignment.center,
      //                   color: theme.getColor(ThemeColor.bgGrey),
      //                   child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         buildShareButton(
      //                             label: "复制链接",
      //                             onTap: () {
      //                               Clipboard.setData(ClipboardData(
      //                                       text: userInfo.inviteUrl ?? ""))
      //                                   .then((_) {
      //                                 ApiRes.addTaskRecord();
      //                                 showToast(msg: "文本已复制到剪切板");
      //                               });
      //                               Get.back();
      //                             }),
      //                         SizedBox(width: Dimens.pt30),
      //                         buildShareButton(
      //                             label: "保存图片",
      //                             onTap: () {
      //                               AppUtils.captureAndDownloadImage(
      //                                   shareBoundaryKey);
      //                               Get.back();
      //                             })
      //                       ])))
      //         ]))),
      barrierColor: Colors.transparent);
}

Future showVideoPlayerDialog(BuildContext context, String videoUri,
    {String? title, String? coverImg}) {
  return Get.dialog(
      barrierDismissible: true,
      Dialog(
          elevation: .5,
          backgroundColor: Colors.black.withOpacity(.5),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12.5),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: Dimens.pt60,
                    child: Text(title ?? "缓存视频播放",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: Dimens.pt32,
                            fontWeight: FontWeight.w600,
                            color: Colors.white))),
                Stack(alignment: Alignment.topRight, children: [
                  FIJKVideoPlayer(
                      url: videoUri,
                      simpleModel: false,
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      cover: coverImg),
                  GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                          margin: EdgeInsets.all(Dimens.pt25),
                          color: Colors.black.withOpacity(.5),
                          child: Image.asset(R.assetsImgIconClose,
                              width: Dimens.pt80, color: Colors.white)))
                ])
              ])));
}

Widget buildShareButton({String? label, VoidCallback? onTap}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return GestureDetector(
      onTap: onTap,
      child: Container(
          width: Dimens.pt192,
          height: Dimens.pt80,
          alignment: Alignment.center,
          color: theme.getColor(ThemeColor.textYellow),
          child: Text(label ?? "保存图片",
              style: TextStyle(
                  fontSize: Dimens.pt26,
                  color: theme.getColor(ThemeColor.bg)))));
}

Future showPlayerCommonDialog(BuildContext context,
    {String? title,
    String? content,
    List<InlineSpan>? attachedText,
    List<String>? btnList,
    List<Function?>? btnCall,
    String? image,
    bool? isGameDialog,
    double? imageHeight,
    Color? contentColor,
    bool showBalance = true,
    bool? barrierDismissible,
    int? btnActionIndex = 0}) async {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  Advertise? gameAds = Advertise();
  gameAds = await LocalAdsStore().randomWhere(AdsType.popUpsAds);
  ThemeManager theme = Get.find<ThemeManager>();
  return Get.dialog(
    Transform.rotate(
      angle: (isGameDialog ?? false) ? pi / 2 : 0,
      child: Dialog(
          elevation: .5,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
              width: 245,
              decoration: BoxDecoration(
                  color: Color(0xFF0B0C13),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Spacer(),
                  GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                          margin: EdgeInsets.all(12.5),
                          child: Image.asset(R.assetsImgIconClose,
                              width: 20, color: Colors.white)))
                ]),
                const SizedBox(height: 10),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.5),
                    child: Text.rich(
                        TextSpan(text: content ?? "", children: attachedText),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            color: contentColor ?? Colors.white))),
                const SizedBox(height: 15),
                if ((image ?? "").isNotEmpty) ...[
                  Image.asset(image!, height: imageHeight ?? 30),
                  const SizedBox(height: 15),
                ],
                GestureDetector(
                    onTap: () => Get.toNamed(Routes.VIP_CENTER_PAGE),
                    child: Container(
                        width: 135,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimens.pt35),
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFFFAEABE),
                                  Color(0xFFECC043)
                                ])),
                        child: Text("成为会员",
                            style: TextStyle(
                                fontSize: 15, color: Color(0xFF1D1D27))))),
                // Wrap(
                //     alignment: WrapAlignment.center,
                //     spacing: 40,
                //     children: List.generate(
                //         btnList?.length ?? 0,
                //         (index) => GestureDetector(
                //               onTap: () {
                //                 btnCall != null
                //                     ? btnCall[index]?.call()
                //                     : Get.back(result: index);
                //               },
                //               child: Container(
                //                   constraints: const BoxConstraints(
                //                       minWidth: 163 / 2),
                //                   padding: const EdgeInsets.symmetric(
                //                       horizontal: 27 / 2, vertical: 6),
                //                   decoration: BoxDecoration(
                //                       color: btnActionIndex == index
                //                           ? theme.getColor(
                //                               ThemeColor.textYellow)
                //                           : theme.getColor(
                //                               ThemeColor.textGrey)),
                //                   child: Text(btnList?[index] ?? "",
                //                       textAlign: TextAlign.center,
                //                       style: TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 12))),
                //             ))),
                const SizedBox(height: 15),
                if (showBalance) ...[
                  Container(height: Dimens.pt2, color: Color(0xFF1F1F1F)),
                  const SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(R.assetsImgTextHomeBalance,
                        height: Dimens.pt40),
                    SizedBox(width: Dimens.pt15),
                    Obx(() => Text("¥${shareKeys.userBalance.value}",
                        style: TextStyle(
                            fontSize: Dimens.pt40,
                            color: Color(0xFFFFDB9E),
                            fontWeight: FontWeight.w500)))
                  ]),
                  SizedBox(height: Dimens.pt35)
                ]
              ]))),
    ),
    barrierDismissible: barrierDismissible ?? true, // 点击蒙层可关闭
    barrierColor: theme.getColor(ThemeColor.bg).withOpacity(.5),
  );
}
