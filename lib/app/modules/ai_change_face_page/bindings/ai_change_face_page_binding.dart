import 'package:get/get.dart';

import '../controllers/ai_change_face_page_controller.dart';

class AiChangeFacePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiChangeFacePageController>(
      () => AiChangeFacePageController(),
    );
  }
}
