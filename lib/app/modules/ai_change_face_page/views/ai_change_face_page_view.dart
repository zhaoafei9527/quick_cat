import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../themes/theme_manager.dart';
import '../../ai_recommend_page/views/ai_off_clothes_page.dart';
import '../controllers/ai_change_face_page_controller.dart';

class AiChangeFacePageView extends GetView<AiChangeFacePageController> {
  const AiChangeFacePageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<AiChangeFacePageController>(
        builder: (AiChangeFacePageController logic) {
      return Scaffold(
          appBar: getCommonAppBar("AI换脸"),
          backgroundColor: theme.getColor(ThemeColor.bg),
          body: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                  child: ImageLoader.withP(logic.faceImageUrl,
                          height: Dimens.pt365)
                      .load()),
              SizedBox(height: Dimens.pt30),
              Text("上传您的素材",
                  style: TextStyle(
                      fontSize: Dimens.pt38,
                      color: theme.getColor(ThemeColor.primary))),
              SizedBox(height: Dimens.pt30),
              buildUploadButton("换脸",
                  padding: .0,
                  localPath: logic.localPath.value,
                  uploadComplete: logic.uploadComplete.value,
                  onClearImage: () => logic.localPath.value = "",
                  onTap: logic.onUploadImage),
              SizedBox(height: Dimens.pt30),
              buildStartGenerateButton(logic.price,
                  padding: .0,
                  imageUrl: logic.imageUrl.value,
                  onTap: logic.startAddTask,
                  needImage: true),
              SizedBox(height: Dimens.pt40),
              Text(logic.desc,
                  style: TextStyle(
                      fontSize: Dimens.pt24,
                      color: theme.getColor(ThemeColor.textGrey))),
              SizedBox(height: Dimens.pt40),
              Text("效果图展示",
                  style: TextStyle(
                      fontSize: Dimens.pt38,
                      color: theme.getColor(ThemeColor.primary))),
              SizedBox(height: Dimens.pt30),
              ImageLoader.withP(
                      "hex/image/1c/29/64f/3d/bc21cf72ca59d8164f0dffb29f853dd4.png",
                      width: screen.screenWidth)
                  .load()
            ]),
          )));
    });
  }
}
