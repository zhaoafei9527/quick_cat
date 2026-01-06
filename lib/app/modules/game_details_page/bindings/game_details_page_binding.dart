// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/game_details_page_controller.dart';

class GameDetailsPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameDetailsPageController>(
      () => GameDetailsPageController(),
    );
  }
}
