// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/text_field.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../../../../r.dart';
import '../controllers/withdraw_cash_bank_controller.dart';

class BindingBankCardPageView extends GetView<WithdrawCashBankController> {
  const BindingBankCardPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getCommonAppBar("绑定银行卡"),
        backgroundColor: AppColors.bgColor,
        body: GetX<WithdrawCashBankController>(
            builder: (WithdrawCashBankController logic) {
          logic.count.value;
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(Get.context!).unfocus(),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBankCardBindingItem(
                            label: "开户姓名", hintText: "请输入开户人姓名",
                            focusNode:logic.nameFocusNode,textController:logic.nameField,inputType: TextInputType.text),
                        _buildBankCardBindingItem(
                            label: "银行卡号", hintText: "请输入银行卡号",
                            focusNode:logic.cardNumberFocusNode,textController:logic.cardNumberField,inputType: TextInputType.text),
                        _buildBankCardBindingItem(
                            onTap:()=>{
                              popUpsBottom(Get.context!)
                            },
                            enabled: true,
                            label: "开户银行", hintText: "请输入开户银行",
                            focusNode:logic.bankNameFocusNode,textController:logic.bankNameField,inputType: TextInputType.text),
                        _buildBankCardBindingItem(
                            label: "开户支行", hintText: "请输入开户支行",
                            focusNode:logic.branchesFocusNode,textController:logic.branchesField,inputType: TextInputType.text),
                        SizedBox(height: Dimens.pt80),
                        GestureDetector(
                            onTap: () => {
                              logic.bindBankCard(),
                            },
                            child: Container(
                                width: screen.screenWidth,
                                height: Dimens.pt84,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius:
                                    BorderRadius.circular(Dimens.pt45)),
                                child: Text("提交绑定",
                                    style: TextStyle(
                                        fontSize: Dimens.pt32,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)))),
                        SizedBox(height: Dimens.pt40),
                        Text("绑定说明",
                            style: TextStyle(
                                fontSize: Dimens.pt32,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: Dimens.pt25),
                        Text(
                            "1.请保证银行卡信息准确有效，否则后果自负\n",
                            style: TextStyle(
                                fontSize: Dimens.pt24,
                                color: const Color(0xFFFF6213))),
                      ])),
          );
        }));
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
        Text(
          label ?? "",
          style: TextStyle(
            fontSize: Dimens.pt28,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: Dimens.pt35),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: Dimens.pt122,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: AbsorbPointer(
                absorbing: isInputEnabled, // 禁止用户与子组件交互
                child:Row(
                  children: [
                    Expanded(
                      child: GetCommonTextField(
                        focusNode: focusNode,
                        controller: textController,
                        inputType: inputType,
                        hintText: hintText ?? "",
                        onSubmitted: (String text) => {},
                      )
                    )
                  ]
                )
              )
            )
          )
        )
      ])
    );
  }

  Future popUpsBottom(BuildContext context) {
    WithdrawCashBankController logic = Get.find<WithdrawCashBankController>();
    bool isFullScreen = false;
    return showModalBottomSheet(
        context: context,
        isDismissible: true,
        useSafeArea: true,
        barrierColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (c) => StatefulBuilder(
            builder: (c1, setState) => AnimatedContainer(
                duration: Durations.medium2,
                width: double.infinity,
                height: isFullScreen ? screen.screenHeight : screen.screenHeight / 2,
                color: AppColors.bgColor,
                padding: EdgeInsets.all(Dimens.pt25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: Dimens.pt40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () => setState(() => isFullScreen = !isFullScreen),
                            child: Image.asset(
                                isFullScreen
                                    ? R.assetsImgIconZoomSmall
                                    : R.assetsImgIconZoomBig,
                                width: Dimens.pt30)),
                        GestureDetector(
                            onTap: () => Get.back(),
                            child: Image.asset(R.assetsImgIconCommentClose,
                                width: Dimens.pt30))
                      ]
                    ),

                    SizedBox(height: Dimens.pt25),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: logic.bankList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () => {
                              Get.back(),
                              logic.bankChooseClick(logic.bankList[index])
                            },
                            child: SizedBox(
                              height: 60, // 添加固定高度
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ImageLoader.withP(logic.bankList[index].img??"",
                                        width: Dimens.pt45).load(),
                                    SizedBox(width: Dimens.pt25),
                                    Text(
                                      logic.bankList[index].name??"",
                                      style: TextStyle(
                                        fontSize: Dimens.pt28,
                                        color: Colors.white,
                                      )
                                    )
                                  ]
                                ),
                                SizedBox(height: Dimens.pt16),
                                Divider(color: Colors.white.withOpacity(0.1)), // 添加下划线
                              ])
                            )
                        );
                      }
                    )
                  ]
                )
              )
            )
        )
    );
  }
}
