// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/post_topic_page_controller.dart';

class PostTopicPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostTopicPageController>(
      () => PostTopicPageController(),
    );
  }
}
