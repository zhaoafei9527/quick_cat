// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/home/pay_list_model.dart';
import 'package:quick_cat_client/app/model/home/services_model.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/r.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

// 🌎 Project imports:
import '../../../../plugins_utils/FirebaseUtils/firebse_utils.dart';
import '../../../../utils/toast_util.dart';
import '../../../model/home/card_list_model.dart';
import '../../../model/home/get_paid_url_model.dart';
import '../../../model/home/payment_list_model.dart';
import '../../../routes/app_pages.dart';

class VipCenterPageController extends GetxController {
  final count = 0.obs;
  final result = VipList().obs;
  final initOk = false.obs;
  RxInt selectedRectangleIndex = (-1).obs;
  RxInt amountSelect = (0).obs;
  RxBool showLoading = true.obs;
  RxDouble getBalanceIng = .0.obs;
  late Rx<UserInfo> userInfo = UserInfo().obs;
  RxBool showOnlineRecharge = false.obs;
  RxString downloadPath = "".obs;
  RxString descPath = "".obs;
  TextEditingController priceController = TextEditingController();
  RxInt inputAmount = 0.obs;
  RxInt inputVipDay = 0.obs;

  // late List<Map<String, dynamic>> payWayList = [];
  late List<Map<String, dynamic>> payAmount = [];
  RxList<PaymentDataList> payWayList = <PaymentDataList>[].obs;
  RxList<PayModes> amountMenu = <PayModes>[].obs;
  RxList<OnlineChargeModes> onLineRecharger = <OnlineChargeModes>[].obs;

  PayModes? get currentPayMode =>
      amountMenu.isNotEmpty ? amountMenu[amountSelect.value] : null;

  int? get currentRechargeRangeType => currentPayMode?.rechargeRangeType;

  bool get showInputPriceView =>
      !showOnlineRecharge.value && currentRechargeRangeType == 2;

  bool get showNoInputPriceView =>
      !showOnlineRecharge.value && currentRechargeRangeType == 1;

  @override
  void onInit() async {
    super.onInit();
    showLoading.value = false;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo.value = await shareKeys.getUserInfo();
    PaymentList? model = await ApiRes.getRechargePayment();
    OnlineRecharge? onlineModel = await ApiRes.getOnlineRechargeList();

    if (model != null) {
      for (var bank in model.list ?? []) {
        if (bank.rechargeType == 1) {
          bank.icon = R.assetsImgIconPayWechat;
        } else if (bank.rechargeType == 2) {
          bank.icon = R.assetsImgIconPayAli;
        } else if (bank.rechargeType == 3) {
          bank.icon = R.assetsImgIconPayUnion;
        } else if (bank.rechargeType == 4) {
          bank.icon = R.assetsImgIconPaySzrmb;
        } else if (bank.rechargeType == 5) {
          bank.icon = R.assetsImgIconPayQq;
        } else if (bank.rechargeType == 6) {
          bank.icon = R.assetsImgIconPayUsdt;
        } else if (bank.rechargeType == 7) {
          bank.icon = R.assetsImgIconPayOnline;
        } else if (bank.rechargeType == 8) {
          bank.icon = R.assetsImgIconPayBobi;
        } else if (bank.rechargeType == 9) {
          bank.icon = R.assetsImgIconPayGopay;
        } else if (bank.rechargeType == 10) {
          bank.icon = R.assetsImgIconPayOkpay;
        }
      }
      payWayList.value = model.list ?? [];
      onLineRecharger.value = onlineModel?.list ?? [];
    }
    selectRectangle(0);
    initOk.value = true;
    update();
  }

  @override
  void onReady() async {
    super.onReady();
    await FirebaseUtils.firebaseLogEvent(
      eventName: "VIP_CENTER_CHARGE",
      routePath: Routes.VIP_CENTER_PAGE,
    );
  }

  Future<void> selectRectangle(int index) async {
    //获取金额菜单
    selectedRectangleIndex.value = index;
    amountSelect.value = 0;
    priceController.clear();
    inputAmount.value = 0;
    inputVipDay.value = 0;
    showLoading.value = true;
    descPath.value = payWayList[index].descUrl ?? "";
    downloadPath.value = payWayList[index].downloadUrl ?? "";
    // 人工支付 单独处理
    if (payWayList[index].rechargeType == 7) {
      showOnlineRecharge.value = true;
      amountMenu.clear();
      showLoading.value = false;
    } else {
      showOnlineRecharge.value = false;
      amountMenu.clear();
      int? rechargeType = payWayList[index].rechargeType;
      PayList? model =
          await ApiRes.getGoldpaytyPeinfo(rechargeType: rechargeType);
      showLoading.value = false;
      if (model != null) {
        amountMenu.value = model.payModes ?? [];
      }
    }
  }

  void vipAmountChange(int index) {
    amountSelect.value = index;
  }

  void onInputAmountChanged(String text) {
    final sanitizedText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedText != text) {
      priceController.value = TextEditingValue(
        text: sanitizedText,
        selection: TextSelection.collapsed(offset: sanitizedText.length),
      );
    }
    final amount = int.tryParse(sanitizedText) ?? 0;
    inputAmount.value = amount;
    final amountRange = _amountRangeByAmount(amount);
    if (amountRange == null) {
      inputVipDay.value = 0;
      return;
    }
    final vipDayRangeList = currentPayMode?.vipDayRangeList ?? [];
    for (final item in vipDayRangeList) {
      if (item.amountRange == amountRange) {
        inputVipDay.value = item.days ?? 0;
        return;
      }
    }
    inputVipDay.value = 0;
  }

  int? _amountRangeByAmount(int amount) {
    if (amount >= 50 && amount <= 200) return 1;
    if (amount >= 201 && amount <= 500) return 2;
    if (amount >= 501 && amount <= 2000) return 3;
    if (amount >= 2001 && amount <= 5000) return 4;
    if (amount >= 5001 && amount <= 20000) return 5;
    if (amount > 20000) return 6;
    return null;
  }

  void goWithdrawCash() async {
    UserInfo userInfo = Get.find<ShareKeys>().userInfo;
    if (userInfo.mobile == null || userInfo.mobile?.isEmpty == true) {
      showPlayerCommonDialog(Get.context!,
          title: "温情提示",
          content:
          "当前为游客账号,为避免账号丢失,请绑定手\n机号码升级成正式账号！\n正式账号特权：\n1.立即获得3元现金\n2.可提现APP余额\n3.可通过手机登陆",
          btnList: ["立即绑定"],
          btnCall: [
                () {
              Get.back();
              Get.toNamed(Routes.BIND_MOBILE_PAGE);
            }
          ],
          btnActionIndex: 0);
    } else {
      Get.toNamed(Routes.WITHDRAW_TYPE_PAGE);
    }
  }

  submitRecharge() async {
    //立即充值
    if (amountMenu.isEmpty) {
      showToast(msg: "请选择充值金额");
      return;
    }
    if (showInputPriceView && inputAmount.value <= 50) {
      showToast(msg: "请输入充值金额，金额必须大于等于50元");
      return;
    }

    showLoading.value = true;
    int? payAmount = showInputPriceView
        ? inputAmount.value * 100
        : currentPayMode?.payAmount; //支付金额
    int? payModeType =
        payWayList[selectedRectangleIndex.value].rechargeType; //支付方式
    int? productId = currentPayMode?.id; //商品Id(金币Id，会员卡Id，观影券Id)
    GetPaidUrl? model = await ApiRes.getRechargeSubmit(
        payAmount: payAmount,
        payMode: payModeType,
        productId: productId,
        rchgUse: 3);
    showLoading.value = false;
    if (model != null) {
      if (kIsWeb) {
        html.window.localStorage["rechargeUrl"] = model.payUrl ?? "";
        html.Element? link = html.document.getElementById("jumpToBrowser");
        link?.click();
      } else {
        await AppPages.jumpRouter(path: 'launch://${model.payUrl}');
      }
    } else {
      showToast(msg: "获取支付失败！请重新点击充值");
    }
    showPlayerCommonDialog(Get.context!,
        title: "友情提示",
        attachedText: [
          TextSpan(
              text: "赢取高额奖金，提现秒到账！如遇充值未到账，请耐心等待10-15分钟！",
              style: TextStyle(color: Color(0xFF8A8785)))
        ],
        content: "充值的余额可用于棋牌游戏娱乐! ",
        btnList: ["知道了"],
        btnCall: [() => Get.back()],
        btnActionIndex: 0);
  }

  Future<void> getCustomServiceInfo({int? type, String? id}) async {
    showLoading.value = true;
    ServicesModel? model = await ApiRes.getCustomServers();
    String? queryString =
        (model?.sign!.split('?').length)! > 1 ? model?.sign?.split('?')[1] : '';
    showLoading.value = false;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    // test ： https://h5.htqhfqp.com/
    Get.toNamed(Routes.ACTIVITY_WEB_PAGE, arguments: {
      "title": "充值客服",
      "uri":
          "${shareKeys.baseUrl}/zoudoboh-h5service/?theme=theme3&$queryString&pType=$type&id=$id#/home"
    });
  }

  void increment() => count.value++;

  @override
  void onClose() {
    priceController.dispose();
    super.onClose();
  }
}
