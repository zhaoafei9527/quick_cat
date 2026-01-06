import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/dimens.dart';
import '../../../../utils/screen.dart';
import '../../../model/comic_chapter.dart';

class PreviewImageViewer extends GetView {
  const PreviewImageViewer({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    List<ChapterPicItem>? images = Get.arguments?['images'];
    String? title = Get.arguments?['title'];

    return Scaffold(
        backgroundColor: theme.getColor(ThemeColor.bg),
        appBar: getCommonAppBar(title ?? "预览图片"),
        body: images == null || images.isEmpty
            ? getEmptyWidget(emptyText: "没有图片可预览")
            : ListView.separated(
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return ImageLoader.withP(images[index].comicsPic,
                          width: screen.screenWidth,
                          fit: BoxFit.cover)
                      .load();
                },
                separatorBuilder: (context, index) =>
                    SizedBox(height: Dimens.pt10),
                itemCount: images.length));
  }
}
