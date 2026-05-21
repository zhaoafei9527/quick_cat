// 🐦 Flutter imports:
import 'package:quick_cat_client/app/model/home/pay_list_model.dart';
import 'package:quick_cat_client/app/modules/home/home_index_web/views/home_tab_pull_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/text_field.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/app_util.dart';
import '../../../../r.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/screen.dart';
import '../../../data/share_key.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_colors.dart';
import '../../../widget/common_widget.dart';
import '../controllers/vip_center_page_controller.dart';

class VipCenterPageView extends GetView<VipCenterPageController> {
  const VipCenterPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<VipCenterPageController>(
        builder: (VipCenterPageController logic) {
      return Stack(children: [
        Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: getCommonAppBar("充值", actions: [
              GestureDetector(
                  onTap: () => AppUtils.goToCustomServicePage(),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("在线客服",
                          style: TextStyle(
                              fontSize: Dimens.pt28,
                              color: AppColors.primaryColor)))),
              SizedBox(width: Dimens.pt25)
            ]),
            body: logic.initOk.value
                ? SingleChildScrollView(
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAnnouncement(),
                              SizedBox(height: Dimens.pt30),
                              _showBalanceCard(),
                              SizedBox(height: Dimens.pt30),
                              _showRechargeListCard(),
                              SizedBox(height: Dimens.pt30),
                              if (logic.showOnlineRecharge.value) ...[
                                _buildOnlineRecharge(),
                                SizedBox(height: Dimens.pt40),
                              ],
                              SizedBox(height: Dimens.pt20),
                              Center(
                                  child: Image.asset(R.assetsImgTipVipCard,
                                      height: Dimens.pt32)),
                              SizedBox(height: Dimens.pt40),
                              Text(
                                  "1.任意充值送VIP，充的多送的多可无限叠加\n2.为保障您的资金安全及权益,请绑定手机号进行完整注册\n3.请在规定时间内完成支付，超时不退不补",
                                  style: TextStyle(
                                      fontSize: Dimens.pt24,
                                      color: AppColors.mainTextColor99)),
                              Text.rich(
                                  const TextSpan(text: "4.支付", children: [
                                    TextSpan(
                                        text: "请勿重复支付同一收款账户",
                                        style: TextStyle(
                                            color: AppColors.mainTextColor99)),
                                    TextSpan(text: "每次充值务必到充值页面,"),
                                    TextSpan(
                                        text: " 重新获取付款账户",
                                        style: TextStyle(
                                            color: AppColors.mainTextColor99)),
                                    TextSpan(
                                        text: "若该收款账户已不收款,而用户仍直接转账,损失由用户自行承担!"),
                                  ]),
                                  style: TextStyle(
                                      fontSize: Dimens.pt24,
                                      color: AppColors.mainTextColor99)),
                              Text("5.支付成功后一般为15分钟内到账,超过30分钟未到账请提供支付凭证截图找客服反馈",
                                  style: TextStyle(
                                      fontSize: Dimens.pt24,
                                      color: AppColors.mainTextColor99)),
                              SizedBox(height: Dimens.pt80),
                              SizedBox(height: screen.bottomNavBarH),
                            ])),
                  )
                : getLoadingView(),
            bottomNavigationBar: !logic.showOnlineRecharge.value
                ? BottomAppBar(
                    color: AppColors.bgColor, // 设置底部导航栏的背景颜色为蓝色
                    height: Dimens.pt130,
                    child: SizedBox(
                        height: 44,
                        child: GestureDetector(
                            onTap: () => logic.submitRecharge(),
                            child: Container(
                                width: screen.screenWidth,
                                height: Dimens.pt84,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(Dimens.pt84),
                                    color: AppColors.mainRed),
                                child: Center(
                                    child: logic.amountMenu.isNotEmpty
                                        ? Text(
                                            "¥${logic.showInputPriceView ? logic.inputAmount.value : (logic.amountMenu[logic.amountSelect.value].payAmount ?? 0) ~/ 100}/确认支付",
                                            style: TextStyle(
                                                fontSize: Dimens.pt36,
                                                color: Colors.white))
                                        : SizedBox())))))
                : null),
        Obx(
          () => logic.showLoading.value
              ? Container(
                  width: screen.screenWidth,
                  height: screen.screenHeight,
                  color: Colors.black.withOpacity(.5),
                  child: getLoadingWidget())
              : const SizedBox(),
        )
      ]);
    });
  }

  Widget _buildAnnouncement() {
    return buildRunningLightView();
    // return Container(
    //     height: Dimens.pt72,
    //     decoration: BoxDecoration(color: AppColors.primaryRaised),
    //     padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
    //     child: Row(children: [
    //       Image.asset(R.assetsImgIconBroadcast, width: Dimens.pt24),
    //       SizedBox(width: Dimens.pt15),
    //       Expanded(
    //           child: Marquee(
    //               blankSpace: 20,
    //               velocity: 100,
    //               text: "全网送最多！每笔充值额外加赠彩金，最高8%！下注即有机会赢取巨额奖金，提现秒到账！",
    //               style: TextStyle(fontSize: Dimens.pt26, color: Colors.black)))
    //     ]));
  }

  Widget _buildOnlineRecharge() {
    VipCenterPageController logic = Get.find<VipCenterPageController>();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("客服列表",
          style: TextStyle(
              fontSize: Dimens.pt32,
              fontWeight: FontWeight.w600,
              color: Colors.white)),
      SizedBox(height: Dimens.pt25),
      if (logic.onLineRecharger.isEmpty)
        Center(
            child: Text("暂无在线客服",
                style: TextStyle(
                    fontSize: Dimens.pt24, color: AppColors.mainTextColor79))),
      ...List.generate(logic.onLineRecharger.length, (index) {
        OnlineChargeModes charger = logic.onLineRecharger[index];
        return GestureDetector(
            onTap: () => logic.getCustomServiceInfo(
                type: charger.type ?? 204, id: charger.id ?? ""),
            child: Container(
                padding: EdgeInsets.symmetric(vertical: Dimens.pt25),
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0x10FFFFFF)))),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  ImageLoader.withP(charger.avatar,
                          radius: Dimens.pt80,
                          height: Dimens.pt80,
                          width: Dimens.pt80)
                      .load(),
                  SizedBox(width: Dimens.pt30),
                  SizedBox(
                      width: Dimens.pt370,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(charger.nickname ?? "",
                                      style: TextStyle(
                                          fontSize: Dimens.pt28,
                                          color: Colors.white)),
                                  SizedBox(width: Dimens.pt70),
                                  Container(
                                      width: Dimens.pt60,
                                      height: Dimens.pt30,
                                      decoration: BoxDecoration(
                                          color: Color(0xFF15A745),
                                          borderRadius: BorderRadius.circular(
                                              Dimens.pt45)),
                                      child: Center(
                                          child: Text("客服",
                                              style: TextStyle(
                                                  fontSize: Dimens.pt20,
                                                  color: Colors.white))))
                                ]),
                            Text(charger.desc ?? "官方24H在线大额秒充笔笔送2%",
                                style: TextStyle(
                                    fontSize: Dimens.pt24,
                                    color: Color(0xFF8A8785)))
                          ])),
                  const Spacer(),
                  Container(
                      width: Dimens.pt110,
                      height: Dimens.pt58,
                      decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(Dimens.pt58)),
                      child: Center(
                          child: Text("充值",
                              style: TextStyle(
                                  fontSize: Dimens.pt26, color: Colors.white))))
                ])));
      })
    ]);
  }

  Widget _showRechargeListCard() {
    VipCenterPageController logic = Get.find<VipCenterPageController>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("充值方式",
          style: TextStyle(fontSize: Dimens.pt32, color: Colors.white)),
      SizedBox(height: Dimens.pt30),
      SizedBox(
        height: Dimens.pt144 + Dimens.pt20,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (c, index) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => logic.selectRectangle(index),
                child: _buildPayTypeItem(logic, index)),
            separatorBuilder: (c, index) => SizedBox(width: Dimens.pt17),
            itemCount: logic.payWayList.length),
      ),
      if (logic.showInputPriceView) _buildInputPriceView(),
      if (logic.showNoInputPriceView) _buildNoInputPriceView()
    ]);
  }

  Widget _buildNoInputPriceView() {
    VipCenterPageController logic = Get.find<VipCenterPageController>();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: Dimens.pt50),
      Text("充值金额",
          style: TextStyle(fontSize: Dimens.pt32, color: Colors.white)),
      SizedBox(height: Dimens.pt45),
      Wrap(
          direction: Axis.horizontal,
          spacing: Dimens.pt10,
          alignment: WrapAlignment.start,
          runSpacing: Dimens.pt15,
          children: List.generate(
              logic.amountMenu.length,
              (index) => GestureDetector(
                  onTap: () => logic.vipAmountChange(index),
                  child: Stack(alignment: Alignment.topLeft, children: [
                    Image.asset(
                        logic.amountSelect.value == index
                            ? R.assetsImgBgVipPriceSel
                            : R.assetsImgBgVipPrice,
                        width: Dimens.pt222,
                        height: Dimens.pt157),
                    Obx(() => SizedBox(
                        width: Dimens.pt222,
                        height: Dimens.pt157,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("赠送VIP${logic.amountMenu[index].vipDay}天",
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      color: Color(0xFFB2F6AF))),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(
                                            bottom: Dimens.pt15),
                                        child: getPriceShadowText(
                                            text: "¥",
                                            fontSize: Dimens.pt26,
                                            fontWeight: FontWeight.w700)),
                                    getPriceShadowText(
                                        text:
                                            "${(logic.amountMenu[index].payAmount ?? 0) ~/ 100}",
                                        fontSize: Dimens.pt58,
                                        fontWeight: FontWeight.w700)
                                  ])
                            ]))),
                    if (index == 0)
                      Transform.translate(
                        offset: Offset(0, -Dimens.pt20),
                        child: Container(
                            width: Dimens.pt150,
                            height: Dimens.pt40,
                            decoration: BoxDecoration(
                              color: AppColors.mainRed,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(Dimens.pt22),
                                  bottomRight: Radius.circular(Dimens.pt22)),
                            ),
                            child: Center(
                                child: Text("95%用户选择",
                                    style: TextStyle(
                                        fontSize: Dimens.pt21,
                                        color: Colors.white)))),
                      )
                  ]))))
    ]);
  }

  Widget _buildInputPriceView() {
    VipCenterPageController logic = Get.find<VipCenterPageController>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: Dimens.pt20),
      Text("【官方推荐】使用电子钱包充值每笔加赠彩金,充提秒到账,安全无忧,让娱乐更简单提现更加方便！",
          style: TextStyle(fontSize: Dimens.pt26, color: Color(0xFFFFDB9E))),
      SizedBox(height: Dimens.pt10),
      Row(children: [
        Text("钱包下载：",
            style: TextStyle(fontSize: Dimens.pt26, color: Colors.white)),
        GestureDetector(
            onTap: () => AppPages.jumpRouter(path: logic.downloadPath.value),
            child: Container(
                width: Dimens.pt128,
                height: Dimens.pt41,
                decoration: BoxDecoration(
                    color: Color(0xFFFFDB9E),
                    borderRadius: BorderRadius.circular(Dimens.pt45)),
                child: Center(
                  child: Text("点击下载",
                      style: TextStyle(
                          fontSize: Dimens.pt26, color: Color(0xFF8B3200))),
                ))),
        Spacer(),
        Text("钱包使用教程：：",
            style: TextStyle(fontSize: Dimens.pt26, color: Colors.white)),
        GestureDetector(
            onTap: () => AppPages.jumpRouter(path: logic.descPath.value),
            child: Container(
                width: Dimens.pt128,
                height: Dimens.pt41,
                decoration: BoxDecoration(
                    color: Color(0xFFFFDB9E),
                    borderRadius: BorderRadius.circular(Dimens.pt45)),
                child: Center(
                  child: Text("点击查看",
                      style: TextStyle(
                          fontSize: Dimens.pt26, color: Color(0xFF8B3200))),
                ))),
      ]),
      SizedBox(height: Dimens.pt50),
      Text("充值金额",
          style: TextStyle(fontSize: Dimens.pt32, color: Colors.white)),
      SizedBox(height: Dimens.pt50),
      Stack(clipBehavior: Clip.none, alignment: Alignment.topRight, children: [
        Container(
            width: screen.screenWidth,
            height: Dimens.pt90,
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            decoration: BoxDecoration(
                color: Color(0xFF24242F),
                borderRadius: BorderRadius.circular(Dimens.pt8)),
            child: GetCommonTextField(
                controller: logic.priceController,
                maxLength: 25,
                textStyle:
                    TextStyle(color: Colors.white, fontSize: Dimens.pt26),
                inputType: TextInputType.number,
                hintStyle:
                    TextStyle(color: Color(0xFFA19D98), fontSize: Dimens.pt26),
                hintText: "¥ 50-300000",
                onChanged: logic.onInputAmountChanged,
                onSubmitted: logic.onInputAmountChanged)),
        Transform.translate(
          offset: Offset(0, -Dimens.pt25),
          child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimens.pt15, vertical: Dimens.pt5),
              decoration: BoxDecoration(
                color: AppColors.mainRed,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimens.pt22),
                    bottomRight: Radius.circular(Dimens.pt22)),
              ),
              child: Obx(() => logic.inputVipDay.value > 0
                  ? Text("赠送VIP${logic.inputVipDay.value}天",
                      style:
                          TextStyle(fontSize: Dimens.pt20, color: Colors.white))
                  : Text("送VIP",
                      style: TextStyle(
                          fontSize: Dimens.pt20, color: Colors.white)))),
        )
      ])
    ]);
  }

  Widget _buildPayTypeItem(VipCenterPageController logic, int index) {
    int selectIndex = logic.selectedRectangleIndex.value;
    return Stack(alignment: Alignment.bottomCenter, children: [
      SizedBox(width: Dimens.pt144, height: Dimens.pt144 + Dimens.pt25),
      Container(
          width: Dimens.pt144,
          height: Dimens.pt144,
          decoration: BoxDecoration(
              color: selectIndex == index
                  ? AppColors.textColorWhite
                  : Color(0xFF24242F),
              borderRadius: BorderRadius.circular(Dimens.pt4)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.asset(logic.payWayList[index].icon ?? '',
                    width: Dimens.pt60, height: Dimens.pt60)),
            SizedBox(height: Dimens.pt5),
            Text(logic.payWayList[index].rechargeName ?? '',
                style: TextStyle(
                    fontSize: Dimens.pt24,
                    color: selectIndex == index
                        ? Color(0xFF0B0C13)
                        : Colors.white))
          ])),
      if ((logic.payWayList[index].bonusRatio ?? 0) > 0)
        Positioned(
            top: 0,
            left: 0,
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimens.pt15, vertical: Dimens.pt5),
                decoration: BoxDecoration(
                    color: AppColors.mainRed,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimens.pt22),
                        bottomRight: Radius.circular(Dimens.pt22))),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("送",
                      style: TextStyle(
                          fontSize: Dimens.pt22,
                          color: AppColors.textColorWhite)),
                  SizedBox(width: Dimens.pt1),
                  Text("${logic.payWayList[index].bonusRatio}%",
                      style: TextStyle(
                          fontSize: Dimens.pt22,
                          color: AppColors.textColorWhite))
                ]))),
      // if (logic.selectedRectangleIndex.value == index)
      // Image.asset(R.assetsImgIconPayTip, width: Dimens.pt16)
    ]);
  }

  Widget _showBalanceCard() {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    return Obx(() {
      VipCenterPageController logic = Get.find<VipCenterPageController>();
      return Stack(alignment: Alignment.centerRight, children: [
        Image.asset(R.assetsImgBgVipCard,
            width: screen.screenWidth, height: Dimens.pt280),
        Container(
            width: screen.screenWidth,
            height: Dimens.pt280,
            padding: EdgeInsets.all(Dimens.pt30),
            child: Padding(
                padding: EdgeInsets.only(left: Dimens.pt50),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text("我的余额（元）",
                            style: TextStyle(
                                fontSize: Dimens.pt30,
                                color: AppColors.mainTextColor33)),
                        SizedBox(width: Dimens.pt10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: Dimens.pt5),
                              GestureDetector(
                                  onTap: () async {
                                    logic.getBalanceIng.value += 1;
                                    await shareKeys.getUserBalance();
                                  },
                                  child: Obx(() => AnimatedRotation(
                                      turns: logic.getBalanceIng.value,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Icon(Icons.refresh,
                                          color: AppColors.mainTextColor33,
                                          size: Dimens.pt38))))
                            ])
                      ]),
                      SizedBox(height: Dimens.pt20),
                      Row(children: [
                        Text("¥${shareKeys.userBalance.value}",
                            style: TextStyle(
                                fontSize: Dimens.pt60,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8B3200)))
                      ]),
                      const Spacer(),
                      Row(children: [
                        GestureDetector(
                            onTap: () =>
                                Get.toNamed(Routes.BILL_RECORD_PAGE_VIEW),
                            child: Text("充值记录 >",
                                style: TextStyle(
                                    fontSize: Dimens.pt24,
                                    color: const Color(0xFF8B3200)))),
                        const Spacer(),
                        GestureDetector(
                            onTap: () => Get.toNamed(
                                Routes.BILL_RECORD_PAGE_VIEW,
                                arguments: {"type": 1}),
                            child: Text("提现记录 >",
                                style: TextStyle(
                                    fontSize: Dimens.pt24,
                                    color: const Color(0xFF8B3200)))),
                        const Spacer(),
                        GestureDetector(
                            onTap: () => Get.toNamed(
                                Routes.BILL_RECORD_PAGE_VIEW,
                                arguments: {"type": 2}),
                            child: Text("收支明细 >",
                                style: TextStyle(
                                    fontSize: Dimens.pt24,
                                    color: const Color(0xFF8B3200))))
                      ])
                    ]))),
        GestureDetector(
            onTap: () => logic.goWithdrawCash(),
            child: Container(
                width: Dimens.pt113,
                height: Dimens.pt54,
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: Dimens.pt25),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3))
                    ],
                    borderRadius: BorderRadius.circular(Dimens.pt45)),
                child: Text("提现",
                    style: TextStyle(
                        fontSize: Dimens.pt26,
                        color: const Color(0xFF8B3200)))))
      ]);
    });
  }
}

ShaderMask getPriceShadowText(
    {String? text, double? fontSize, FontWeight? fontWeight}) {
  return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81E19A), Color(0xFFF1F91D)], // 渐变颜色
          // 渐变方向
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      child: Text(text ?? "",
          style: TextStyle(
              fontSize: fontSize ?? Dimens.pt30,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: Colors.white)));
}
