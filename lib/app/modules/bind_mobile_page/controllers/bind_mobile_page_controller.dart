// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/utils/toast_util.dart';
import '../../../../conf/api_res.dart';
import '../../../../plugins_utils/HttpRequester/http_requester.dart';
import '../../../data/share_key.dart';
import '../../../model/home/user_info_model.dart';
import '../../../routes/app_pages.dart';

class BindMobilePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  late List<String> tabList;
  late RxInt? timeOut = 0.obs;
  late var checkAll = false.obs;

  // 选择的国家区号
  final List<String> countryCodes = ['+86', '+91', '+44', '+28'];
  RxString selectedCountryCode = '+86'.obs;
  TextEditingController phoneTextController = TextEditingController();
  TextEditingController captchaTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController emailCaptchaTextController = TextEditingController();
  TextEditingController emailPasswordTextController = TextEditingController();

  @override
  void onInit() {
    tabList = ["手机绑定", "邮箱绑定"];
    int index = 0;
    if (Get.arguments != null) {
      index = Get.arguments["type"];
    }
    tabController =
        TabController(length: tabList.length, vsync: this, initialIndex: index);
    update();
    super.onInit();
  }

  void startTimeOut() {
    timeOut?.value = 60;
    update();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      timeOut?.value -= 1;
      if (timeOut!.value < 0) {
        timeOut?.value = 0;
        timer.cancel();
      }
      update();
    });
  }

  Future<void> sendCaptcha() async {
    if ((phoneTextController.text).isNotEmpty) {
      var response = await post(ApiRes.sendCaptcha, data: {
        "country": selectedCountryCode.value.replaceAll('+', ''),
        "mobile": phoneTextController.text
      });
      response.when(success: (model) async {
        debugPrint("验证码发送成功");
        startTimeOut();
      }, failure: (String msg, int code) {
        showToast(msg: "验证码发送失败 :$msg");
        debugPrint("验证码发送失败了：msg=$msg/code=$code");
      });
    } else {
      showToast(msg: "请输入电话号码发送");
    }
  }

  Future<void> sendEmailCaptcha() async {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);

    debugPrint("${regex.hasMatch(emailTextController.text)}");
    if (regex.hasMatch(emailTextController.text)) {
      var response = await post(ApiRes.sendEmailCaptcha,
          data: {"email": emailTextController.text});
      response.when(success: (model) async {
        debugPrint("验证码发送成功");
        startTimeOut();
      }, failure: (String msg, int code) {
        showToast(msg: "验证码发送失败 :$msg");
        debugPrint("验证码发送失败了：msg=$msg/code=$code");
      });
    } else {
      showToast(msg: "请输入正确的邮箱地址后发送");
    }
  }

  Future<void> loginEmail() async {
    if (emailCaptchaTextController.text.isNotEmpty) {
      if ((emailTextController.text).isNotEmpty) {
        if ((emailPasswordTextController.text).isNotEmpty) {
          var response = await post<UserInfo, UserInfo>(ApiRes.loginEmail,
              decodeType: UserInfo(),
              data: {
                "captcha": emailCaptchaTextController.text,
                "email": emailTextController.text,
                "password": emailPasswordTextController.text,
              });
          response.when(success: (UserInfo? model) async {
            ShareKeys shareKeys = Get.find<ShareKeys>();
            shareKeys.setUserInfo(model);
            showToast(msg: 'loginPage_text8'.tr);
            await Get.offAllNamed(Routes.SPLASH_PAGE);
          }, failure: (String msg, int code) {
            showToast(msg: "邮箱绑定失败 :$msg");
            debugPrint("邮箱绑定失败：msg=$msg/code=$code");
          });
        } else {
          showToast(msg: "请输入邮箱登陆密码");
        }
      } else {
        showToast(msg: "请输入邮箱号码");
      }
    } else {
      showToast(msg: "请输入邮箱验证码");
    }
  }

  Future<void> loginPhone() async {
    if (captchaTextController.text.isNotEmpty) {
      if ((phoneTextController.text).isNotEmpty) {
        var response = await post<UserInfo, UserInfo>(ApiRes.register,
            decodeType: UserInfo(),
            data: {
              "captcha": captchaTextController.text,
              "country": selectedCountryCode.value.replaceAll('+', ''),
              "mobile": phoneTextController.text
            });
        response.when(success: (UserInfo? model) async {
          ShareKeys shareKeys = Get.find<ShareKeys>();
          shareKeys.setUserInfo(model);
          showToast(msg: 'loginPage_text8'.tr);
          await Get.offAllNamed(Routes.SPLASH_PAGE);
        }, failure: (String msg, int code) {
          showToast(msg: "手机绑定失败 :$msg");
          debugPrint("手机登录失败了：msg=$msg/code=$code");
        });
      } else {
        showToast(msg: "请输入电话号码");
      }
    } else {
      showToast(msg: "请输入短信验证码");
    }
  }

  void changeCheck() {
    checkAll.value = !checkAll.value;
    update();
  }


}
