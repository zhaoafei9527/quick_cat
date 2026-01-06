// 📦 Package imports:
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/floating_ads_manager.dart';
import 'package:get/get.dart';

class CommonBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(ThemeManager());
    Get.put(FloatingAdsManager());
  }
}
