// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/text_field.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../../../data/share_key.dart';
import '../controllers/withdraw_cash_bank_controller.dart';

class WithdrawCashBankView extends GetView<WithdrawCashBankController> {
  const WithdrawCashBankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getCommonAppBar("提现"),
        backgroundColor: AppColors.bgColor,
        body: GetX<WithdrawCashBankController>(
            builder: (WithdrawCashBankController logic) {
          logic.count.value;
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(Get.context!).unfocus(),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          logic.bankCard.value.bankName != null &&
                                  logic.bankCard.value.bankName != ""
                              ? Container(
                                  width: screen.screenWidth,
                                  height: Dimens.pt162,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF1D1A19),
                                      borderRadius:
                                          BorderRadius.circular(Dimens.pt12)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: Dimens.pt4),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(width: Dimens.pt70),
                                              Text(
                                                "到账银行卡",
                                                style: TextStyle(
                                                  fontSize: Dimens.pt28,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: Dimens.pt30),
                                              // ImageLoader.withP(logic.bankCard.value.img??"",
                                              //     width: Dimens.pt45).load(),
                                              Obx(() => ImageLoader.withP(
                                                      logic.bankCard.value
                                                              .img ??
                                                          "",
                                                      width: Dimens.pt45)
                                                  .load()),
                                              SizedBox(width: Dimens.pt15),
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        height: Dimens.pt35),
                                                    Text(
                                                      logic.bankCard.value
                                                              .bankName ??
                                                          '',
                                                      style: TextStyle(
                                                        fontSize: Dimens.pt32,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text("2分钟内到账",
                                                        style: TextStyle(
                                                          fontSize: Dimens.pt24,
                                                          color: const Color(
                                                              0xFF8A8785),
                                                        ))
                                                  ])
                                            ])
                                      ]))
                              : Container(),
                          SizedBox(height: Dimens.pt35),
                          GestureDetector(
                              onTap: () =>
                                  Get.toNamed(Routes.BINDING_BANK_CARD),
                              child: Container(
                                  width: screen.screenWidth,
                                  height: Dimens.pt162,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF1D1A19),
                                      borderRadius:
                                          BorderRadius.circular(Dimens.pt12)),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add,
                                            size: Dimens.pt34,
                                            color: Colors.white),
                                        SizedBox(width: Dimens.pt10),
                                        Text(
                                            logic.bankCard.value.bankName !=
                                                        null &&
                                                    logic.bankCard.value
                                                            .bankName !=
                                                        ""
                                                ? "更换绑定银行卡"
                                                : "立即绑定银行卡",
                                            style: TextStyle(
                                                fontSize: Dimens.pt28,
                                                color: Colors.white))
                                      ]))),
                          SizedBox(height: Dimens.pt45),
                          Text("提现金额",
                              style: TextStyle(
                                  fontSize: Dimens.pt32, color: Colors.white)),
                          SizedBox(height: Dimens.pt45),
                          Container(
                              padding:
                                  EdgeInsets.symmetric(vertical: Dimens.pt20),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color:
                                              Colors.white.withOpacity(.1)))),
                              child: Row(children: [
                                Text("¥",
                                    style: TextStyle(
                                        fontSize: Dimens.pt58,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                SizedBox(width: Dimens.pt20),
                                Expanded(child: _buildCashInputView())
                              ])),
                          SizedBox(height: Dimens.pt25),
                          _buildBalanceView(logic),
                          SizedBox(height: Dimens.pt80),
                          GestureDetector(
                              onTap: () => logic.bindingPhone(),
                              child: Container(
                                  width: screen.screenWidth,
                                  height: Dimens.pt84,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius:
                                          BorderRadius.circular(Dimens.pt45)),
                                  child: Text("提现",
                                      style: TextStyle(
                                          fontSize: Dimens.pt32,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)))),
                          SizedBox(height: Dimens.pt40),
                          Text("提现说明",
                              style: TextStyle(
                                  fontSize: Dimens.pt32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: Dimens.pt25),
                          _buildTip("1.单笔提现金额 200 ～ 30000元"),
                          _buildTip("2.每天最多提现5单，总金额不超过 150000 元"),
                          _buildTip("3.审核通过超过30分钟未到账时请及时联系在线客服"),
                          _buildTip(
                              "4.提现前请核对您的银行卡信息是否有误，避免提现失败，提现前核查银行卡状态是否正常，避免提现后资金异常无法使用"),
                          _buildTip(
                              "5.提现资金均为正常金流，无需担心资金安全，如果提现后银行卡出现异常状态，请联系在线客服进行反馈"),
                        ]),
                  )));
        }));
  }

  Text _buildTip(String text) {
    return Text(text,
        style:
            TextStyle(fontSize: Dimens.pt24, color: const Color(0xFF8A8785)));
  }

  Row _buildBalanceView(WithdrawCashBankController logic) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    String intValueString;
    return Row(children: [
      Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(
                TextSpan(text: "账户余额：", children: [
                  TextSpan(
                      text: "",
                      style: const TextStyle(color: AppColors.primaryColor))
                ]),
                style: TextStyle(
                    fontSize: Dimens.pt24, color: const Color(0xFF8A8785)))
          ])),
      const Spacer(),
      Container(
          padding: EdgeInsets.symmetric(
              horizontal: Dimens.pt25, vertical: Dimens.pt15),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(Dimens.pt12)),
          child: GestureDetector(
              onTap: () => {
                    // intValueString = shareKeys.userTransferable.value.replaceAll(RegExp(r'\.00$'), ''),
                    logic.cashField.text = shareKeys.userTransferable.value
                  },
              child: Text("最大金额",
                  style: TextStyle(
                      fontSize: Dimens.pt26, color: AppColors.primaryColor))))
    ]);
  }

  _buildCashInputView() {
    WithdrawCashBankController logic = Get.find<WithdrawCashBankController>();
    return GetCommonTextField(
        focusNode: logic.cashFocusNode,
        controller: logic.cashField,
        inputType: TextInputType.number,
        maxLength: 10,
        hintText: "0",
        textStyle: TextStyle(
            fontSize: Dimens.pt58,
            fontWeight: FontWeight.w600,
            color: Colors.white),
        hintStyle: TextStyle(
            fontSize: Dimens.pt58,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8A8785)),
        onSubmitted: (String text) => {});
  }
}
