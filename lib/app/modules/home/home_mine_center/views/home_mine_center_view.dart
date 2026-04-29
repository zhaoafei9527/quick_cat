// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/pubspec.dart';
import 'package:quick_cat_client/app/dialog/accont_qr_dialog.dart';
import 'package:quick_cat_client/app/dialog/announce_dialog.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/dialog/update_dialog.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import 'package:quick_cat_client/app/model/home/video_play_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/cover_banner.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import '../../../../../utils/screen.dart';
import '../../../../data/share_key.dart';
import '../../../../model/home/config_model_model.dart';
import '../controllers/home_mine_center_controller.dart';

class HomeMineCenterView extends GetView<HomeMineCenterController> {
  const HomeMineCenterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeMineCenterController logic = Get.find<HomeMineCenterController>();
    return GetX<ThemeManager>(
        builder: (ThemeManager theme) => Scaffold(
            backgroundColor: theme.getColor(ThemeColor.bg), // 设置背景颜色
            body: Stack(alignment: Alignment.topCenter, children: [
              Image.asset(R.assetsImgBgMineTop,
                  width: screen.screenWidth, fit: BoxFit.cover),
              SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      width: screen.screenWidth,
                      margin:
                          EdgeInsets.only(top: screen.paddingTop + Dimens.pt45),
                      child: Column(children: [
                        _mineTopUtilsBuilder(logic, theme),
                        SizedBox(height: Dimens.pt50),
                        _buildVipButtonView(theme),
                        SizedBox(height: Dimens.pt30),
                        _buildMoreUtilsBtnView(),
                        SizedBox(height: Dimens.pt30),
                        _buildChangeIconView(logic),
                        SizedBox(height: Dimens.pt30),
                        Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: Dimens.pt25),
                            child: Column(children: [
                              CoverBanner(
                                  //广告minSwiperAds
                                  aspectRatio: 700 / 336,
                                  radius: Dimens.pt20,
                                  adsType: AdsType.homeSwiperAds,
                                  onItemClick: (Advertise model) {
                                    AppPages.jumpRouter(
                                        path: model.href, id: model.id);
                                  }),
                              SizedBox(height: Dimens.pt30),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.05),
                                    borderRadius:
                                        BorderRadius.circular(Dimens.pt20)),
                                child: Column(children: [
                                  _buildMineUtilsBtnView(
                                      title: "设置",
                                      color: AppColors.textColorWhite,
                                      onTap: () =>
                                          Get.toNamed(Routes.SETTING_PAGE),
                                      icon: R.assetsImgIconMineSetting),
                                  _buildMineUtilsBtnView(
                                      title: "绑定手机号",
                                      color: AppColors.textColorWhite,
                                      desc: "绑定成功送3元彩金！",
                                      onTap: () => Get.toNamed(
                                          Routes.BIND_MOBILE_PAGE,
                                          arguments: {"type": "find"}),
                                      icon: R.assetsImgIconMinePhone),
                                  _buildMineUtilsBtnView(
                                      onTap: () async {
                                        await M3u8CacheManager().clearCache();
                                        logic.cacheSize.value = 0;
                                        showToast(msg: "缓存已清除");
                                      },
                                      title: "清除缓存",
                                      color: AppColors.textColorWhite,
                                      desc:
                                          "${logic.cacheSize.toStringAsFixed(2)}MB",
                                      icon: R.assetsImgIconMineDownload),
                                  _buildMineUtilsBtnView(
                                      onTap: () => Get.toNamed(
                                          Routes.TICKET_MANAGE_PAGE,
                                          arguments: {"type": 3}),
                                      color: AppColors.textColorWhite,
                                      title: "兑换码",
                                      icon: R.assetsImgIconMineExchange),
                                  _buildMineUtilsBtnView(
                                      title: "检查更新",
                                      color: AppColors.textColorWhite,
                                      desc: "V${Pubspec.versionFull}",
                                      onTap: () async {
                                        ShareKeys shareKeys =
                                            Get.find<ShareKeys>();
                                        VersionBean? version =
                                            shareKeys.version;
                                        if (version != null &&
                                            (version.hasNewVersion ?? false)) {
                                          await showUpdateVersionDialog(
                                              Get.context!,
                                              version: shareKeys.version);
                                        } else {
                                          showToast(msg: "当前已经是最新版本");
                                        }
                                      },
                                      icon: R.assetsImgIconMineCertif),
                                ]),
                              ),

                              // _buildDayTimeChange(theme, logic),
                              SizedBox(
                                  height: screen.bottomNavBarH + Dimens.pt40)
                            ]))
                      ])))
            ])));
  }

  Widget _buildDayTimeChange(
      ThemeManager theme, HomeMineCenterController logic) {
    return Container(
        height: Dimens.pt90,
        width: screen.screenWidth,
        color: theme.getColor(ThemeColor.bgGrey),
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt35),
        child: Row(children: [
          Text("日间模式/夜间模式",
              style: TextStyle(
                  fontSize: Dimens.pt24,
                  color: theme.getColor(ThemeColor.primary))),
          Spacer(),
          Text("点击切换${!logic.dayTimeModel.value ? '日间' : '夜间'}模式",
              style: TextStyle(
                  fontSize: Dimens.pt24,
                  color: theme.getColor(ThemeColor.textGrey))),
          Transform.scale(
              scale: .75,
              child: Switch(
                  activeColor: Color(0xFF26BA46),
                  value: logic.dayTimeModel.value,
                  onChanged: (value) {
                    ThemeManager.to.switchTheme(value ? 1 : 0);
                    logic.dayTimeModel.value = value;
                  }))
        ]));
  }

  Widget _buildMoreUtilsBtnView() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimens.pt35),
      margin: EdgeInsets.symmetric(horizontal: Dimens.pt30),
      decoration: BoxDecoration(
          color: Color(0xFFFFFFFF).withOpacity(.05),
          borderRadius: BorderRadius.circular(Dimens.pt20)),
      child: Row(children: [
        Expanded(
            child: _buildColumnUtilItem(
                title: "我的收藏",
                icon: R.assetsImgIconMineCollect,
                onTap: () => Get.toNamed(Routes.MINE_COLLECT_PAGE))),
        SizedBox(width: Dimens.pt20),
        Expanded(
            child: _buildColumnUtilItem(
                title: "历史记录",
                icon: R.assetsImgIconWatchHistory,
                onTap: () => Get.toNamed(Routes.WATCH_HISTORY_PAGE))),
        Expanded(
            child: _buildColumnUtilItem(
                title: "邀请分享",
                icon: R.assetsImgIconMineShare,
                onTap: () => Get.toNamed(Routes.INVITED_PAGE)))
        // Expanded(
        //     child: _buildColumnUtilItem(
        //         title: "活动",
        //         icon: R.assetsImgIconMineActive,
        //         onTap: () => Get.toNamed(Routes.ACTIVITY_CENTER_PAGE))),
      ]),
    );
  }

  Widget _buildColumnUtilItem(
      {String? title, Color? color, String? icon, Function? onTap}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
        onTap: () => onTap?.call(),
        child: Column(children: [
          Image.asset(icon ?? "",
              width: Dimens.pt50, height: Dimens.pt50, color: color),
          SizedBox(height: Dimens.pt18),
          Text(title ?? "",
              style: TextStyle(
                  fontSize: Dimens.pt24,
                  color: color ?? Colors.white.withOpacity(.7)))
        ]));
  }

  Widget _buildMineUtilsBtnView(
      {String? title,
      String? icon,
      Color? color,
      String? desc,
      Function? onTap}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Container(
          width: screen.screenWidth,
          height: Dimens.pt90,
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: Row(children: [
            Image.asset(icon ?? "",
                width: Dimens.pt38,
                height: Dimens.pt38,
                color: color ?? theme.getColor(ThemeColor.primary)),
            SizedBox(width: Dimens.pt20),
            Text(title ?? "",
                style: TextStyle(
                    fontSize: Dimens.pt24,
                    color: color ?? theme.getColor(ThemeColor.primary))),
            Spacer(),
            Text(desc ?? "",
                style: TextStyle(
                    fontSize: Dimens.pt20,
                    color: color ?? theme.getColor(ThemeColor.textGrey))),
            SizedBox(width: Dimens.pt7),
            Image.asset(R.assetsImgIconArrowRight,
                width: Dimens.pt30, color: Colors.white.withOpacity(.6))
          ])),
      // child: SizedBox(
      //     width: Dimens.pt155,
      //     child: Column(children: [

      //       Text(title ?? "",
      //           style: TextStyle(
      //               fontSize: Dimens.pt24,
      //               color: theme.getColor(ThemeColor.primary)))
      //     ]))
    );
  }

  Widget _buildVipButtonItem(ThemeManager theme,
      {String? icon, String? title, String? subTitle, Function? onTap}) {
    return Flexible(
        flex: 1,
        child: GestureDetector(
          onTap: () => onTap?.call(),
          child: Container(
              height: Dimens.pt162,
              color: theme.getColor(ThemeColor.bgGrey),
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Image.asset(R.assetsImgBtnMineVip,
                        width: Dimens.pt80,
                        color: theme.getColor(ThemeColor.textYellow)),
                    SizedBox(width: Dimens.pt30),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title ?? "",
                              style: TextStyle(
                                  fontSize: Dimens.pt36,
                                  fontWeight: FontWeight.w600,
                                  color: theme.getColor(ThemeColor.primary))),
                          Text(subTitle ?? "",
                              style: TextStyle(
                                  fontSize: Dimens.pt20,
                                  color: theme.getColor(ThemeColor.textGrey))),
                        ])
                  ]))),
        ));
  }

  Widget _buildVipButtonView(ThemeManager theme) {
    HomeMineCenterController logic = Get.find<HomeMineCenterController>();
    UserInfo user = logic.userInfo.value;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    return Container(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        child: Column(children: [
          GestureDetector(
            onTap: () => Get.toNamed(Routes.USER_TERMS_PAGE),
            child: Stack(
              children: [
                Image.asset(R.assetsImgBgMineVipCard,
                    width: screen.screenWidth, height: Dimens.pt140),
                Container(
                    height: Dimens.pt140,
                    padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(children: [
                            Image.asset(R.assetsImgIconMineVip,
                                height: Dimens.pt36),
                            SizedBox(width: Dimens.pt20),
                            if (user.vipType == 0) ...[
                              getVipShadowText(text: "尊享全站资源免费看")
                            ] else ...[
                              getVipShadowText(
                                  text:
                                      "会员有效期:${TimeUtil.buildYYMMDDToNormal(user.vipExpireTime ?? "")}")
                            ],
                            Spacer(),
                            if (user.vipType == 0)
                              Container(
                                  width: Dimens.pt146,
                                  height: Dimens.pt52,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(Dimens.pt45),
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFFFFEBD5),
                                          Color(0xFFFFD6AA)
                                        ]),
                                  ),
                                  child: Text("立即开通",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: AppColors.mainTextColor33)))
                          ]),
                          SizedBox(height: Dimens.pt22),
                          GestureDetector(
                              onTap: () => Get.toNamed(Routes.USER_TERMS_PAGE),
                              child: Row(children: [
                                Image.asset(R.assetsImgIconMineTipAds,
                                    width: Dimens.pt33),
                                SizedBox(width: Dimens.pt8),
                                getVipShadowText(
                                    text: "免广告",
                                    fontSize: Dimens.pt20,
                                    fontWeight: FontWeight.w400),
                                Spacer(),
                                Image.asset(R.assetsImgIconMineTipMoney,
                                    width: Dimens.pt33),
                                SizedBox(width: Dimens.pt8),
                                getVipShadowText(
                                    text: "购买会员送海量金币",
                                    fontSize: Dimens.pt20,
                                    fontWeight: FontWeight.w400),
                                Spacer(),
                                getVipShadowText(
                                    text: "更多特权",
                                    fontSize: Dimens.pt20,
                                    fontWeight: FontWeight.w400),
                                SizedBox(width: Dimens.pt8),
                                Image.asset(R.assetsImgIconMineTipPri,
                                    width: Dimens.pt33)
                              ]))
                        ])),
              ],
            ),
          ),
          Container(
              height: Dimens.pt240,
              padding: EdgeInsets.all(Dimens.pt30),
              decoration: BoxDecoration(color: Color(0xFF24242F)),
              child: Column(children: [
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      logic.getBalanceIng.value += 1;
                      await shareKeys.getUserBalance();
                    },
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(R.assetsImgTextHomeBalance,
                              height: Dimens.pt46),
                          SizedBox(width: Dimens.pt15),
                          Obx(() => Text("¥${shareKeys.userBalance.value}",
                              style: TextStyle(
                                  fontSize: Dimens.pt38,
                                  color: Color(0xFFFFDB9E),
                                  fontWeight: FontWeight.w600))),
                          SizedBox(width: Dimens.pt15),
                          Obx(() => AnimatedRotation(
                                turns: logic.getBalanceIng.value,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(Icons.refresh,
                                    size: Dimens.pt40,
                                    color: const Color(0xFF858589)),
                              )),
                          Spacer(),
                          GestureDetector(
                              onTap: () async {
                                await ApiRes.oneClickScore(onSuccess: () {
                                  showTypeToast(
                                      msg: "下分成功",
                                      toastType: ToastType.SUCCESS);
                                }, onError: (msg) {
                                  showTypeToast(
                                      msg: "下分失败：$msg",
                                      toastType: ToastType.Error);
                                });
                                await shareKeys.getUserBalance();
                              },
                              child: Container(
                                  width: Dimens.pt146,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: Dimens.pt8),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFFE1FDDB),
                                            Color(0xFFD0FBFC)
                                          ]),
                                      borderRadius:
                                          BorderRadius.circular(Dimens.pt46)),
                                  child: Text("一键取回",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: const Color(0xFF333333),
                                          fontWeight: FontWeight.w500)))),
                          SizedBox(width: Dimens.pt10),
                          GestureDetector(
                              onTap: () => Get.toNamed(Routes.VIP_CENTER_PAGE),
                              child: Container(
                                  width: Dimens.pt98,
                                  height: Dimens.pt52,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(Dimens.pt52),
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFFE1FDDB),
                                            Color(0xFFD0FBFC)
                                          ])),
                                  alignment: Alignment.center,
                                  child: Text("充值",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: Color(0xFF333333)))))
                        ])),
                SizedBox(height: Dimens.pt30),
                Image.asset(R.assetsImgLineRunlight, width: double.infinity),
                SizedBox(height: Dimens.pt20),
                Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                    begin: Alignment(-1.0, 0.0), // 91度的起始点
                                    end: Alignment(1.0, 0.0), // 91度的结束点
                                    colors: [
                                      Colors.white, // #FFF
                                      Color(0xFFCE6BE4) // #CE6BE4
                                    ]).createShader(bounds);
                              },
                              child: Text("快猫官方正版火爆电子游戏 充值赢取高额奖金",
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      color: AppColors.textYellowColor)),
                            ),
                            Text("玩快猫官方棋牌游戏 即赠视频VIP 解锁全站精彩爽片",
                                style: TextStyle(
                                    fontSize: Dimens.pt20, color: Colors.white))
                          ]),
                      Spacer(),
                      Transform.translate(
                          offset: Offset(0, Dimens.pt10),
                          child: Image.asset(R.assetsImgIconMineCoin,
                              width: Dimens.pt73))
                    ]))
              ]))
        ]));
  }

  Widget _buildUserLeftNumber(
      HomeMineCenterController logic, ThemeManager theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _leftNumberViewBuilder(logic, theme,
          label: "免费观看次数", left: logic.userInfo.value.currentWatchNum ?? 0),
      _leftNumberViewBuilder(logic, theme,
          label: "观影券", left: logic.userInfo.value.movieTickets),
    ]);
  }

  Column _leftNumberViewBuilder(
      HomeMineCenterController logic, ThemeManager theme,
      {int? left = 0, String? label}) {
    return Column(children: [
      Text("$left",
          style: TextStyle(
              fontSize: Dimens.pt28,
              fontWeight: FontWeight.w600,
              color: theme.getColor(ThemeColor.primary))),
      SizedBox(height: Dimens.pt10),
      Text(label ?? "",
          style: TextStyle(
              fontSize: Dimens.pt28,
              fontWeight: FontWeight.w600,
              color: theme.getColor(ThemeColor.primary))),
    ]);
  }

  Widget _userInfoViewBuilder(
      HomeMineCenterController logic, ThemeManager theme) {
    return GestureDetector(
        onTap: () => Get.toNamed(Routes.SETTING_PAGE),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            ImageLoader.withP(logic.userInfo.value.avatarUrl ?? "",
                    width: Dimens.pt100,
                    height: Dimens.pt100,
                    radius: Dimens.pt100)
                .load(),
            SizedBox(width: Dimens.pt20),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(logic.userInfo.value.nickName ?? "",
                      style: TextStyle(
                          fontSize: Dimens.pt28,
                          color: theme.getColor(ThemeColor.primary))),
                  SizedBox(height: Dimens.pt8),
                  Text("ID:${logic.userInfo.value.id}",
                      style: TextStyle(
                          fontSize: Dimens.pt26,
                          color: theme.getColor(ThemeColor.textGrey)))
                ])),
            SizedBox(width: Dimens.pt20),
            GestureDetector(
                onTap: () => Get.toNamed(Routes.SETTING_PAGE),
                child: Image.asset(R.assetsImgIconArrowRight,
                    width: Dimens.pt40,
                    color: theme.getColor(ThemeColor.textGrey))),
          ]),
        ));
  }

  Widget _mineTopUtilsBuilder(
      HomeMineCenterController logic, ThemeManager theme) {
    return Stack(alignment: Alignment.topRight, children: [
      SizedBox(
          width: screen.screenWidth,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            GestureDetector(
                onTap: () => Get.toNamed(Routes.SETTING_PAGE),
                child: ImageLoader.withP(logic.userInfo.value.avatarUrl ?? "",
                        width: Dimens.pt182,
                        height: Dimens.pt182,
                        radius: Dimens.pt182)
                    .load()),
            SizedBox(height: Dimens.pt25),
            GestureDetector(
                onTap: () => Get.toNamed(Routes.SETTING_PAGE),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(logic.userInfo.value.nickName ?? "",
                      style: TextStyle(
                          fontSize: Dimens.pt36, color: Colors.white)),
                  SizedBox(width: Dimens.pt10),
                  Image.asset(R.assetsImgIconMineEdit, width: Dimens.pt34)
                ])),
            SizedBox(height: Dimens.pt25),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  width: Dimens.pt220,
                  height: Dimens.pt52,
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: Dimens.pt2),
                      borderRadius: BorderRadius.circular(Dimens.pt32)),
                  alignment: Alignment.center,
                  child: Text("ID: ${logic.userInfo.value.id}",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: Dimens.pt24,
                          color: Colors.white.withOpacity(.5)))),
              SizedBox(width: Dimens.pt40),
              GestureDetector(
                  onTap: () => showAccountQrDialog(Get.context!),
                  child: Container(
                      height: Dimens.pt52,
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(Dimens.pt8)),
                      child: Row(children: [
                        Image.asset(R.assetsImgIconMineQr, width: Dimens.pt36),
                        SizedBox(width: Dimens.pt6),
                        Text("账号凭证",
                            style: TextStyle(
                                fontSize: Dimens.pt28, color: Colors.white))
                      ])))
            ])
          ])),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        GestureDetector(
            onTap: () => Get.toNamed(Routes.MESSAGE_CENTER_PAGE),
            child: Container(
                width: Dimens.pt64,
                height: Dimens.pt64,
                padding: EdgeInsets.all(Dimens.pt8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(Dimens.pt64)),
                child: Image.asset(R.assetsImgIconMineMessage))),
        SizedBox(width: Dimens.pt25),
        GestureDetector(
            onTap: () => AppUtils.goToCustomServicePage(),
            child: Container(
                width: Dimens.pt64,
                height: Dimens.pt64,
                padding: EdgeInsets.all(Dimens.pt8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(Dimens.pt64)),
                child: Image.asset(R.assetsImgIconMineCustom))),
        SizedBox(width: Dimens.pt25),
      ]),
      Positioned(
          top: Dimens.pt100,
          child: GestureDetector(
              onTap: () => Get.toNamed(Routes.WEEKLY_CHECK_TASK_PAGE),
              child: Image.asset(R.assetsImgIconMineSigin,
                  width: Dimens.pt99, height: Dimens.pt80))),
    ]);
  }

  Widget _buildChangeIconView(HomeMineCenterController logic) {
    ThemeManager theme = Get.find<ThemeManager>();
    return Container(
        width: screen.screenWidth,
        height: Dimens.pt260,
        margin: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        padding: EdgeInsets.symmetric(
            horizontal: Dimens.pt25, vertical: Dimens.pt25),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(Dimens.pt20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("设置桌面图标",
              style: TextStyle(fontSize: Dimens.pt28, color: Colors.white)),
          SizedBox(height: Dimens.pt20),
          Expanded(
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (c, i) => GestureDetector(
                      onTap: () =>
                          logic.changeAppIcon(logic.logoList[i].name ?? ""),
                      child: Column(children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(Dimens.pt20),
                            child: Image.asset(logic.logoList[i].icon ?? "",
                                width: Dimens.pt90)),
                        SizedBox(height: Dimens.pt10),
                        Text(logic.logoList[i].title ?? "",
                            style: TextStyle(
                                fontSize: Dimens.pt24, color: Colors.white))
                      ])),
                  separatorBuilder: (c, i) => SizedBox(width: Dimens.pt65),
                  itemCount: logic.logoList.length))
        ]));
  }

  static buildNodePoint() {
    return [
      const Spacer(),
      Container(height: Dimens.pt10, width: Dimens.pt2, color: Colors.black)
    ];
  }

  Widget buildRowsItem({
    String? title,
    String? value,
    bool checkValue = false,
    bool haveBorder = true,
    Function? onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
          height: Dimens.pt45,
          decoration: BoxDecoration(
              border: haveBorder
                  ? const Border(bottom: BorderSide(color: Colors.white))
                  : null),
          child: Row(children: [
            Text(title ?? "",
                style: TextStyle(
                    fontSize: Dimens.pt14, color: AppColors.textColor1B1B)),
            const Spacer(),
            if ((value ?? "").isNotEmpty)
              Text(value ?? "",
                  style: TextStyle(
                      fontSize: Dimens.pt12,
                      color: !checkValue
                          ? AppColors.primaryColor
                          : const Color(0xFFB3B6FF))),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.primaryColor, size: Dimens.pt15)
          ])),
    );
  }

  Widget buildUserActions() {
    HomeMineCenterController logic = Get.find();
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ...List.generate(
              logic.actions.length,
              (index) => GestureDetector(
                    onTap: () => logic.actions[index].onTap?.call(),
                    child: Column(children: [
                      Container(
                          alignment: Alignment.center,
                          width: Dimens.pt50,
                          height: Dimens.pt50,
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(Dimens.pt45)),
                          child: Image.asset(logic.actions[index].icon ?? "",
                              width: Dimens.pt30)),
                      SizedBox(height: Dimens.pt10),
                      Text(logic.actions[index].name ?? "",
                          style: TextStyle(
                              fontSize: Dimens.pt12,
                              color: AppColors.primaryColor))
                    ]),
                  ))
        ]));
  }
}

ShaderMask getVipShadowText(
    {String? text, double? fontSize, FontWeight? fontWeight}) {
  return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Color(0xFFFFD8B9),
            Color(0xFFE3A08F),
            Color(0xFFEAC4B1),
            Color(0xFFDD8D69)
          ], // 渐变颜色
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      child: Text(text ?? "",
          style: TextStyle(
              fontSize: fontSize ?? Dimens.pt30,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: Colors.white)));
}
