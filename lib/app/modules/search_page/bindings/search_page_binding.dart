// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/search_page_controller.dart';

class SearchPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchPageController>(
      () => SearchPageController(),
    );
  }
}
