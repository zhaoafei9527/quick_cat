import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/dialog/comic_chapter_dialog.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/comic_info_model.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/comment_refresh_view.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/app/widget/cover_banner.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/common_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/comic_detail_page_controller.dart';

class ComicDetailPageView extends GetView<ComicDetailPageController> {
  const ComicDetailPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ComicDetailPageController>(builder: (logic) {
      final theme = Get.find<ThemeManager>();
      return Scaffold(
          appBar: getCommonAppBar(logic.comicName.value),
          backgroundColor: theme.getColor(ThemeColor.bg),
          body: logic.initOk.value
              ? NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                          child: Obx(() => buildComicCoverHeader(logic))),
                      SliverToBoxAdapter(child: SizedBox(height: Dimens.pt25)),
                      SliverToBoxAdapter(
                          child: Obx(() => buildComicDescInfo(logic))),
                      if (logic.relatedVideo.isNotEmpty)
                        SliverToBoxAdapter(child: _buildRelateVideoView()),
                      SliverToBoxAdapter(
                          child: getHengLine(
                              paddingTop: Dimens.pt35,
                              paddingBottom: Dimens.pt35,
                              color: Color(0xFF1F1F1F),
                              h: Dimens.pt1))
                    ];
                  },
                  body: Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CoverBanner(
                                //广告minSwiperAds
                                aspectRatio: 700 / 198,
                                adsType: AdsType.minSwiperAds,
                                radius: 0,
                                onItemClick: (Advertise model) {
                                  AppPages.jumpRouter(
                                      path: model.href, id: model.id);
                                }),
                            SizedBox(height: Dimens.pt20),
                            Row(
                              children: [
                                buildCommonTabBar(
                                    controller: logic.tabController,
                                    tabs: logic.tabList
                                        .map((e) => Text(e))
                                        .toList()),
                                SizedBox(width: Dimens.pt15),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Dimens.pt10,
                                        vertical: Dimens.pt5),
                                    decoration: BoxDecoration(
                                        color: theme
                                            .getColor(ThemeColor.textYellow),
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt40)),
                                    child: Text(
                                        getShowWatchNumberStr(
                                            logic.comicsData.value?.comments ??
                                                0,
                                            count: 1),
                                        style: TextStyle(
                                            fontSize: Dimens.pt20,
                                            color: theme
                                                .getColor(ThemeColor.bg)))),
                              ],
                            ),
                            SizedBox(height: Dimens.pt25),
                            Expanded(
                                child: TabBarView(
                                    controller: logic.tabController,
                                    children: [
                                  buildRecommendComics(logic),
                                  CommentRefreshView(
                                      postId: 0,
                                      topInput: true,
                                      type: CommentType.CT_Comic,
                                      comments: 10)
                                ])),
                            getHengLine(
                                color: theme
                                    .getColor(ThemeColor.textGrey)
                                    .withOpacity(.5),
                                h: Dimens.pt1,
                                w: screen.screenWidth),
                            buildComicChapterView(logic),
                          ])))
              : getLoadingWidget());
    });
  }

  Widget _buildRelateVideoView() {
    ThemeManager theme = Get.find<ThemeManager>();
    ComicDetailPageController logic = Get.find<ComicDetailPageController>();
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: Dimens.pt40),
          Text("动漫版本",
              style: TextStyle(
                  fontSize: Dimens.pt38,
                  color: theme.getColor(ThemeColor.primary))),
          SizedBox(height: Dimens.pt25),
          SizedBox(
              height: Dimens.pt200,
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    MediaInfo model = logic.relatedVideo[index];
                    return getMediaCoverItemWidget(model, MediaType.videoLong,
                        width: Dimens.pt270, height: Dimens.pt152);
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(width: Dimens.pt25),
                  itemCount: logic.relatedVideo.length,
                  scrollDirection: Axis.horizontal))
        ]));
  }

  Widget buildComicChapterView(ComicDetailPageController logic) {
    return Obx(() {
      List<Chapter?> chapterList = logic.chapterList;
      bool isVip =
          logic.comicsData.value?.comicsPayType == PaymentType.vipPaymentType;
      return Container(
          height: Dimens.pt164,
          color: Get.find<ThemeManager>().getColor(ThemeColor.bg),
          padding: EdgeInsets.symmetric(vertical: Dimens.pt20),
          child: Row(children: [
            GestureDetector(
                onTap: () {
                  showComicChapterDialog(
                      context: Get.context!,
                      chapterList: chapterList,
                      onTap: (Chapter? chapter) {
                        logic.startReadComicAndRecord(
                            startChapterId: chapter?.id);
                      },
                      readNum: logic.readNum.value,
                      readChapterId: logic.readChapterId.value,
                      type: MediaType.comic,
                      isBuy: logic.comicsData.value?.isBuy,
                      comicsPayType: logic.comicsData.value?.comicsPayType ??
                          PaymentType.vipPaymentType,
                      price: logic.comicsData.value?.price ?? 0,
                      coverImg: logic.comicsData.value?.coverImg ?? "",
                      isSeries: logic.comicsData.value?.isSerial ?? false);
                },
                child: Container(
                    width: Dimens.pt148,
                    height: Dimens.pt164,
                    alignment: Alignment.center,
                    color: Get.find<ThemeManager>().getColor(ThemeColor.bgGrey),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(R.assetsImgIconComicChapter,
                              width: Dimens.pt50,
                              color: Get.find<ThemeManager>()
                                  .getColor(ThemeColor.primary)),
                          SizedBox(height: Dimens.pt10),
                          Text("目录",
                              style: TextStyle(
                                  fontSize: Dimens.pt24,
                                  color: Get.find<ThemeManager>()
                                      .getColor(ThemeColor.primary)))
                        ]))),
            SizedBox(width: Dimens.pt15),
            Expanded(
                child: SizedBox(
                    height: Dimens.pt76,
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () => logic.startReadComicAndRecord(
                                  startChapterId: chapterList[index]?.id),
                              child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                        width: Dimens.pt140,
                                        alignment: Alignment.center,
                                        color: Get.find<ThemeManager>()
                                            .getColor(ThemeColor.bgGrey),
                                        child: Text(
                                            "第${chapterList[index]?.chapterNum}话",
                                            style: TextStyle(
                                                fontSize: Dimens.pt24,
                                                color: Get.find<ThemeManager>()
                                                    .getColor(
                                                        ThemeColor.primary)))),
                                    Container(
                                        width: Dimens.pt16,
                                        height: Dimens.pt16,
                                        margin:
                                            EdgeInsets.only(right: Dimens.pt15),
                                        color: Get.find<ThemeManager>()
                                            .getColor(
                                                (chapterList[index]?.isFree ??
                                                        false)
                                                    ? ThemeColor.spring
                                                    : isVip
                                                        ? ThemeColor.textYellow
                                                        : ThemeColor.red))
                                  ]));
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(width: Dimens.pt15),
                        itemCount: chapterList.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics()))),
            GestureDetector(
                onTap: () => logic.startReadComicAndRecord(),
                child: Container(
                    width: Dimens.pt148,
                    height: Dimens.pt122,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: Dimens.pt10),
                    color: Get.find<ThemeManager>()
                        .getColor(ThemeColor.textYellow),
                    child: Text(
                        logic.readChapterNum.value > 0
                            ? "续看第${logic.readChapterNum.value}话"
                            : '开始阅读',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Dimens.pt28,
                            color: Get.find<ThemeManager>()
                                .getColor(ThemeColor.bg)))))
          ]));
    });
  }

  Widget buildRecommendComics(ComicDetailPageController logic) {
    return PagePullView<MediaInfo>(
        key: Key("pullKey_comic_recommend"),
        dataGetter: (int pageNum, int size) async {
          MediaList? media = await ApiRes.getRecommendComics(
              id: logic.comicId.value, pageNum: pageNum);
          return media?.comicList ?? [];
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          return gridViewBuilder(list.cast<MediaInfo>(),
              crossAxisCount: 3,
              childAspectRatio: 226 / 435,
              onTap: (index) => logic.switchComicPage(list[index].id),
              type: MediaType.comic);
        });
  }

  Widget buildComicDescInfo(ComicDetailPageController logic) {
    final model = logic.comicsData.value;
    bool collected = logic.isCollect.value;
    String type = (model?.isSerial ?? false) ? "连载中-更新" : "已完结-共";
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
                onTap: () => logic.addCollectComic(model),
                child: Container(
                    height: Dimens.pt46,
                    width: Dimens.pt144,
                    color: Get.find<ThemeManager>().getColor(collected
                        ? ThemeColor.textGrey
                        : ThemeColor.textYellow),
                    child: Center(
                        child: Text(collected ? "已加入" : "加入书架",
                            style: TextStyle(
                                color: Get.find<ThemeManager>()
                                    .getColor(ThemeColor.bg),
                                fontSize: Dimens.pt26))))),
            Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimens.pt20, vertical: Dimens.pt8),
                color: Get.find<ThemeManager>()
                    .getColor((model?.isSerial ?? false)
                        ? ThemeColor.red
                        : ThemeColor.textYellow)
                    .withOpacity(.1),
                child: Text("$type${model?.newChapter ?? 0}话",
                    style: TextStyle(
                        color: Get.find<ThemeManager>().getColor(
                            (model?.isSerial ?? false)
                                ? ThemeColor.red
                                : ThemeColor.textYellow),
                        fontSize: Dimens.pt26)))
          ]),
          SizedBox(height: Dimens.pt25),
          Text(model?.desc ?? "",
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: Dimens.pt24,
                  color:
                      Get.find<ThemeManager>().getColor(ThemeColor.textGrey))),
          SizedBox(height: Dimens.pt25),
          Row(children: [
            Image.asset(R.assetsImgIconEye,
                width: Dimens.pt36,
                color: Get.find<ThemeManager>().getColor(ThemeColor.textGrey)),
            SizedBox(width: Dimens.pt5),
            Text("${getShowWatchNumberStr(model?.watchTimes ?? 0)}观看",
                style: TextStyle(
                    fontSize: Dimens.pt26,
                    color: Get.find<ThemeManager>()
                        .getColor(ThemeColor.textGrey))),
            Spacer(),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showShareAccountDialog(),
                child: Row(children: [
                  Image.asset(R.assetsImgIconMineShare,
                      width: Dimens.pt36,
                      color: Get.find<ThemeManager>()
                          .getColor(ThemeColor.textGrey)),
                  SizedBox(width: Dimens.pt3),
                  Text("分享",
                      style: TextStyle(
                          fontSize: Dimens.pt26,
                          color: Get.find<ThemeManager>()
                              .getColor(ThemeColor.textGrey)))
                ]))
          ])
        ]));
  }

  Widget buildComicCoverHeader(ComicDetailPageController logic) {
    final model = logic.comicsData.value;

    return Stack(alignment: Alignment.bottomCenter, children: [
      ImageLoader.withP(model?.coverImg ?? "",
              width: screen.screenWidth, height: Dimens.pt600 + Dimens.pt180)
          .load(),
      Container(
          width: screen.screenWidth,
          height: Dimens.pt376,
          padding: EdgeInsets.symmetric(
              horizontal: Dimens.pt25, vertical: Dimens.pt20),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)])),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPayTypeWidget(
                    model?.comicsPayType ?? PaymentType.freePaymentType,
                    price: model?.price ?? 0,
                    width: Dimens.pt80,
                    height: Dimens.pt44,
                    fontSize: Dimens.pt28),
                SizedBox(height: Dimens.pt20),
                Text("${model?.title}",
                    style: TextStyle(
                        color: Get.find<ThemeManager>()
                            .getColor(ThemeColor.primary),
                        fontSize: Dimens.pt32)),
                SizedBox(height: Dimens.pt20),
                Row(children: [
                  Text("作者：",
                      style: TextStyle(
                          color: Get.find<ThemeManager>()
                              .getColor(ThemeColor.primary),
                          fontSize: Dimens.pt24)),
                  SizedBox(
                      height: Dimens.pt45,
                      child: ListView.separated(
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => Get.toNamed(Routes.TAG_DETAIL_PAGE,
                                  arguments: {
                                    "author": model?.author?[index] ?? "",
                                    "isAuthor": true,
                                    "mediaType": MediaType.comic.index
                                  }),
                              child: Container(
                                  // height: Dimens.pt50,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.pt20),
                                  alignment: Alignment.center,
                                  color: Get.find<ThemeManager>()
                                      .getColor(ThemeColor.bgGrey),
                                  child: Text(model?.author?[index] ?? "",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: Get.find<ThemeManager>()
                                              .getColor(ThemeColor.primary)))),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(width: Dimens.pt20),
                          itemCount: model?.author?.length ?? 0,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal))
                ]),
                SizedBox(height: Dimens.pt20),
                Row(
                  children: [
                    Text("标签：",
                        style: TextStyle(
                            color: Get.find<ThemeManager>()
                                .getColor(ThemeColor.primary),
                            fontSize: Dimens.pt24)),
                    SizedBox(
                        height: Dimens.pt45,
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => Get.toNamed(Routes.TAG_DETAIL_PAGE,
                                    arguments: {
                                      "id":
                                          "${model?.comicTags?[index].id ?? ""}",
                                      "title":
                                          model?.comicTags?[index].name ?? "",
                                      "mediaType": MediaType.comic.index
                                    }),
                                child: Container(
                                    // height: Dimens.pt50,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Dimens.pt20),
                                    alignment: Alignment.center,
                                    color: Get.find<ThemeManager>()
                                        .getColor(ThemeColor.bgGrey),
                                    child: Text(
                                        model?.comicTags?[index].name ?? "",
                                        style: TextStyle(
                                            fontSize: Dimens.pt24,
                                            color: Get.find<ThemeManager>()
                                                .getColor(
                                                    ThemeColor.primary)))),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(width: Dimens.pt20),
                            itemCount: model?.comicTags?.length ?? 0,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal)),
                  ],
                )
              ]))
    ]);
  }
}
