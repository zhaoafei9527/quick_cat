import 'package:get/get.dart';

import '../controllers/comic_reader_page_controller.dart';

class ComicReaderPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComicReaderPageController>(
      () => ComicReaderPageController(),
    );
  }
}
