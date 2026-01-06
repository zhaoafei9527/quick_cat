// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';

Future showAnnounceDialog(BuildContext context) async {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  Announcement? announceInfo = shareKeys.announceInfo;
  if (announceInfo == null) return;
  ThemeManager theme = Get.find<ThemeManager>();
  return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
                horizontal: Dimens.pt0, vertical: Dimens.pt0),
            child: Stack(alignment: Alignment.center, children: [
              Image.asset(R.assetsImgBgAnnounce,
                  width: Dimens.pt650 - Dimens.pt10),
              Container(
                  width: Dimens.pt496,
                  height: Dimens.pt560 + Dimens.pt130,
                  padding: EdgeInsets.symmetric( horizontal: Dimens.pt20),
                  margin: EdgeInsets.only(top: Dimens.pt280),
                  child: Column(children: [
                    SizedBox(
                        height: Dimens.pt560,
                        child: SingleChildScrollView(
                            child: Text(announceInfo.content ?? "",
                                style: TextStyle(
                                    fontSize: Dimens.pt26,
                                    color: Colors.white)))),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        if ((announceInfo.jumpUrl ?? "").isNotEmpty) {
                          AppPages.jumpRouter(path: announceInfo.jumpUrl);
                        } else {
                          Get.back();
                        }
                      },
                      child: Container(
                          width: Dimens.pt400,
                          height: Dimens.pt70,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xFF6954E7),
                              borderRadius: BorderRadius.circular(Dimens.pt8)),
                          child: Text("我知道了",
                              style: TextStyle(
                                  fontSize: Dimens.pt32, color: Colors.white))),
                    )
                  ]))
            ]));
      });
}
