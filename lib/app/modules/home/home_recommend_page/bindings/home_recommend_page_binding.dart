// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/home_recommend_page_controller.dart';

class HomeRecommendPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRecommendPageController>(
      () => HomeRecommendPageController(),
    );
  }
}
