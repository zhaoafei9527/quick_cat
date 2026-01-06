// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/message_center_page_controller.dart';

class MessageCenterPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageCenterPageController>(
      () => MessageCenterPageController(),
    );
  }
}
