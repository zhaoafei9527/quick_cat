import 'package:get/get.dart';

import '../controllers/novel_detail_page_controller.dart';

class NovelDetailPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NovelDetailPageController>(
      () => NovelDetailPageController(),
    );
  }
}
