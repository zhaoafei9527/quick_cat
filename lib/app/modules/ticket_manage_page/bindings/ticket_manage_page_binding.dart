// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/ticket_manage_page_controller.dart';

class TicketManagePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketManagePageController>(
      () => TicketManagePageController(),
    );
  }
}
