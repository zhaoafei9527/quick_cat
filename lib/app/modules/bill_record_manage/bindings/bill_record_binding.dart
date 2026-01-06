// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/bill_record_controller.dart';

class BillRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillRecordController>(
      () => BillRecordController(),
    );
  }
}
