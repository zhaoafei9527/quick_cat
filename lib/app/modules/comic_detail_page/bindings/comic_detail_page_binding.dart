import 'package:get/get.dart';

import '../controllers/comic_detail_page_controller.dart';

class ComicDetailPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComicDetailPageController>(
      () => ComicDetailPageController(),
    );
  }
}
