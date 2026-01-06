// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/user_terms_page_controller.dart';

class UserTermsPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserTermsPageController>(
      () => UserTermsPageController(),
    );
  }
}
