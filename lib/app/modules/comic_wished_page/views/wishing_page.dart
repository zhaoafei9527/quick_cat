import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/text_field.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/comic_wished_page_controller.dart';

class WishingPage extends GetView<ComicWishedPageController> {
  const WishingPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<ComicWishedPageController>(builder: (logic) {
      return Scaffold(
          appBar: getCommonAppBar("立即许愿"),
          backgroundColor: theme.getColor(ThemeColor.bg),
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: screen.screenWidth,
                        height: Dimens.pt72,
                        color: theme.getColor(ThemeColor.bgGrey),
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt20),
                        child: GetCommonTextField(
                            controller: logic.titleController,
                            maxLength: 25,
                            inputType: TextInputType.text,
                            hintStyle: TextStyle(
                                color: theme.getColor(ThemeColor.textGrey),
                                fontSize: Dimens.pt22),
                            hintText: "标题（必填）请尽可能详细填写漫画标题",
                            onSubmitted: (String text) => {})),
                    SizedBox(height: Dimens.pt30),
                    // Container(
                    //     width: screen.screenWidth,
                    //     height: Dimens.pt383,
                    //     color: theme.getColor(ThemeColor.bgGrey),
                    //     padding: EdgeInsets.symmetric(horizontal: Dimens.pt20),
                    //     child: GetCommonTextField(
                    //         controller: logic.wishContentController,
                    //         inputType: TextInputType.text,
                    //         hintStyle: TextStyle(
                    //             color: theme.getColor(ThemeColor.textGrey),
                    //             fontSize: Dimens.pt22),
                    //         maxLines: 12,
                    //         hintText: "作品描述/推荐理由/描述的越详细找到您期待的作品的概率越大",
                    //         onSubmitted: (String text) => {})),
                    SizedBox(height: Dimens.pt30),
                    GestureDetector(
                      onTap: () => logic.submitWishContent(),
                      child: Container(
                          width: screen.screenWidth,
                          height: Dimens.pt80,
                          color: theme.getColor(ThemeColor.primary),
                          child: Center(
                              child: Text("确定",
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      fontWeight: FontWeight.w600,
                                      color: theme.getColor(ThemeColor.bg))))),
                    ),
                    SizedBox(height: Dimens.pt70),
                    Text("温馨提示",
                        style: TextStyle(
                            fontSize: Dimens.pt38,
                            color: theme.getColor(ThemeColor.primary))),
                    SizedBox(height: Dimens.pt20),
                    Text("1.会员用户每一期只能许愿一次！\n2.禁止输入任何违规广告信息,否则永久封禁！",
                        style: TextStyle(
                            fontSize: Dimens.pt24,
                            color: theme.getColor(ThemeColor.textYellow))),
                  ])));
    });
  }
}
