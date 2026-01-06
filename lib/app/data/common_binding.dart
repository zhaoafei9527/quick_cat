// 📦 Package imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/floating_ads_manager.dart';
import 'package:get/get.dart';

class CommonBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(ThemeManager());
    Get.put(FloatingAdsManager());
  }
}
