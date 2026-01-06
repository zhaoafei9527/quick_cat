// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/HttpRequester.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:scan/scan.dart';
import '../../../model/home/user_info_model.dart';
import '../../../notifier/bus_events.dart';

class SettingPageController extends GetxController {
  final count = 0.obs;
  final textLen = 0.obs;
  GlobalKey findPanelKey = GlobalKey();
  RxBool openMask = false.obs;
  RxBool openNamePanel = false.obs;
  RxBool openGenderPanel = false.obs;
  RxBool openInvitePanel = false.obs;
  RxBool openFindAccountPanel = false.obs;
  RxBool isFindPage = false.obs;
  Rx<Offset> position = const Offset(0, 0).obs;
  FocusNode phoneFocusNode = FocusNode();
  FocusNode codeFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  FocusNode inviteFocusNode = FocusNode();
  Rx<UserInfo> userInfo = UserInfo().obs;
  RxString userAvatar = "".obs;
  RxInt chapterTime = 60.obs; // 短信倒计时
  var items = <Map<String, dynamic>>[].obs;
  TextEditingController phoneField = TextEditingController();
  TextEditingController codeField = TextEditingController();
  TextEditingController nameField = TextEditingController();
  TextEditingController inviteField = TextEditingController();
  RxMap<String, List<AvatarInfo>> avatarList = <String, List<AvatarInfo>>{}.obs;

  @override
  void onInit() async {
    super.onInit();

    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo.value = await shareKeys.getUserInfo();
    userAvatar.value = userInfo.value.avatarUrl ?? "";
    eventBus.on(EventsBusKey.subUpdateUserInfo)?.listen((event) async {
      ShareKeys shareKeys = Get.find<ShareKeys>();
      userInfo.value = shareKeys.userInfo;
      update();
    });
    update();
  }

  cleanSettingPage() {
    phoneField.text = "";
    codeField.text = "";
    nameField.text = "";
    inviteField.text = "";
  }

  closePanel() {
    // FocusScope.of(Get.context!).unfocus();
    if (openNamePanel.value) {
      nameFocusNode.unfocus();
      openNamePanel.value = false;
    }
    if (openGenderPanel.value) openGenderPanel.value = false;
    if (openInvitePanel.value) {
      inviteFocusNode.unfocus();
      openInvitePanel.value = false;
    }
    if (openFindAccountPanel.value) {
      openFindAccountPanel.value = false;
    }
    Future.delayed(Durations.medium4, () {
      openMask.value = false;
    });
  }

  openPanel(param) {
    openMask.value = true;
    if (param == "openNamePanel") {
      openNamePanel.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(Get.context!).requestFocus(nameFocusNode);
      });
    } else if (param == "openGenderPanel") {
      openGenderPanel.value = true;
    } else if (param == "openInvitePanel") {
      openInvitePanel.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(Get.context!).requestFocus(inviteFocusNode);
      });
    } else if (param == "findAccountPanel") {
      final renderBox =
          findPanelKey.currentContext?.findRenderObject() as RenderBox?;
      position.value = renderBox!.localToGlobal(Offset.zero);
      openFindAccountPanel.value = true;
      // openInvitePanel.value = true;
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   FocusScope.of(Get.context!).requestFocus(inviteFocusNode);
      // });
    }
  }

  changeNameDown() async {
    if ((nameField.text).isEmpty) return showToast(msg: "请输入昵称后重试");
    if ((userInfo.value.vipType ?? 0) > 0) {
      await ApiRes.setUserInformation(
          onSuccess: () async {
            await ApiRes.getUpdateUserInfo();
            showTypeToast(msg: "成功更换昵称", toastType: ToastType.SUCCESS);
            closePanel();
          },
          onError: (err) {
            showTypeToast(msg: "昵称更换失败，错误：$err");
          },
          nickName: nameField.text);
    } else {
      var result = await showPlayerCommonDialog(Get.context!,
          title: "友情提示",
          content: "该功能仅会员用户可使用,请先获得会员！",
          btnList: ["获得会员"],
          btnActionIndex: 0);
    }
  }

  sendCaptchaCode() async {
    if (phoneField.text.isNotEmpty) {
      if (!isValidPhoneNumber(phoneField.text)) {
        return showTypeToast(msg: "手机号码格式不正确");
      }

      Timer? timer;
      const oneSec = Duration(seconds: 1);
      if (chapterTime.value >= 60) {
        await ApiRes.getCaptcha(
            mobile: phoneField.text,
            country: "86",
            onSuccess: (t) {
              timer = Timer.periodic(oneSec, (time) {
                chapterTime.value -= 1;
                if (chapterTime.value <= 1) {
                  timer?.cancel();
                  chapterTime.value = 60;
                }
              });
            },
            onError: (msg) {
              showTypeToast(msg: "验证码发送失败，错误:$msg");
            });
      }
    } else {
      showTypeToast(msg: "手机号码不能为空");
    }
  }

  bool isValidPhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^\+?[0-9]{7,15}$');
    return regex.hasMatch(phoneNumber);
  }

  loginByPhone() async {
    if (phoneField.text.isNotEmpty) {
      if (!isValidPhoneNumber(phoneField.text)) {
        return showTypeToast(msg: "手机号码格式不正确");
      }
      if (codeField.text.isNotEmpty) {
        showLoadingDialog();
        await ApiRes.loginByPhone(
            country: "86",
            captcha: codeField.text,
            mobile: phoneField.text,
            onSuccess: (UserInfo userInfo) async {
              showTypeToast(msg: "手机账号找回成功", toastType: ToastType.SUCCESS);

              Future.delayed(Durations.extralong4, () async {
                await Get.offAllNamed(Routes.SPLASH_PAGE);
              });
            },
            onError: (err) {
              showToast(msg: "手机账号找回失败，错误:$err");
              Get.back();
            });
      } else {
        showTypeToast(msg: "手机验证码不能为空");
      }
    } else {
      showTypeToast(msg: "手机号码不能为空");
    }
  }

  bindingPhone() async {
    if (phoneField.text.isNotEmpty) {
      if (!isValidPhoneNumber(phoneField.text)) {
        return showTypeToast(msg: "手机号码格式不正确");
      }
      if (codeField.text.isNotEmpty) {
        showLoadingDialog();
        await ApiRes.bindingPhone(
            country: "86",
            captcha: codeField.text,
            mobile: phoneField.text,
            onSuccess: (UserInfo userInfo) async {
              ShareKeys shareKeys = Get.find<ShareKeys>();
              shareKeys.userInfo = userInfo;
              if ((userInfo.token ?? "").isNotEmpty) {
                await NetWorkCreator.init(newToken: userInfo.token ?? "");
              }
              showTypeToast(msg: "绑定手机成功", toastType: ToastType.SUCCESS);
              AppUtils.jumpToHome(index: 4);
            },
            onError: (err) {
              showToast(msg: "绑定手机失败，错误:$err");
              Get.back();
            });
      } else {
        showTypeToast(msg: "手机验证码不能为空");
      }
    } else {
      showTypeToast(msg: "手机号码不能为空");
    }
  }

  inviteCode() async {}

  // 0 : 男 1: 女
  changeGenderDown(int type) async {
    await ApiRes.setUserInformation(
        onSuccess: () async {
          await ApiRes.getUpdateUserInfo();
          showTypeToast(msg: "性别设置成功", toastType: ToastType.SUCCESS);
          closePanel();
        },
        onError: (err) {
          showTypeToast(msg: "性别设置失败，错误：$err");
        },
        gender: type);
  }

  Future<void> scanQRCodeFromImage() async {
    closePanel();
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final String imageFilePath = pickedImage.path;
      try {
        String? result = await Scan.parse(imageFilePath);
        UserInfo? userInfo = await ApiRes.scanQrCodeAndLogin(
            code: result,
            onError: (err) {
              showTypeToast(msg: "登录错误：$err");
            });
        if (userInfo != null) {
          showTypeToast(msg: "二维码账号找回成功", toastType: ToastType.SUCCESS);
          Future.delayed(Durations.extralong4, () async {
            await Get.offAllNamed(Routes.SPLASH_PAGE);
          });
        }
      } catch (e) {
        showTypeToast(msg: "扫描失败，请检测图片是否清晰或包含二维码");
      }
    }
  }


  getUserAvatarList() async {
    Map<String, List<AvatarInfo>> avatarType = {};
    UserAvatarList? model = await ApiRes.getUserAvatar();
    if ((model?.list ?? []).isNotEmpty) {
      for (AvatarInfo item in model?.list ?? []) {
        if (avatarType[item.avatarType] != null) {
          avatarType[item.avatarType]?.add(item);
        } else {
          avatarType[item.avatarType ?? ""] = [item];
        }
      }
    }
    avatarList.value = avatarType;
  }

  Future<bool> goVipRecharge() async {
    bool isVip = false;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    await Get.toNamed(Routes.VIP_CENTER_PAGE);
    if (shareKeys.userInfo.isActiveMember ?? false) {
      isVip = true;
    }
    return isVip;
  }

  copyShareText() {
    String id = (userInfo.value.id ?? 0).toString();
    Clipboard.setData(ClipboardData(text: id)).then((_) {
      showToast(msg: "ID已复制到剪切板");
    });
  }

  @override
  void onClose() {
    super.onClose();
    nameFocusNode.dispose();
    inviteFocusNode.dispose();
  }

  void increment() => count.value++;
}
