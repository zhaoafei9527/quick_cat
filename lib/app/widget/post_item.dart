// 🐦 Flutter imports:
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/dialog/comment_dialog.dart';
import 'package:quick_cat_client/app/widget/post_common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import '../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../model/post_list_model.dart';
import '../routes/app_pages.dart';

class PostItem extends StatefulWidget {
  PostBrief? postBrief;
  int? categoryId;
  double? padding;

  PostItem({super.key, this.postBrief, this.categoryId, this.padding});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  PostBrief? postBrief;
  late TapGestureRecognizer _tapRecognizer;
  List<String>? images;
  bool haveVideo = false;

  @override
  void initState() {
    super.initState();
    postBrief = widget.postBrief;
    images = postBrief?.node?.imgs ?? [];
    PostBase? base = postBrief?.base;
    if ((base?.videoCover ?? "").isNotEmpty) {
      haveVideo = true;
      images?.add(base?.videoCover ?? "");
    }
    _tapRecognizer = TapGestureRecognizer()..onTap = _handleTap; // 绑定点击事件处理函数
  }

  @override
  void dispose() {
    _tapRecognizer.dispose(); // 释放 GestureRecognizer 资源
    super.dispose();
  }

  void _handleTap() {
    int? topicId = postBrief?.base?.topicId;
    String? name = postBrief?.base?.topicName;

    Get.toNamed(Routes.POST_DETAILE_PAGE,
        arguments: {"id": "${postBrief?.base?.id}"});
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    bool isCollect = postBrief?.base?.isCollect ?? false;
    int collects = postBrief?.base?.collects ?? 0;
    String image = postBrief?.base?.videoCover ?? "";
    String firstImg = postBrief?.base?.firstImg ?? "";
    if (image.isEmpty) {
      image = images != null && images!.isNotEmpty ? images!.first : "";
    }
    if (firstImg.isNotEmpty && image != firstImg) {
      image = firstImg;
    }

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          Get.toNamed(Routes.POST_DETAILE_PAGE,
              arguments: {"id": "${postBrief?.base?.id}"});
          // if (model != null) {
          //   postBrief?.base?.isCollect = model.isCollect;
          //   postBrief?.base?.collects = model.collects;
          //   setState(() {});
          // }
        },
        child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: widget.padding ?? Dimens.pt30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // SizedBox(height: Dimens.pt15),
              Stack(alignment: Alignment.bottomCenter, children: [
                Stack(alignment: Alignment.topRight, children: [
                  ImageLoader.withP(image,
                          width: screen.screenWidth, height: Dimens.pt276)
                      .load(),
                  if (postBrief?.base?.isHot ?? false)
                    Image.asset(R.assetsImgTipPostHot, width: Dimens.pt113)
                ]),
                Container(
                    width: screen.screenWidth,
                    height: Dimens.pt276 / 2,
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimens.pt35, vertical: Dimens.pt18),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5)
                        ])),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: (postBrief?.base?.title ?? "").isEmpty? postBrief?.node?.text ?? "":
                              postBrief?.base?.title ?? "",
                          style: TextStyle(
                              fontSize: Dimens.pt24, color: Colors.white),
                          recognizer: _tapRecognizer),
                    ]))),
                SizedBox(height: Dimens.pt15)
              ]),
              SizedBox(height: Dimens.pt20),
              Text(
                  "${TimeUtil.buildChineseYYMMDD(postBrief?.base?.createdAt ?? '')} ·"
                  " ${postBrief?.base?.topicName ?? '吃瓜'} ·"
                  " ${postBrief?.base?.watches ?? 0}浏览",
                  style: TextStyle(
                      fontSize: Dimens.pt22, color: AppColors.textGrey)),
              SizedBox(height: Dimens.pt20)
            ])));
  }

  Widget buildVideoNumber(
      {String? icon,
      String? text,
      double? width,
      VoidCallback? onTap,
      Color? color}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap?.call(),
        child: Row(children: [
          Image.asset(icon ?? R.assetsImgIconVideoCollect,
              color: color ?? theme.getColor(ThemeColor.primary),
              width: width ?? Dimens.pt42),
          SizedBox(width: Dimens.pt10),
          Text(text ?? "",
              style: TextStyle(
                  fontSize: Dimens.pt24,
                  color: theme.getColor(ThemeColor.primary)))
        ]));
  }
}
