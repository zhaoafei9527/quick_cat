// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/app/widget/text_field.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../../../../r.dart';
import '../controllers/withdraw_cash_bank_controller.dart';

class BindingBankCardPageView extends StatefulWidget {
  const BindingBankCardPageView({Key? key}) : super(key: key);

  @override
  State<BindingBankCardPageView> createState() =>
      _BindingBankCardPageViewState();
}

class _BindingBankCardPageViewState extends State<BindingBankCardPageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<WithdrawCashBankController>().applyRouteParams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetX<WithdrawCashBankController>(
        builder: (WithdrawCashBankController logic) {
      logic.count.value;
      return Scaffold(
          appBar: getCommonAppBar(logic.bindPageTitle),
          backgroundColor: AppColors.bgColor,
          body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(Get.context!).unfocus(),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (logic.isBankWithdraw) ...[
                          _buildBankCardBindingItem(
                              label: "开户姓名",
                              hintText: "请输入开户人姓名",
                              focusNode: logic.nameFocusNode,
                              textController: logic.nameField,
                              inputType: TextInputType.text),
                          _buildBankCardBindingItem(
                              label: "银行卡号",
                              hintText: "请输入银行卡号",
                              focusNode: logic.cardNumberFocusNode,
                              textController: logic.cardNumberField,
                              inputType: TextInputType.text),
                          _buildBankCardBindingItem(
                              onTap: () => {popUpsBottom(Get.context!)},
                              enabled: true,
                              label: "开户银行",
                              hintText: "请输入开户银行",
                              focusNode: logic.bankNameFocusNode,
                              textController: logic.bankNameField,
                              inputType: TextInputType.text),
                          _buildBankCardBindingItem(
                              label: "开户支行",
                              hintText: "请输入开户支行",
                              focusNode: logic.branchesFocusNode,
                              textController: logic.branchesField,
                              inputType: TextInputType.text),
                        ] else ...[
                          _buildBankCardBindingItem(
                              label: "姓名",
                              hintText: "请输入姓名",
                              focusNode: logic.nameFocusNode,
                              textController: logic.nameField,
                              inputType: TextInputType.text),
                          _buildBankCardBindingItem(
                              label: "钱包地址",
                              hintText: "请输入钱包地址",
                              focusNode: logic.cardNumberFocusNode,
                              textController: logic.cardNumberField,
                              inputType: TextInputType.text),
                          _buildBankCardBindingItem(
                              onTap: () => {popUpsBottom(Get.context!)},
                              enabled: true,
                              label: "钱包名称",
                              hintText: "请选择钱包名称",
                              focusNode: logic.bankNameFocusNode,
                              textController: logic.bankNameField,
                              inputType: TextInputType.text),
                        ],
                        SizedBox(height: Dimens.pt30),
                        getHengLine(h: Dimens.pt1, color: Color(0xFF606060)),
                        SizedBox(height: Dimens.pt30),
                        Text("绑定说明",
                            style: TextStyle(
                                fontSize: Dimens.pt28, color: Colors.white)),
                        SizedBox(height: Dimens.pt25),
                        Text(
                            logic.isBankWithdraw
                                ? "请保证银行卡信息准确有效，否则后果自负"
                                : "请保证姓名、钱包地址与所选钱包名称准确有效，否则后果自负",
                            style: TextStyle(
                                fontSize: Dimens.pt24,
                                color: const Color(0xFF83827E))),
                        SizedBox(height: Dimens.pt80),
                        GestureDetector(
                            onTap: () => logic.submitBinding(),
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
                                child: Text("提交绑定",
                                    style: TextStyle(
                                        fontSize: Dimens.pt30,
                                        color: Colors.black)))),
                        SizedBox(height: Dimens.pt40),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("提现将在15个工作日内到账，如未收到请联系",
                                  style: TextStyle(
                                      fontSize: Dimens.pt24,
                                      color: Colors.white)),
                              GestureDetector(
                                  onTap: () => AppUtils.goToCustomServicePage(),
                                  child: Text("在线客服",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: AppColors.mainRed))),
                            ])
                      ]))));
    });
  }

  Widget _buildBankCardBindingItem({
    String? label,
    String? hintText,
    FocusNode? focusNode,
    TextEditingController? textController,
    TextInputType? inputType,
    VoidCallback? onTap,
    bool? enabled,
  }) {
    bool isInputEnabled = enabled ?? false;
    return SizedBox(
        height: Dimens.pt122,
        child: Row(children: [
          getHengLine(
              h: Dimens.pt18,
              w: Dimens.pt10,
              color: AppColors.mainRed,
              radius: Dimens.pt10),
          SizedBox(width: Dimens.pt15),
          Text(label ?? "",
              style: TextStyle(
                  fontSize: Dimens.pt28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
          SizedBox(width: Dimens.pt35),
          Expanded(
              child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                      height: Dimens.pt72,
                      decoration: BoxDecoration(
                          color: Color(0xFF1F1E22),
                          borderRadius: BorderRadius.circular(Dimens.pt8)),
                      child: AbsorbPointer(
                          absorbing: isInputEnabled,
                          child: Row(children: [
                            SizedBox(width: Dimens.pt15),
                            Expanded(
                                child: GetCommonTextField(
                              focusNode: focusNode,
                              controller: textController,
                              inputType: inputType,
                              hintText: hintText ?? "",
                              onSubmitted: (String text) => {},
                            ))
                          ])))))
        ]));
  }

  Future popUpsBottom(BuildContext context) {
    WithdrawCashBankController logic = Get.find<WithdrawCashBankController>();
    return showModalBottomSheet(
        context: context,
        isDismissible: true,
        useSafeArea: true,
        barrierColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (c) => StatefulBuilder(
            builder: (c1, setState) => Container(
                width: screen.screenWidth,
                height: screen.screenHeight / 2,
                color: Colors.black,
                padding: EdgeInsets.all(Dimens.pt25),
                child: Column(children: [
                  SizedBox(height: Dimens.pt10),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Spacer(),
                        GestureDetector(
                            onTap: () => Get.back(),
                            child: Image.asset(R.assetsImgIconCommentClose,
                                width: Dimens.pt40))
                      ]),
                  SizedBox(height: Dimens.pt25),
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: logic.bankList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () => {
                                      Get.back(),
                                      logic.bankChooseClick(
                                          logic.bankList[index])
                                    },
                                child: SizedBox(
                                    height: Dimens.pt120,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ImageLoader.withP(
                                                        logic.bankList[index]
                                                                .img ??
                                                            "",
                                                        width: Dimens.pt45)
                                                    .load(),
                                                SizedBox(width: Dimens.pt25),
                                                Text(
                                                    logic.bankList[index]
                                                            .name ??
                                                        "",
                                                    style: TextStyle(
                                                      fontSize: Dimens.pt28,
                                                      color: Colors.white,
                                                    ))
                                              ]),
                                          SizedBox(height: Dimens.pt16),
                                          Divider(
                                              color: Colors.white
                                                  .withOpacity(0.1)),
                                        ])));
                          })),
                  SizedBox(height: Dimens.pt25),
                ]))));
  }
}
