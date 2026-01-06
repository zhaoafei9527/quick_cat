// 🐦 Flutter imports:

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/vip_center_page_controller.dart';

class VipCenterPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VipCenterPageController>(
      () => VipCenterPageController(),
    );
  }
}
