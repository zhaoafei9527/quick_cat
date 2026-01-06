import 'package:get/get.dart';

import '../controllers/comic_wished_page_controller.dart';

class ComicWishedPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComicWishedPageController>(
      () => ComicWishedPageController(),
    );
  }
}
