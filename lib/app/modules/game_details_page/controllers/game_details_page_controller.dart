// 📦 Package imports:
import 'package:get/get.dart';
import 'package:quick_cat_client/app/data/enum.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/model/bill_info_model.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/text_util.dart';

class GameDetailsPageController extends GetxController {
  final count = 0.obs;
  int? id;
  int? billType;
  int? gamePlatform;
  String? gameName;
  String? icon;
  RxBool initOk = false.obs;
  RxBool showDateChoose = false.obs;
  RxInt selectDateValue = 0.obs;
  RxInt gameBillId = 0.obs;
  Rx<BillDetailsInfo>? billInfo = BillDetailsInfo().obs;
  RxList<gameRecordsBean> gameBills = <gameRecordsBean>[].obs;
  RxList<Map<String, dynamic>> dateCodesList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    id = TextUtil.getIntArgument('id');
    billType = TextUtil.getIntArgument('billType');
    if (billType == BillInfoType.billTypeGame.index) {
      icon = Get.arguments["icon"] ?? "";
      gameName = Get.arguments["gameName"] ?? "";
      gamePlatform = TextUtil.getIntArgument('gamePlatform');
      dateCodesList.value = [
        {"name": "今日", "value": 1},
        {"name": "本周", "value": 2},
        {"name": "本月", "value": 3},
        {"name": "全部", "value": 0}
      ];
    }
  }

  @override
  void onReady() async {
    super.onReady();
    if (billType == BillInfoType.billTypeGame.index) {
      // await ApiRes.getGameBillDetails(
      //     dayType: 1, gamePlatform: gamePlatform ?? 0, pageNum: 1);
      initOk.value = true;
    } else {
      BillDetailsInfo? bill =
          await ApiRes.getBillInfo(id: id, billType: billType);
      if (bill != null) billInfo?.value = bill;
      initOk.value = true;
    }

    update();
  }

  void increment() => count.value++;

  void chooseDate(int index) {
    if (index < 0 || index >= dateCodesList.length) return;
    selectDateValue.value = index;
    showDateChoose.value = false;
  }
}
