import 'package:get/get.dart';

import '../controllers/watch_history_page_controller.dart';

class WatchHistoryPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WatchHistoryPageController>(
      () => WatchHistoryPageController(),
    );
  }
}
