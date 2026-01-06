import 'package:get/get.dart';

import '../controllers/rank_list_page_controller.dart';

class RankListPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RankListPageController>(
      () => RankListPageController(),
    );
  }
}
