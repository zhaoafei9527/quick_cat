// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/redeem_code_page_controller.dart';

class RedeemCodePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RedeemCodePageController>(
      () => RedeemCodePageController(),
    );
  }
}
