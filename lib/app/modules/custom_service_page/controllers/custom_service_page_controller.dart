// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import '../../../../conf/api_res.dart';
import '../../../../plugins_utils/HttpRequester/http_requester.dart';
import '../../../model/home/services_model.dart';

class CustomServicePageController extends GetxController {
  late RxString customerUri = "".obs;

  @override
  void onInit() async {
    super.onInit();
    await FirebaseUtils.firebaseLogEvent(
        eventName: "CUSTOM_SERVICE",
        routePath: Routes.CUSTOM_SERVICE_PAGE);
  }

  @override
  void onReady() {
    getCustomServiceInfo();

    super.onReady();
  }

  Future<void> getCustomServiceInfo() async {
    var response = await post<ServicesModel, ServicesModel>(ApiRes.customConfig,
        data: {}, decodeType: ServicesModel());

    response.when(success: (ServicesModel? model) async {
      customerUri.value = model?.sign ?? "";
      update();
    }, failure: (String msg, int code) {
      debugPrint("获取客服配置出现故障，$msg");
      customerUri.value = "http://121.127.231.205:9080/#/home";
      update();
    });
  }

}
