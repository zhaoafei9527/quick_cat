// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/topic_detail_page_controller.dart';

class TopicDetailPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopicDetailPageController>(
      () => TopicDetailPageController(),
    );
  }
}
