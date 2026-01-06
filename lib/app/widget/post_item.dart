// 🐦 Flutter imports:
import 'package:acgn_client/app/dialog/common_dialog.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/dialog/comment_dialog.dart';
import 'package:acgn_client/app/widget/post_common_widget.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/time_util.dart';
import '../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../model/post_list_model.dart';
import '../routes/app_pages.dart';

class PostItem extends StatefulWidget {
  PostBrief? postBrief;
  int? categoryId;

  PostItem({super.key, this.postBrief, this.categoryId});

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

    Get.toNamed(Routes.POST_TOPIC_PAGE,
        arguments: {"topicId": topicId, "title": name});
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    bool isCollect = postBrief?.base?.isCollect ?? false;
    int collects = postBrief?.base?.collects ?? 0;

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          await Get.toNamed(Routes.POST_DETAILE_PAGE,
              arguments: {"id": "${postBrief?.base?.id}"});
          // if (model != null) {
          //   postBrief?.base?.isCollect = model.isCollect;
          //   postBrief?.base?.collects = model.collects;
          //   setState(() {});
          // }
        },
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // SizedBox(height: Dimens.pt15),
              Stack(alignment: Alignment.bottomCenter, children: [
                ImageLoader.withP(images?[0] ?? "",
                        width: screen.screenWidth, height: Dimens.pt276)
                    .load(),
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
                          text: postBrief?.node?.text ?? "",
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
