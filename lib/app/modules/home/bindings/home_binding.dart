// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/modules/home/home_recommend_page/controllers/home_recommend_page_controller.dart';
import '../controllers/home_controller.dart';
import '../home_game_page/controllers/home_game_page_controller.dart';
import '../home_index_web/controllers/home_index_web_controller.dart';
import '../home_mine_center/controllers/home_mine_center_controller.dart';
import '../home_post_page/controllers/home_post_page_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController(), permanent: true);
    Get.put(HomeGamePageController(), permanent: true);
    Get.put(HomeIndexWebController(), permanent: true);
    Get.put(HomeRecommendPageController(), permanent: true);
    Get.put(HomePostPageController(), permanent: true);
    Get.put(HomeMineCenterController(), permanent: true);
  }
}
