// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/bind_mobile_page_controller.dart';

class BindMobilePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BindMobilePageController>(
      () => BindMobilePageController(),
    );
  }
}
