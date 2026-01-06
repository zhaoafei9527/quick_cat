import 'package:get/get.dart';

import '../controllers/category_detail_page_controller.dart';

class CategoryDetailPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryDetailPageController>(
      () => CategoryDetailPageController(),
    );
  }
}
