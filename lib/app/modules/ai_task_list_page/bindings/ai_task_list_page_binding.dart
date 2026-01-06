import 'package:get/get.dart';

import '../controllers/ai_task_list_page_controller.dart';

class AiTaskListPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiTaskListPageController>(
      () => AiTaskListPageController(),
    );
  }
}
