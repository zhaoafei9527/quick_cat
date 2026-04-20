// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/app/widget/text_field.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import '../../../data/share_key.dart';
import '../controllers/withdraw_cash_bank_controller.dart';

/// 银行卡 / 电子钱包等提现共用表单（文案由 [WithdrawCashBankController] 路由参数驱动）
class WithdrawCashFormWidget extends GetView<WithdrawCashBankController> {
  const WithdrawCashFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<WithdrawCashBankController>(
        builder: (WithdrawCashBankController logic) {
      ShareKeys shareKeys = Get.find<ShareKeys>();
      return Scaffold(
          appBar: getCommonAppBar(logic.pageAppBarTitle),
          backgroundColor: AppColors.bgColor,
          body: logic.isBankWithdraw && logic.isLoadingBindInfo.value
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white70))
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(Get.context!).unfocus(),
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            logic.hasArrivalAccount
                                ? Container(
                                    width: screen.screenWidth,
                                    height: Dimens.pt162,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Dimens.pt70),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF1D1A19),
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt12)),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(children: [
                                            Text(
                                                logic.isBankWithdraw
                                                    ? logic.arrivalLabelText
                                                    : "到账电子钱包",
                                                style: TextStyle(
                                                    fontSize: Dimens.pt26,
                                                    color: Color(0xFFFFDB9E))),
                                            SizedBox(width: Dimens.pt20),
                                            if (logic.isBankWithdraw)
                                              ImageLoader.withP(
                                                      logic.bankCard.value
                                                              .img ??
                                                          "",
                                                      width: Dimens.pt45)
                                                  .load()
                                            else
                                              ImageLoader.withP(logic.paramIcon,
                                                      width: Dimens.pt45)
                                                  .load(),
                                            SizedBox(width: Dimens.pt15),
                                            Text(logic.arrivalName,
                                                style: TextStyle(
                                                  fontSize: Dimens.pt32,
                                                  color: Colors.white,
                                                )),
                                            SizedBox(width: Dimens.pt30),
                                            Text("秒到账",
                                                style: TextStyle(
                                                    fontSize: Dimens.pt24,
                                                    color: Color(0xFFA19D98))),
                                          ]),
                                          Text(logic.arrivalSubText,
                                              style: TextStyle(
                                                  fontSize: Dimens.pt24,
                                                  color: Colors.white))
                                        ]))
                                : Container(),
                            SizedBox(height: Dimens.pt35),
                            GestureDetector(
                                onTap: () => Get.toNamed(
                                        Routes.BINDING_BANK_CARD,
                                        parameters: {
                                          'wtype': '${logic.withdrawWtype}',
                                          'name': logic.paramName,
                                          'icon': logic.paramIcon,
                                        }),
                                child: Container(
                                    width: screen.screenWidth,
                                    height: Dimens.pt162,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF1F1E22),
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt8)),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add,
                                              size: Dimens.pt34,
                                              color: Color(0xFFFFDB9E)),
                                          SizedBox(width: Dimens.pt10),
                                          Text(logic.bindButtonLabel(),
                                              style: TextStyle(
                                                  fontSize: Dimens.pt28,
                                                  color: Color(0xFFFFDB9E)))
                                        ]))),
                            SizedBox(height: Dimens.pt10),
                            Container(
                                width: screen.screenWidth,
                                height: Dimens.pt84,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF1F1E22),
                                    borderRadius:
                                        BorderRadius.circular(Dimens.pt8)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimens.pt30),
                                child: Row(children: [
                                  Image.asset(R.assetsImgTextHomeBalance,
                                      height: Dimens.pt40),
                                  SizedBox(width: Dimens.pt15),
                                  Obx(() => Text(
                                      "¥${shareKeys.userBalance.value}",
                                      style: TextStyle(
                                          fontSize: Dimens.pt40,
                                          color: Color(0xFFFFDB9E),
                                          fontWeight: FontWeight.w500)))
                                ])),
                            SizedBox(height: Dimens.pt40),
                            Row(children: [
                              Text("提现币类:",
                                  style: TextStyle(
                                      fontSize: Dimens.pt28,
                                      color: Colors.white)),
                              SizedBox(width: Dimens.pt15),
                              Text("人民币",
                                  style: TextStyle(
                                      fontSize: Dimens.pt28,
                                      color: Colors.white.withOpacity(.6)))
                            ]),
                            SizedBox(height: Dimens.pt30),
                            Row(children: [
                              Text("提现金额:",
                                  style: TextStyle(
                                      fontSize: Dimens.pt28,
                                      color: Colors.white)),
                              SizedBox(width: Dimens.pt15),
                              Expanded(
                                  child: Container(
                                      height: Dimens.pt72,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Dimens.pt15),
                                      decoration: BoxDecoration(
                                          color: Color(0xFF1F1E22),
                                          borderRadius: BorderRadius.circular(
                                              Dimens.pt8)),
                                      child: _buildCashInputView()))
                            ]),
                            SizedBox(height: Dimens.pt30),
                            getHengLine(
                                color: Color(0xFF606060), h: Dimens.pt1),
                            SizedBox(height: Dimens.pt30),
                            Text("提现规则",
                                style: TextStyle(
                                    fontSize: Dimens.pt28,
                                    color: Colors.white)),
                            SizedBox(height: Dimens.pt15),
                            Text.rich(
                                TextSpan(
                                    text:
                                        "1.请流水足够后在行提现,流水规则请参考【客服助手】自行查询流水标准查询",
                                    children: [
                                      TextSpan(
                                          text:
                                              "（如未达流水频繁提现，可能会判定为异常，造成短时间内系统禁止提现，损失您的权益）\n",
                                          style: TextStyle(
                                              color: Color(0xFFFFDB9E))),
                                      if (logic.isBankWithdraw)
                                        TextSpan(
                                            text:
                                                "2.提现后会经过人工审核，确保您的资金安全，请耐心等候\n"
                                                "3.单笔提现金额200～30000元（整数提现）\n"
                                                "4.如提现后长时间未通过审核，可能是提现款项系统卡单，此笔订单将会原路返回，请不用担心\n"
                                                "6.提现前请核对您的银行卡信息是否有误，避免提现失败，提现前核查银行卡状态是否正常，避免提现后资金异常无法使用\n"
                                                "7.提现资金均为正常金流，无需担心资金安全，如果提现后银行卡出现异常状态，请联系在线客服进行反馈\n")
                                      else
                                        TextSpan(
                                            text:
                                                "2.电子钱包提现秒到账；无风控，保护您的资金安全 "
                                                    "3.单笔提现金额200～30000元（整数提现） "
                                                    "4.请完整填写电子钱包账户钱包地址 "
                                                    "5.严正声明：本平台严禁洗黑钱，恶意套利等行为，一经发现，严肃处理！")
                                    ]),
                                style: TextStyle(
                                    fontSize: Dimens.pt24,
                                    color: Color(0xFF83827E))),
                            SizedBox(height: Dimens.pt70),
                            GestureDetector(
                                onTap: () => logic.submitWithdraw(),
                                child: Container(
                                    width: screen.screenWidth,
                                    height: Dimens.pt76,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Dimens.pt45),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Color(0xFFE8C07D),
                                              Color(0xFFD29B28)
                                            ]),
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt45)),
                                    child: Text("确认提现",
                                        style: TextStyle(
                                            fontSize: Dimens.pt30,
                                            color: Colors.black)))),
                            SizedBox(height: Dimens.pt38),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("提现将在15个工作日内到账，如未收到请联系",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: Colors.white)),
                                  GestureDetector(
                                      onTap: () =>
                                          AppUtils.goToCustomServicePage(),
                                      child: Text("在线客服",
                                          style: TextStyle(
                                              fontSize: Dimens.pt24,
                                              color: AppColors.mainRed))),
                                ]),
                          ])))));
    });
  }

  Widget _buildCashInputView() {
    WithdrawCashBankController logic = Get.find<WithdrawCashBankController>();
    return GetCommonTextField(
        focusNode: logic.cashFocusNode,
        controller: logic.cashField,
        inputType: TextInputType.number,
        maxLength: 10,
        hintText: "单笔提现金额 200-30000元（整数)",
        textStyle: TextStyle(
            fontSize: Dimens.pt24,
            fontWeight: FontWeight.w600,
            color: Colors.white),
        hintStyle: TextStyle(
            fontSize: Dimens.pt24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8A8785)),
        onSubmitted: (String text) => {});
  }
}
