// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/model/home/user_info_model.dart';
import 'package:acgn_client/app/model/task_center_model.dart';
import 'package:acgn_client/utils/toast_util.dart';
import '../../../../conf/api_res.dart';
import '../../../../utils/app_util.dart';
import '../../../../utils/dimens.dart';
import '../../../dialog/common_dialog.dart';
import '../../../themes/app_colors.dart';

class WelfareTaskController extends GetxController {
  RxInt checkedDays = 0.obs;
  RxBool todayChecked = false.obs;
  RxBool initOk = false.obs;
  RxList<TaskInfoList> taskInfoList = <TaskInfoList>[].obs;
  RxList<PrizeInfoList> prizeInfoList = <PrizeInfoList>[].obs;

  UserInfo userInfo = UserInfo();

  @override
  void onInit() async {
    // super.onInit();
    // ShareKeys shareKeys = Get.find<ShareKeys>();
    // userInfo = shareKeys.userInfo;
    // await getCheckInRules();
    // await getTaskNetData();
    // initOk.value = true;
  }
}
