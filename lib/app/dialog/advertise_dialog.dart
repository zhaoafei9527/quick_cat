// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import '../../plugins_utils/ImageLoader/ImageLoader.dart';

Future showAdvertiseDialog(BuildContext context, Advertise? ads) async {
  return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            // insetPadding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                  onTap: () {
                    AppPages.jumpRouter(path: ads?.href, id: ads?.id);
                  },
                  child: ImageLoader.withP(ads?.cover ?? "",)
                      .load()),
              const SizedBox(height: 40),
              GestureDetector(
                  onTap: () => Get.back(),
                  child: Image.asset(R.assetsImgIconSearchAdvertise, width: 32))
            ]));
      });
}
