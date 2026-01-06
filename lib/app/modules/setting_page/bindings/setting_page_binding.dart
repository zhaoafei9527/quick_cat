// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/scan_qr_code_controller.dart';
import '../controllers/setting_page_controller.dart';

class SettingPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingPageController>(
      () => SettingPageController(),
    );
    Get.lazyPut<ScanQrCodeController>(
          () => ScanQrCodeController(),
    );
  }
}
