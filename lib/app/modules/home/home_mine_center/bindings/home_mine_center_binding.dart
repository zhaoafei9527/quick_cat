// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/home_mine_center_controller.dart';

class HomeMineCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeMineCenterController>(
      () => HomeMineCenterController(),
    );
  }
}
