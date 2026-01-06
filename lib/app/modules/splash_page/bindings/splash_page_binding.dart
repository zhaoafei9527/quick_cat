// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import '../controllers/splash_page_controller.dart';

class SplashPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShareKeys(), permanent: true);

    Get.lazyPut<SplashPageController>(
      () => SplashPageController(),
    );
  }
}
