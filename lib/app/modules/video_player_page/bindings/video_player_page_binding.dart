// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/video_player_page_controller.dart';

class VideoPlayerPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayerPageController>(
      () => VideoPlayerPageController(),
    );
  }
}
