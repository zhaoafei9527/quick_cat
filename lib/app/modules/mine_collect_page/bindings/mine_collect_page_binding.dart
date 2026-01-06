// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/mine_collect_page_controller.dart';

class MineCollectPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MineCollectPageController>(
      () => MineCollectPageController(),
    );
  }
}
