// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/update_dialog.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/utils/toast_util.dart';

class AboutUsPageController extends GetxController {
  final count = 0.obs;



  Future<void> checkVersion() async {
    if (!kIsWeb) {
      ShareKeys shareKeys = Get.find<ShareKeys>();
      VersionBean? version = shareKeys.version;
      if (version != null && (version.hasNewVersion ?? false)) {
        await showUpdateVersionDialog(Get.context!, version: shareKeys.version);
      } else {
        showToast(msg: "当前已经是最新版本");
      }
    }
  }


  void increment() => count.value++;
}
