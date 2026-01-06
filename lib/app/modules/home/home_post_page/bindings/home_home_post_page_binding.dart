// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/home_post_page_controller.dart';

class HomePostPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomePostPageController>(
      () => HomePostPageController(),
    );
  }
}
