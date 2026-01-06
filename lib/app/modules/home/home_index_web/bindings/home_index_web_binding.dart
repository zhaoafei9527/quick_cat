// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/home_index_web_controller.dart';

class HomeIndexWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeIndexWebController>(
      () => HomeIndexWebController(),
    );
  }
}
