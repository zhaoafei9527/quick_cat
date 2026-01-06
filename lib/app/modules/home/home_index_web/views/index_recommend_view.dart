// 🐦 Flutter imports:
import 'package:acgn_client/app/modules/home/home_index_web/controllers/home_index_web_controller.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/views/round_under_line_tab_indicator.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/widget/long_video_cover.dart';
import 'package:acgn_client/utils/dimens.dart';
import '../../../../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../../../../../r.dart';
import '../../../../routes/app_pages.dart';
import '../../../../views/page_pull_view.dart';
import '../../../../widget/common_widget.dart';
import '../controllers/index_recommend_controller.dart';

class IndexRecommendView extends GetView<IndexRecommendController> {
  const IndexRecommendView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var logic = Get.put(IndexRecommendController(), tag: "home_index");

    return GetX<ThemeManager>(
      builder: (ThemeManager theme) => Column(children: [
        buildHomeTabBar(logic, theme),
        SizedBox(height: Dimens.pt32),
        // Expanded(
        //     child: TabBarView(
        //         controller: logic.tabController,
        //         children: logic.categoryList
        //             .asMap()
        //             .map((index, value) {
        //               return MapEntry(
        //                   index,
        //                   KeepAliveWrapper(
        //                       child: HomeComicCateTabBarView(
        //                           index: index, id: value.id ?? 0)));
        //             })
        //             .values
        //             .toList())),

      ]),
    );
  }

  Widget buildHomeTabBar(IndexRecommendController logic, ThemeManager theme) {
    return Container(
        height: Dimens.pt66,
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt10),
        child: TabBar(
            controller: logic.tabController,
            isScrollable: true,
            tabs: logic.categoryList.map((e) => Text(e.name ?? '')).toList(),
            labelStyle: TextStyle(
                fontSize: Dimens.pt26,
                fontWeight: FontWeight.w600,
                color: theme.getColor(ThemeColor.primary)),
            labelColor: theme.getColor(ThemeColor.primary),
            indicatorWeight: Dimens.pt10,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            labelPadding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
            unselectedLabelStyle: TextStyle(
                fontSize: Dimens.pt26,
                color: theme.getColor(ThemeColor.textGrey)),
            unselectedLabelColor: theme.getColor(ThemeColor.textGrey),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            tabAlignment: TabAlignment.start,
            indicator: RoundUnderlineTabIndicator(
                borderSide: BorderSide(
                    width: Dimens.pt4,
                    color: theme.getColor(ThemeColor.primary)),
                wantToWith: Dimens.pt72)));
  }

  Widget _buildTabBarView(IndexRecommendController logic) {
    logic.isSingleModel.value;
    return TabBarView(
        controller: logic.sortTabController,
        children: List.generate(3, (index) {
          return RepaintBoundary(
            child: PagePullView(
                key: Key("key_$index"),
                // enablePullDown: false,
                dataGetter: (int pageNum, int size) async {
                  List<MediaInfo> media = await logic.getTopicMediaData(
                      pageNum: pageNum, sort: index);
                  return media;
                },
                emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
                widgetBuilder:
                    (BuildContext context, List<dynamic> list, Widget? child) {
                  return logic.isSingleModel.value
                      ? _buildMediaModel(1, list)
                      : _buildMediaModel(2, list);
                }),
          );
        }));
  }

  Widget _buildMediaModel(int buildLength, List<dynamic> mediaList) {
    bool single = buildLength == 1;
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        physics: const NeverScrollableScrollPhysics(),
        cacheExtent: 100,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: single ? 1 : 2,
            //横向数量
            crossAxisSpacing: Dimens.pt10,
            mainAxisSpacing: Dimens.pt25,
            childAspectRatio: single ? 16 / 12 : 16 / 14.8),
        itemCount: mediaList.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return LongVideoCover(mediaList[index],
              // showCover: index >= index - 10,
              width: single ? Dimens.pt700 : Dimens.pt345);
        });
  }

  Widget _buildHeaderAdsView(IndexRecommendController logic) {
    //广告homeGameIconAds
    return Obx(
      () => Container(
          height: Dimens.pt132,
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (c, i) {
                return GestureDetector(
                    onTap: () {
                      AppPages.jumpRouter(path: logic.gameAdList[i].href);
                    },
                    child: ImageLoader.withP(logic.gameAdList[i].cover ?? "",
                            width: Dimens.pt132, radius: Dimens.pt14)
                        .load());
              },
              separatorBuilder: (c, i) => SizedBox(width: Dimens.pt10),
              itemCount: logic.gameAdList.length)),
    );
  }

  Widget buildSortMediaView(IndexRecommendController logic) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
      child: Column(children: [
        SizedBox(
            height: Dimens.pt54,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: Dimens.pt98),
                  Expanded(
                      child: Center(
                          child: buildCommonTabBar(
                              controller: logic.sortTabController,
                              insets: Dimens.pt40,
                              tabs: shareKeys.longMediaSortList
                                  .map((e) => Text(e))
                                  .toList()))),
                  GestureDetector(
                      onTap: () => logic.isSingleModel.value =
                          !logic.isSingleModel.value,
                      child: Row(children: [
                        Text("切换",
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: const Color(0xFFADB5BD))),
                        Obx(
                          () => Image.asset(
                              logic.isSingleModel.value
                                  ? R.assetsImgIconChangeTop
                                  : R.assetsImgIconChangeDown,
                              width: Dimens.pt40),
                        )
                      ]))
                ]))
      ]),
    );
  }

  Widget buildTopicButtonView(IndexRecommendController logic) {
    // IndexRecommendController logic = Get.find<IndexRecommendController>();
    return Obx(() => Container(
        height: Dimens.pt60,
        margin: EdgeInsets.only(bottom: Dimens.pt16),
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (c, i) {
                  return GestureDetector(
                    onTap: () => Get.toNamed(Routes.TOPIC_DETAIL_PAGE,
                        arguments: {
                          "id": "${logic.topicList[i].id}",
                          "title": logic.topicList[i].name
                        }),
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimens.pt23, vertical: Dimens.pt5),
                        decoration: BoxDecoration(
                            color: const Color(0xFF1D1A19),
                            borderRadius: BorderRadius.circular(Dimens.pt12)),
                        child: Center(
                            child: Text(logic.topicList[i].name ?? "",
                                style: TextStyle(
                                    fontSize: Dimens.pt28,
                                    color: const Color(0xFFC5C1BE))))),
                  );
                },
                separatorBuilder: (c, i) => SizedBox(width: Dimens.pt20),
                itemCount: logic.topicList.length),
          ),
          SizedBox(width: Dimens.pt25),
          GestureDetector(
              onTap: () {
                HomeIndexWebController home = Get.find();
              },
              child: Image.asset(R.assetsImgIconHomeTopic, width: Dimens.pt40))
        ])));
  }
}
