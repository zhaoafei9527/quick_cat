// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/invited_page_controller.dart';

class InvitedPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvitedPageController>(
      () => InvitedPageController(),
    );
  }
}
