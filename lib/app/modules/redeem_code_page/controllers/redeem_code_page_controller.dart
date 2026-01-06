// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/logger_utils.dart';
import '../../../../conf/api_res.dart';
import '../../../../plugins_utils/HttpRequester/src/net_client.dart';

class RedeemCodePageController extends GetxController {
  TextEditingController redeemCode = TextEditingController(); //兑换码
  // bool redeemCodeBool = false;
  final redeemCodeBool = false.obs;
  Future<void> submitRedeemCode() async {
    var response = await post(ApiRes.redeemcodeUse, data: {"code": redeemCode});
    response.when(success: (model) async {
      redeemCodeBool.value = false;
      log.i("redeem_code_submit","兑换码请求成功");
    }, failure: (String msg, int code) {
      log.i("redeem_code_submit","兑换码错误code $code");
      redeemCodeBool.value = true;
    });
  }
}
