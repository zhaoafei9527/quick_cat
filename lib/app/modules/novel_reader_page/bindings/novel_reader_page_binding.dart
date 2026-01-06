import 'package:get/get.dart';

import '../controllers/novel_reader_page_controller.dart';

class NovelReaderPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NovelReaderPageController>(
      () => NovelReaderPageController(),
    );
  }
}
