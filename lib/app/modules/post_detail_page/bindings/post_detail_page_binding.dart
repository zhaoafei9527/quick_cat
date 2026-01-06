// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/post_detail_page_controller.dart';

class PostDetailPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostDetailPageController>(
      () => PostDetailPageController(),
    );
  }
}
