// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../../data/share_key.dart';
import '../../../model/home/user_info_model.dart';

class SubTermsPageController extends GetxController {
  final count = 0.obs;
  List<String> levelCardText = [];
  var userInfo = UserInfo().obs;
  @override
  Future<void> onInit() async {
    levelCardText = ["1.8", "1.8", "3.8", "5.8", "8.8", "12.8", "18.8"];
    super.onInit();

    ShareKeys shareKey = Get.find<ShareKeys>();
    userInfo.value = await shareKey.getUserInfo();
  }



  void increment() => count.value++;
}
