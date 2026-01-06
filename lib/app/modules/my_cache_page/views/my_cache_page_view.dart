import 'dart:math';

import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/video_play_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/pull_refresh_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/fijk_player.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:get/get.dart';

import '../../../../plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import '../../../dialog/common_dialog.dart';
import '../../../views/page_pull_view.dart';
import '../../../widget/comic_topic_builder.dart';
import '../../../widget/common_widget.dart';
import '../controllers/my_cache_page_controller.dart';

class MyCachePageView extends GetView<MyCachePageController> {
  const MyCachePageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<MyCachePageController>(builder: (MyCachePageController logic) {
      return Scaffold(
          appBar: getCommonAppBar("我的缓存"),
          backgroundColor: theme.getColor(ThemeColor.bg),
          body: logic.cacheInfoList.isNotEmpty
              ? SingleChildScrollView(
                  child: MasonryGridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: Dimens.pt10,
                      mainAxisSpacing: Dimens.pt10,
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                      itemCount: logic.cacheInfoList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        VideoCacheInfo cache = logic.cacheInfoList[index];

                        return _buildCacheVideoItem(logic, cache);
                      }))
              : buildCommonEmptyView("宝贝,没有找到东西哦～"));
    });
  }

  Widget _buildCacheVideoItem(
      MyCachePageController logic, VideoCacheInfo cache) {
    ThemeManager theme = Get.find<ThemeManager>();
    double progress = (cache.segmentCount / cache.totalCount) * 100;
    progress = progress > 100 ? 100 : progress;
    double size = cache.cacheSizeBytes / 1024 / 1024;

    return GestureDetector(
      onTap: () async {
        var result = await showVideoPlayerDialog(
            Get.context!, cache.originalUrl,
            title: cache.title, coverImg: cache.coverImg);
        FIJKPlayerManager manager = FIJKPlayerManager();
        manager.disposePlayer();
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(alignment: Alignment.center, children: [
          ImageLoader.withP(cache.coverImg ?? "", width: Dimens.pt345).load(),
          Image.asset(R.assetsImgIconPlayerPause, width: Dimens.pt60),
          Positioned(
              bottom: 0,
              child: Container(
                  width: Dimens.pt345,
                  padding: EdgeInsets.all(Dimens.pt10),
                  color: Colors.black.withOpacity(.5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("进度：${progress.toStringAsFixed(2)}%",
                            style: TextStyle(
                                fontSize: Dimens.pt20,
                                color: theme.getColor(ThemeColor.primary))),
                        Text("内存：${size.toStringAsFixed(2)}M",
                            style: TextStyle(
                                fontSize: Dimens.pt20,
                                color: theme.getColor(ThemeColor.primary)))
                      ])))
        ]),
        SizedBox(height: Dimens.pt15),
        Text(cache.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: Dimens.pt26, color: Colors.white))
      ]),
    );
  }
}
