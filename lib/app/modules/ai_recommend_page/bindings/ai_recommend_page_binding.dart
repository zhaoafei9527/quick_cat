import 'package:get/get.dart';

import '../controllers/ai_recommend_page_controller.dart';

class AiRecommendPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiRecommendPageController>(
      () => AiRecommendPageController(),
    );
  }
}
