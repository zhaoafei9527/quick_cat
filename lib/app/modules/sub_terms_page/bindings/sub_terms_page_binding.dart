// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/sub_terms_page_controller.dart';

class SubTermsPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubTermsPageController>(
      () => SubTermsPageController(),
    );
  }
}
