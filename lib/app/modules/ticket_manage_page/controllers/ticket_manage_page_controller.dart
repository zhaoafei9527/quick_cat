// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/views/page_pull_view.dart';
import 'package:acgn_client/utils/toast_util.dart';
import '../../../../conf/api_res.dart';
import '../../../../plugins_utils/HttpRequester/http_requester.dart';
import '../../../data/enum.dart';
import '../../../data/share_key.dart';
import '../../../model/home/user_info_model.dart';
import '../../../model/recharge_model.dart';

class TicketManagePageController extends GetxController {
  final count = 0.obs;
  RxBool initOk = false.obs;
  RxString title = "".obs;
  RxInt type = 0.obs;
  GlobalKey<PagePullViewState> redeemKey = GlobalKey();
  RxInt lotteryTicket = 0.obs; // 已经使用的抽奖券
  RxInt recentLottery = 0.obs; // 现有的
  RxInt movieTicket = 0.obs; // 已经使用的观影券
  RxInt recentMovie = 0.obs; // 现有的
  RxList<RedeemInfo> redeemList = <RedeemInfo>[].obs;
  FocusNode redeemFocusNode = FocusNode();
  TextEditingController redeemField = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    UserInfo userInfo = shareKeys.userInfo;

    movieTicket.value = userInfo.useMovieTickets??0; //已使用观影券数
    recentMovie.value = userInfo.movieTickets??0; //未使用观影券数
    lotteryTicket.value = userInfo.lotteryUsedCount??0; //已使用抽奖券数
    recentLottery.value = userInfo.lotteryFreeCount??0; //未使用抽奖券数

    type.value = (Get.arguments?['type'] ?? 0);
    if (type >= 0) {
      title.value = type.value == 1 ? "抽奖券" : "观影券";
      if (type.value == 3) {
        title.value = "兑换码";
        // RechargeModel? model = await ApiRes.getRedeemList();
        // if(model!=null) redeemList.value
      }
    }
    initOk.value = true;
  }



  Future<void> useRedeemCode() async {
    if ((redeemField.text ?? "").isNotEmpty) {
      await ApiRes.useRedeemCode(
          code: redeemField.text,
          onSuccess: () {
            showTypeToast(msg: "兑换成功", toastType: ToastType.SUCCESS);
          },
          onError: (msg) {
            showToast(msg: "兑换出错:$msg");
          });
      redeemKey.currentState?.refresh();
      ShareKeys shareKeys = Get.find();
      shareKeys.getUserInfo(needUpdate: true);
    } else {
      showToast(msg: "请输入兑换码后尝试");
    }
  }

  Future<void> logOut(devID) async {
    var response = await post<UserInfo, UserInfo>(ApiRes.logOut,
        data: {"devID": devID}, decodeType: UserInfo());

    response.when(success: (UserInfo? model) async {
      ShareKeys shareKeys = Get.find<ShareKeys>();
      shareKeys.setUserInfo(model);
      Get.toNamed(Routes.SPLASH_PAGE);
    }, failure: (String msg, int code) {
      debugPrint("退出登录出现故障，$msg");
      showToast(msg: "退出登录出现故障");
      update();
    });
  }

  void increment() => count.value++;
}
