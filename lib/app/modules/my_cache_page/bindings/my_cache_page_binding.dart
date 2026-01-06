import 'package:get/get.dart';

import '../controllers/my_cache_page_controller.dart';

class MyCachePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyCachePageController>(
      () => MyCachePageController(),
    );
  }
}
