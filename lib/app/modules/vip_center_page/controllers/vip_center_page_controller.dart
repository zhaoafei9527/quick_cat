// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/home/pay_list_model.dart';
import 'package:quick_cat_client/app/model/home/services_model.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
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

  // late List<Map<String, dynamic>> payWayList = [];
  late List<Map<String, dynamic>> payAmount = [];
  RxList<PaymentDataList> payWayList = <PaymentDataList>[].obs;
  RxList<PayModes> amountMenu = <PayModes>[].obs;
  RxList<OnlineChargeModes> onLineRecharger = <OnlineChargeModes>[].obs;

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
          // bank.icon = R.assetsImgIconPayOnline;
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
    showLoading.value = true;
    // 人工支付 单独处理
    if (payWayList[index].rechargeType == 7) {
      showOnlineRecharge.value = true;
      showLoading.value = false;
    } else {
      showOnlineRecharge.value = false;
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

  void goWithdrawCash() async {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    if ((shareKeys.userInfo.mobile ?? "").isNotEmpty) {
      Get.toNamed(Routes.WITHDRAW_CASH_BANK);
    } else {
      showPlayerCommonDialog(Get.context!,
          title: "友情提示",
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
    }
  }

  submitRecharge() async {
    //立即充值
    showLoading.value = true;
    int? payAmount = amountMenu[amountSelect.value].payAmount; //支付金额
    int? payModeType =
        payWayList[selectedRectangleIndex.value].rechargeType; //支付方式
    int? productId = amountMenu[amountSelect.value].id; //商品Id(金币Id，会员卡Id，观影券Id)
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
      showTypeToast(msg: "获取支付失败！请重新点击充值");
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
}
