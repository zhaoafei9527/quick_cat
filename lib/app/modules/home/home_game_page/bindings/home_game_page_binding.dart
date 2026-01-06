// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/modules/home/home_game_page/controllers/game_web_view_controller.dart';

class HomeGamePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameWebViewPageController>(
      () => GameWebViewPageController(),
    );
  }
}
