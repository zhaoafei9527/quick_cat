// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/model/bill_info_model.dart';
import 'package:acgn_client/conf/api_res.dart';

class GameDetailsPageController extends GetxController {
  final count = 0.obs;
  int? id;
  int? billType;
  RxBool initOk = false.obs;
  Rx<BillDetailsInfo>? billInfo = BillDetailsInfo().obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments?['id'] != null) {
      var ids = Get.arguments?['id'];
      var billTypes = Get.arguments?['billType'];
      if (ids.runtimeType == String) {
        id = int.tryParse(ids) ?? 0;
      }
      if (billTypes.runtimeType == String) {
        billType = int.tryParse(billTypes) ?? 0;
      }
    }
  }

  @override
  void onReady() async {
    super.onReady();
    BillDetailsInfo? bill =
        await ApiRes.getBillInfo(id: id, billType: billType);
    if (bill != null) billInfo?.value = bill;
    initOk.value = true;
    update();
  }


  void increment() => count.value++;
}
