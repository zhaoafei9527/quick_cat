// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/tag_detail_page_controller.dart';

class TagDetailPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TagDetailPageController>(
      () => TagDetailPageController(),
    );
  }
}
