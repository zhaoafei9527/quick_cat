// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/model/home/config_model_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/app_util.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/toast_util.dart';

import '../data/share_key.dart';

Future showUpdateVersionDialog(BuildContext context, {VersionBean? version}) {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  return showDialog(
      context: context,
      barrierDismissible: !(version?.forcedUpdate ?? false),
      builder: (context) {
        return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
                horizontal: Dimens.pt0, vertical: Dimens.pt0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(alignment: Alignment.center, children: [
                Image.asset(R.assetsImgBgUpdate,
                    width: Dimens.pt650 - Dimens.pt10),
                Container(
                    width: Dimens.pt496,
                    height: Dimens.pt560 + Dimens.pt130,
                    padding: EdgeInsets.symmetric(horizontal: Dimens.pt20),
                    margin: EdgeInsets.only(top: Dimens.pt280),
                    child: Column(children: [
                      SizedBox(
                          height: Dimens.pt560,
                          child: SingleChildScrollView(
                              child: Text(version?.description ?? "",
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      color: Colors.white)))),
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          String uuid = await AppUtils.getDeviceId(); // 获取设备ID
                          // 将当前uuid 带入 新的APK中
                          Clipboard.setData(ClipboardData(text: uuid))
                              .then((_) {});

                          if ((version?.downloadLink ?? "").isNotEmpty) {
                            if (!await launchUrl(
                                Uri.parse(version?.downloadLink ?? ""))) {
                              throw Exception(
                                  'Could not launch ${version?.downloadLink}');
                            }
                          } else if ((version?.landpageLink ?? "").isNotEmpty) {
                            AppPages.jumpRouter(path: version?.landpageLink);
                          } else {
                            showTypeToast(msg: "下载出错，请进入联系管理");
                            if (version?.forcedUpdate ?? false) {
                              Get.toNamed(Routes.MESSAGE_CENTER_PAGE);
                            }
                          }
                        },
                        child: Container(
                            width: Dimens.pt400,
                            height: Dimens.pt70,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Color(0xFF6954E7),
                                borderRadius:
                                    BorderRadius.circular(Dimens.pt8)),
                            child: Text("立即更新",
                                style: TextStyle(
                                    fontSize: Dimens.pt32,
                                    color: Colors.white))),
                      )
                    ]))
              ]),
              SizedBox(height: Dimens.pt30),
              if (!(version?.forcedUpdate ?? false))
                Positioned(
                    right: Dimens.pt25,
                    top: Dimens.pt25,
                    child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Image.asset(R.assetsImgIconClose,
                            width: Dimens.pt48)))
            ]));
      });
}
