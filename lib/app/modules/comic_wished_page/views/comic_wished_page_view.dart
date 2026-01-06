import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/comic_topic_builder.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/comic_wished_page_controller.dart';

class ComicWishedPageView extends GetView<ComicWishedPageController> {
  const ComicWishedPageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<ComicWishedPageController>(builder: (logic) {
      List<TopicList> topicList = logic.wishedList.value.topicList ?? [];
      return Scaffold(
          appBar: getCommonAppBar("许愿墙"),
          backgroundColor: theme.getColor(ThemeColor.bg),
          body: logic.loading.value
              ? getLoadingWidget()
              : CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: _buildTopInfoView()),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((c, index) {
                    List<MediaInfo> mediaList = topicList[index].list ?? [];
                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                        child: Column(children: [
                          topicHeaderBuilder(topicList[index],
                              type: MediaType.comic.index,
                              showRank:true,
                              showMore: true),
                          Container(
                              width: screen.screenWidth,
                              height: Dimens.pt470 + Dimens.pt20,
                              margin:
                                  EdgeInsets.symmetric(vertical: Dimens.pt30),
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) =>
                                      ComicItemCover(
                                          model: mediaList[index],
                                          height: Dimens.pt380,
                                          width: Dimens.pt260,
                                          index: index + 1,
                                          showRank: true),
                                  separatorBuilder: (context, index) =>
                                      SizedBox(width: Dimens.pt10),
                                  itemCount: mediaList.length))
                        ]));
                  },
                          childCount: topicList.length,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: false))
                ]));
    });
  }

  Widget _buildTopInfoView() {
    ThemeManager theme = Get.find<ThemeManager>();

    return Column(children: [
      Image.asset(R.assetsImgBgWishedPage,
          width: screen.screenWidth, height: Dimens.pt330),
      SizedBox(height: Dimens.pt30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
            onTap: () => Get.toNamed(Routes.WISHING_PAGE),
            child: Container(
                width: Dimens.pt185,
                height: Dimens.pt66,
                color: theme.getColor(ThemeColor.primary),
                alignment: Alignment.center,
                child: Text("立即许愿",
                    style: TextStyle(
                        fontSize: Dimens.pt26,
                        fontWeight: FontWeight.w600,
                        color: theme.getColor(ThemeColor.bg))))),
        SizedBox(width: Dimens.pt50),
        GestureDetector(
            onTap: () => Get.toNamed(Routes.WISHED_ACTIVE_PAGE),
            child: Container(
                width: Dimens.pt185,
                height: Dimens.pt66,
                color: theme.getColor(ThemeColor.primary),
                alignment: Alignment.center,
                child: Text("当前榜单",
                    style: TextStyle(
                        fontSize: Dimens.pt26,
                        fontWeight: FontWeight.w600,
                        color: theme.getColor(ThemeColor.bg)))))
      ]),
      SizedBox(height: Dimens.pt40)
    ]);
  }
}
