// 🐦 Flutter imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/dialog/common_dialog.dart';
import 'package:acgn_client/app/model/envelope_model.dart';
import 'package:acgn_client/app/model/home/user_info_model.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/utils/app_util.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../../../conf/api_res.dart';
import '../../../../r.dart';
import '../../../../utils/toast_util.dart';
import '../../../model/check_in_model.dart';
import '../../../model/home/gold_task_model.dart';
import '../../../routes/app_pages.dart';

class WeeklyCheckInController extends GetxController {
  late RxList<GoldTaskModel> taskList = <GoldTaskModel>[].obs;
  RxBool todayChecked = false.obs;
  RxBool yesterdayChecked = false.obs;
  RxBool todayReceive = false.obs;
  RxInt todayVipType = 0.obs;
  RxInt continuouslyDays = 0.obs;
  RxBool showLoading = true.obs;
  RxList<CheckInInfoModel> checkInfo = <CheckInInfoModel>[].obs;
  RxList<EnvelopeModel> envList = <EnvelopeModel>[].obs;
  List<String> weeklyList = ["一", "二", "三", "四", "五", "六", "天"];

  // List<String> envelopeList = ["3.8", "5.8", "8.8", "12.8", "18.8"];
  UserInfo userInfo = UserInfo();

  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo = shareKeys.userInfo;
    await getWeeklyCheckInData();
    var model = await ApiRes.getEnvelopeList();
    showLoading.value = false;
    if (model != null) {
      envList.value = model.list ?? [];
      todayVipType.value = (model.vipType ?? 0) - 1;
      todayReceive.value = model.isReceive ?? false;
    }
  }

  // 点击领取红包
  Future clickGetEnv(index) async {
    showLoading.value = true;
    EnvelopeModel? model = await ApiRes.checkInEnv();
    if ((model?.receiveType ?? 0) == 2) {
      await showPlayerCommonDialog(Get.context!,
          title: "友情提示",
          content: "恭喜获得",
          attachedText: [
            TextSpan(
                text: "${(model?.money ?? 0) / 100}",
                style: TextStyle(
                    fontSize: Dimens.pt50,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600)),
            const TextSpan(text: "元现金红包"),
          ],
          btnList: ["收下", "开一局游戏"],
          btnCall: [() => Get.back(), () => AppUtils.jumpToHome(index: 2)],
          btnActionIndex: 0);
    } else if ((model?.receiveType ?? 0) == 1) {
      showTypeToast(msg: "每日只能领取一次");
    } else {
      showTypeToast(msg: "领取失败");
    }

    var newList = await ApiRes.getEnvelopeList();
    if (newList != null) {
      envList.value = [];
      showLoading.value = false;
      todayVipType.value = (newList.vipType ?? 0) - 1;
      envList.value = newList.list ?? [];
      todayReceive.value = newList.isReceive ?? false;
    }
  }

  Future checkInAndReceive() async {
    if (!todayChecked.value) {
      showLoading.value = true;
      CheckInModel? model = await ApiRes.checkInWeeklyV3();
      bool isMoney = model?.isMoney ?? false;
      bool isMondayRewards = model?.isMondayRewards ?? false;
      if (isMoney) {
        await showPlayerCommonDialog(Get.context!,
            title: "友情提示",
            content: "恭喜获得",
            attachedText: [
              TextSpan(
                  text: "${(model?.money ?? 0) / 100}",
                  style: TextStyle(
                      fontSize: Dimens.pt50,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600)),
              const TextSpan(text: "元现金红包"),
            ],
            btnList: ["收下", "开一局游戏"],
            btnCall: [() => Get.back(), () => AppUtils.jumpToHome(index: 2)],
            btnActionIndex: 0);
      }
      if (isMondayRewards) {
        await showPlayerCommonDialog(Get.context!,
            title: "友情提示",
            content: "恭喜获得",
            attachedText: [
              TextSpan(
                  text: "1天",
                  style: TextStyle(
                      fontSize: Dimens.pt50,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600)),
              const TextSpan(text: "体验会员"),
            ],
            btnList: ["收下", "观看VIP影片"],
            btnCall: [() => Get.back(), () => AppUtils.jumpToHome(index: 1)],
            btnActionIndex: 0);
      }
      await getWeeklyCheckInData();
      showLoading.value = false;
    }
  }

  Future getWeeklyCheckInData() async {
    checkInfo.value = [];
    CheckInModel? model = await ApiRes.getWeeklyCheckListV3();
    todayChecked.value = model?.isTodayCheckin ?? false;
    yesterdayChecked.value = model?.isYesCheckin ?? false;
    continuouslyDays.value = model?.continuouslyDays ?? 0;
    // List checks = model?.checkInfo ?? [];
    //
    // if (checks.length >= 7) {
    //   for (int i = 0; i < checks.length; i++) {
    //     if (i > 0) checkInfo.add(checks[i]);
    //   }
    //   checkInfo.add(checks[0]);
    // }
    update();
  }
}
