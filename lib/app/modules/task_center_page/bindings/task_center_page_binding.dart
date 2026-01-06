// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/activity_center_controller.dart';
import '../controllers/weekly_check_in_controller.dart';
import '../controllers/welfare_task_controller.dart';

class TaskCenterPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeeklyCheckInController>(
      () => WeeklyCheckInController(),
    );
    Get.lazyPut<ActivityCenterController>(
      () => ActivityCenterController(),
    );
    Get.lazyPut<WelfareTaskController>(
      () => WelfareTaskController(),
    );
  }
}
