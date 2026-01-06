// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/short_video_player_controller.dart';

class ShortVideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShortVideoPlayerController());
    // Get.lazyPut<ShortVideoPlayerController>(
    //   () => ShortVideoPlayerController(),
    // );
  }
}
