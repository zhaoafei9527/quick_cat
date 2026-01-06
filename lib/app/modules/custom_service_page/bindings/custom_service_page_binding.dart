// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/custom_service_page_controller.dart';
import '../controllers/system_message_controller.dart';

class CustomServicePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomServicePageController>(
      () => CustomServicePageController(),
    );

    Get.lazyPut<SystemMessageController>(
      () => SystemMessageController(),
    );
  }
}
