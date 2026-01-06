// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import '../../../../utils/dimens.dart';
import '../../../widget/common_widget.dart';
import '../controllers/custom_service_page_controller.dart';

class CustomServicePageView extends GetView<CustomServicePageController> {
  const CustomServicePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomServicePageController>(builder: (logic) {
      return Scaffold(
          backgroundColor: AppColors.bgColor,
          appBar: buildAppBar(title: 'appBar_customService'.tr),
          body: logic.customerUri.value.isNotEmpty
              ? InAppWebView(
                  initialUrlRequest:
                      URLRequest(url: WebUri(logic.customerUri.value)))
              : Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      const CupertinoActivityIndicator(
                          color: AppColors.primaryColor),
                      Text("加载中",
                          style: TextStyle(
                              fontSize: Dimens.pt14, color: Colors.black))
                    ])));
    });
  }
}
