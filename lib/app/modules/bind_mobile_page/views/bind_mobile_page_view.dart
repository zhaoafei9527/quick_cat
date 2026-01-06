// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/utils/toast_util.dart';
import '../../../../r.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/screen.dart';
import '../../../themes/app_colors.dart';
import '../../../widget/common_widget.dart';
import '../controllers/bind_mobile_page_controller.dart';

class BindMobilePageView extends GetView<BindMobilePageController> {
  const BindMobilePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BindMobilePageController>(builder: (logic) {
      return Scaffold(
        appBar: buildAppBar(title: 'appBar_bindMobile'.tr),
        body: Column(children: [
          SizedBox(height: Dimens.pt15),
          buildTab(logic),
          SizedBox(height: Dimens.pt30),
          Expanded(
              child: TabBarView(
            controller: logic.tabController,
            children: [buildPhoneBinding(logic), buildEmailBinding(logic)],
          ))
        ]),
      );
    });
  }

  Widget buildPhoneBinding(BindMobilePageController logic) {
    return Column(children: [
      buildBorderInputView(
        child: Row(
          children: [
            SizedBox(
                width: Dimens.pt50,
                child: DropdownButton<String>(
                    value: controller.selectedCountryCode.value,
                    underline: Container(),
                    alignment: AlignmentDirectional.topStart,
                    dropdownColor: AppColors.bgColor,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    // 自定义的下拉图标
                    iconSize: 24,
                    style:
                        TextStyle(color: Colors.white, fontSize: Dimens.pt14),
                    onChanged: (String? newValue) {
                      logic.selectedCountryCode.value = newValue ?? "";
                      logic.update();
                    },
                    items: controller.countryCodes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: TextStyle(
                                fontSize: Dimens.pt14, color: Colors.black)),
                      );
                    }).toList())),
            Expanded(
              child: buildTextInput(logic.phoneTextController,
                  keyboardType: TextInputType.phone, hintText: "请输入手机号码"),
            ),
          ],
        ),
      ),
      SizedBox(height: Dimens.pt20),
      buildBorderInputView(
          child: Row(children: [
        Expanded(
          child: buildTextInput(logic.captchaTextController,
              keyboardType: TextInputType.number, hintText: "请输入短信验证码"),
        ),
        if ((logic.timeOut ?? 0) != 0)
          Text("${logic.timeOut}s后重新获取",
              style: TextStyle(
                  fontSize: Dimens.pt12, color: const Color(0xFF96979E)))
        else
          GestureDetector(
              onTap: () => logic.sendCaptcha(),
              child: Text("获取验证码",
                  style: TextStyle(
                      fontSize: Dimens.pt12, color: AppColors.primaryColor)))
      ])),
      SizedBox(height: Dimens.pt20),
      GestureDetector(
          onTap: () {
            if (logic.checkAll.value) {
              logic.loginPhone();
            } else {
              showToast(msg: "请同意服务条款和隐私协议后缺人");
            }
          },
          child: Container(
            width: screen.screenWidth,
            height: Dimens.pt54,
            margin: EdgeInsets.symmetric(horizontal: Dimens.pt20),
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(Dimens.pt45)),
            child: Center(
                child: Text("立即绑定",
                    style:
                        TextStyle(fontSize: Dimens.pt16, color: Colors.white))),
          )),
      SizedBox(height: Dimens.pt20),
      buildProtocol(logic)
    ]);
  }

  Widget buildEmailBinding(BindMobilePageController logic) {
    return Column(children: [
      buildBorderInputView(
          child: buildTextInput(logic.emailTextController,
              maxLength: 50,
              keyboardType: TextInputType.text,
              hintText: "请输入邮箱号码")),
      SizedBox(height: Dimens.pt20),
      buildBorderInputView(
          child: Row(children: [
        Expanded(
            child: buildTextInput(logic.emailCaptchaTextController,
                keyboardType: TextInputType.number, hintText: "请输入邮箱验证码")),
        if ((logic.timeOut ?? 0) != 0)
          Text("${logic.timeOut}s后重新获取",
              style: TextStyle(
                  fontSize: Dimens.pt12, color: const Color(0xFF96979E)))
        else
          GestureDetector(
              onTap: () => logic.sendEmailCaptcha(),
              child: Text("获取验证码",
                  style: TextStyle(
                      fontSize: Dimens.pt12, color: AppColors.primaryColor)))
      ])),
      SizedBox(height: Dimens.pt20),
      buildBorderInputView(
          child: buildTextInput(logic.emailPasswordTextController,
              maxLength: 50,
              keyboardType: TextInputType.text,
              hintText: "请输入密码")),
      SizedBox(height: Dimens.pt20),
      GestureDetector(
          onTap: () {
            if (logic.checkAll.value) {
              logic.loginEmail();
            } else {
              showToast(msg: "请同意服务条款和隐私协议后确认");
            }
          },
          child: Container(
            width: screen.screenWidth,
            height: Dimens.pt54,
            margin: EdgeInsets.symmetric(horizontal: Dimens.pt20),
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(Dimens.pt45)),
            child: Center(
                child: Text("立即绑定",
                    style:
                        TextStyle(fontSize: Dimens.pt16, color: Colors.white))),
          )),
      SizedBox(height: Dimens.pt20),
      buildProtocol(logic)
    ]);
  }

  Widget buildProtocol(BindMobilePageController logic) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
          onTap: () => logic.changeCheck(),
          child: Container(
              child: (logic.checkAll.value)
                  ? Image.asset(R.assetsImgIconRadioCheck, width: Dimens.pt18)
                  : Image.asset(R.assetsImgIconRadio, width: Dimens.pt18))),
      SizedBox(width: Dimens.pt3),
      Text("已阅读同意：91免费版",
          style:
              TextStyle(fontSize: Dimens.pt12, color: AppColors.textColor1B1B)),
      Text("服务条款",
          style:
              TextStyle(fontSize: Dimens.pt12, color: AppColors.primaryColor)),
      Text("和",
          style:
              TextStyle(fontSize: Dimens.pt12, color: AppColors.textColor1B1B)),
      Text("隐私协议",
          style:
              TextStyle(fontSize: Dimens.pt12, color: AppColors.primaryColor))
    ]);
  }

  Widget buildBorderInputView({Widget? child, Color? borderColor}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimens.pt29),
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
      decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? const Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(Dimens.pt45)),
      child: child ?? const SizedBox.shrink(),
    );
  }

  Widget buildTab(BindMobilePageController logic) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimens.pt29),
      height: Dimens.pt40,
      decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(Dimens.pt8)),
      child: TabBar(
          controller: logic.tabController,
          isScrollable: false,
          tabs: logic.tabList.map((e) => Text(e)).toList(),
          labelStyle:
              TextStyle(fontSize: Dimens.pt14, color: const Color(0xFF9ABBD1)),
          labelColor: Colors.white,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicatorWeight: 0,
          labelPadding: EdgeInsets.symmetric(vertical: Dimens.pt6),
          unselectedLabelStyle:
              TextStyle(fontSize: Dimens.pt14, color: const Color(0xFF9ABBD1)),
          unselectedLabelColor: const Color(0xFF979797),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
              color: const Color(0xFF7651FD),
              borderRadius: BorderRadius.all(Radius.circular(Dimens.pt8)))),
    );
  }
}
