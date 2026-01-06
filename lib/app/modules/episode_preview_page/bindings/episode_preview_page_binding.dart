import 'package:get/get.dart';

import '../controllers/episode_preview_page_controller.dart';

class EpisodePreviewPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EpisodePreviewPageController>(
      () => EpisodePreviewPageController(),
    );
  }
}
