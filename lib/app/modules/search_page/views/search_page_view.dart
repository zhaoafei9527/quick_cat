// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/ad_view.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/modules/search_page/views/search_result_view.dart';
import 'package:quick_cat_client/app/modules/search_page/views/search_view.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/array_util.dart';
import 'package:quick_cat_client/utils/common_util.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import 'package:path/path.dart';
import '../../../../utils/dimens.dart';
import '../../../widget/common_widget.dart';
import '../controllers/search_page_controller.dart';

class SearchPageView extends GetView<SearchPageController> {
  const SearchPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(Get.context!).unfocus(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset(R.assetsImgPageBg,
                width: screen.screenWidth,
                height: screen.screenHeight,
                fit: BoxFit.fill),
            Scaffold(
                backgroundColor: Colors.transparent,
                body: GetX<SearchPageController>(builder: (logic) {
                  return Container(
                      margin: EdgeInsets.only(top: screen.paddingTop),
                      child: Column(children: [
                        Container(
                            margin: EdgeInsets.only(bottom: Dimens.pt30),
                            padding:
                                EdgeInsets.symmetric(horizontal: Dimens.pt25),
                            child: SearchBarView(
                                onBack: () {
                                  if (logic.isSearch.value) {
                                    logic.isSearch.value = false;
                                  } else {
                                    Get.back();
                                  }
                                },
                                controller: logic.textEditingController,
                                onSubmitted: (String text) =>
                                    logic.searchData())),
                        Expanded(
                            child: Stack(children: [
                          Offstage(
                              offstage: logic.isSearch.value,
                              child: logic.initOk.value
                                  ? _notSearchView(logic)
                                  : getLoadingView()),
                          Offstage(
                              offstage: !logic.isSearch.value,
                              child: _searchResultView(logic))
                        ]))
                      ]));
                })),
          ],
        ));
  }

  Widget _notSearchView(SearchPageController logic) {
    ThemeManager theme = Get.find<ThemeManager>();
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: NestedScrollView(
            headerSliverBuilder: (_, __) {
              return _buildNoSearchHeader();
            },
            body: TabBarView(controller: logic.typeTabController, children: [
              ...List.generate(logic.tagTabList.length, (index) {
                return buildPagePullView(logic.mediaTypeList[index]);
              })
            ])));
  }

  // 视频下拉列表组建 包含漫画、动漫、视频、darkWeb。
  Widget buildPagePullView(MediaType type) {
    SearchPageController logic = Get.find<SearchPageController>();
    return PagePullView(
        dataGetter: (int pageNum, int size) async {
          MediaList? medias =
              await ApiRes.getSearchRankMediaList(type: type, pageNum: pageNum);
          return getMediaListOfList(medias, type);
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          return Padding(
              padding: EdgeInsets.zero,
              child: buildCommonMediaGrid(list.cast<MediaInfo>(),
                  mediaType: type, dataGetter: (int pageNum) async {
                MediaList? medias = await ApiRes.getSearchRankMediaList(
                    type: type, pageNum: pageNum);
                return getMediaListOfList(medias, type);
              }));
        });
  }

  List<Widget> _buildNoSearchHeader() {
    ThemeManager theme = Get.find<ThemeManager>();
    SearchPageController logic = Get.find<SearchPageController>();
    List<String> tagList = logic.hotSearchTagMap[MediaType.videoLong] ?? [];
    return [
      SliverToBoxAdapter(
          child: Row(children: [
        Text('搜索历史',
            style: TextStyle(color: Colors.white, fontSize: Dimens.pt32)),
        const Spacer(),
        GestureDetector(
            onTap: () => logic.clearHistory(),
            child: Row(children: [
              Image.asset(R.assetsImgIconDelete,
                  width: Dimens.pt24, color: Colors.white)
            ]))
      ])),
      if (ArrayUtil.isEmpty(logic.historyWords))
        SliverToBoxAdapter(child: getEmptyWidget())
      else
        SliverToBoxAdapter(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: Dimens.pt26),
                child: buildSearchHistory(logic))),
      SliverToBoxAdapter(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: EdgeInsets.only(top: Dimens.pt25, left: Dimens.pt6),
            child: Text('大家都在搜',
                style: TextStyle(color: Colors.white, fontSize: Dimens.pt32))),
        SizedBox(height: Dimens.pt25),
        SizedBox(
            height: Dimens.pt110,
            child: Wrap(
                spacing: Dimens.pt25,
                runSpacing: Dimens.pt15,
                alignment: WrapAlignment.start,
                children: [
                  ...tagList.map((tag) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => logic.searchData(searchKey: tag),
                      child: Container(
                          color: Color(0xFF222433),
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimens.pt22, vertical: Dimens.pt10),
                          child: Text(tag,
                              style: TextStyle(
                                  fontSize: Dimens.pt24,
                                  color: Colors.white)))))
                ])),
        SizedBox(height: Dimens.pt45),
        AdView(
            type: AdsType.minSwiperAds,
            width: Dimens.pt700,
            height: Dimens.pt195),
        SizedBox(height: Dimens.pt25),
        SizedBox(
            height: Dimens.pt70,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => GestureDetector(
                    onTap: () => logic.recommendIndex.value = index,
                    child: Obx(() =>
                        Stack(alignment: Alignment.topLeft, children: [
                          SizedBox(width: Dimens.pt146, height: Dimens.pt70),
                          if (logic.recommendIndex.value == index)
                            Image.asset(R.assetsImgBgTextPop,
                                height: Dimens.pt70, width: Dimens.pt146),
                          Container(
                              width: Dimens.pt146,
                              height: Dimens.pt56,
                              decoration: BoxDecoration(
                                  color: logic.recommendIndex.value != index
                                      ? Color(0xFF2C2C34)
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(Dimens.pt6)),
                              alignment: Alignment.center,
                              child: Text(logic.recommendType[index],
                                  style: TextStyle(
                                      fontSize: Dimens.pt28,
                                      color: Colors.white)))
                        ]))),
                separatorBuilder: (context, index) =>
                    SizedBox(width: Dimens.pt25),
                itemCount: logic.recommendType.length)),
        // Container(
        //     padding: EdgeInsets.only(top: Dimens.pt25, left: Dimens.pt6),
        //     child: Text('每日热搜',
        //         style: TextStyle(
        //             color: theme.getColor(ThemeColor.primary),
        //             fontSize: Dimens.pt32,
        //             fontWeight: FontWeight.w600))),
        SizedBox(height: Dimens.pt25),
      ]))
    ];
  }

  Widget _buildMediaRankItem(MediaInfo media, int index) {
    List<String> rankImg = [
      R.assetsImgIconNumberOne,
      R.assetsImgIconNumberTwo,
      R.assetsImgIconNumberThree
    ];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed(Routes.VIDEO_PLAYER_PAGE,
          arguments: {"id": "${media.id}"}),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
            width: Dimens.pt45,
            alignment: Alignment.center,
            child: index < 3
                ? Image.asset(rankImg[index])
                : Text("${index + 2}.",
                    style: TextStyle(
                        fontSize: Dimens.pt22,
                        color: const Color(0xFFADB5BD)))),
        SizedBox(width: Dimens.pt28),
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimens.pt10),
                child: Row(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.pt12),
                      child: Stack(children: [
                        ImageLoader.withP(media.coverImg ?? "",
                                width: Dimens.pt300, height: Dimens.pt169)
                            .load(),
                        Positioned(
                            top: 0,
                            right: Dimens.pt30,
                            child: Image.asset(
                                media.payType == 0
                                    ? R.assetsImgTipCoverFree
                                    : R.assetsImgTipCoverVip,
                                width: Dimens.pt58))
                      ])),
                  SizedBox(width: Dimens.pt8),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(media.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: Dimens.pt28, color: Colors.white)),
                        Text(
                            (media.desc ?? "").isNotEmpty
                                ? media.desc ?? ""
                                : media.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: Dimens.pt24,
                                color: const Color(0xFF8A8785))),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  TimeUtil.showDateBefore(
                                      media.createdAt ?? ""),
                                  style: TextStyle(
                                      fontSize: Dimens.pt22,
                                      color: const Color(0xFF8A8785))),
                              const Spacer(),
                              Image.asset(R.assetsImgIconCoverComment,
                                  width: Dimens.pt23),
                              SizedBox(width: Dimens.pt10),
                              Text("${media.comments}",
                                  style: TextStyle(
                                      fontSize: Dimens.pt22,
                                      color: const Color(0xFF8A8785))),
                            ]),
                        const Spacer(),
                        Row(children: [
                          Image.asset(
                            R.assetsImgIconCoverPlay,
                            width: Dimens.pt31,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: Dimens.pt10),
                          Text(
                              getShowWatchNumberStr(media.watchTimes ?? 0,
                                  count: 1),
                              style: TextStyle(
                                  fontSize: Dimens.pt22,
                                  color: AppColors.primaryColor)),
                          const Spacer(),
                          Text(TimeUtil.getHHNNSS(media.playTime ?? 0),
                              style: TextStyle(
                                  fontSize: Dimens.pt22, color: Colors.white))
                        ])
                      ]))
                ])))
      ]),
    );
  }

  Widget _buildHotSearchItem(String? text, SearchPageController logic) {
    return GestureDetector(
      onTap: () => logic.searchData(searchKey: text),
      child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: Dimens.pt20, vertical: Dimens.pt10),
          decoration: BoxDecoration(
              color: const Color(0xFF1D1A19),
              borderRadius: BorderRadius.circular(Dimens.pt45)),
          child: Text(text ?? "",
              style: TextStyle(fontSize: Dimens.pt26, color: Colors.white))),
    );
  }

  Widget buildSearchHistory(SearchPageController logic) {
    return Obx(
      () => Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Dimens.pt15,
          runSpacing: Dimens.pt15,
          alignment: WrapAlignment.start,
          direction: Axis.horizontal,
          children: List.generate(
              logic.historyWords.length,
              (index) => Container(
                  color: Color(0xFF222433),
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimens.pt20, vertical: Dimens.pt10),
                  child: GestureDetector(
                      onTap: () => logic.searchData(
                          searchKey: logic.historyWords[index]),
                      child: Text(logic.historyWords[index],
                          style: TextStyle(
                              fontSize: Dimens.pt24, color: Colors.white)))))),
    );
  }

  Widget _searchResultView(SearchPageController logic) {
    return Column(children: [
      buildCommonTabBar(
          controller: logic.tabController,
          insetsWidth: Dimens.pt4,
          fontSize: Dimens.pt34,
          isScrollable: true,
          unselectedLabelColor: AppColors.textGrey,
          alignment: TabAlignment.center,
          tabs: logic.tabList.map((e) => Text(e)).toList()),
      SizedBox(height: Dimens.pt35),
      Expanded(
          child: TabBarView(controller: logic.tabController, children: [
            SearchResultView(key: logic.postKey, searchType: MediaType.post),
            SearchResultView(
                key: logic.longVideoKey, searchType: MediaType.videoLong),
            SearchResultView(
                key: logic.shortVideoKey, searchType: MediaType.videoShort),
        SearchResultView(key: logic.cartoonKey, searchType: MediaType.cartoon),
        SearchResultView(key: logic.novelKey, searchType: MediaType.novel),

        // _buildPostSearchResultView(logic, logic.postKey),
      ])),
      const SizedBox(height: kToolbarHeight)
    ]);
  }
}
