import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/dialog/comic_chapter_dialog.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/comic_info_model.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
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

import '../controllers/novel_detail_page_controller.dart';

class NovelDetailPageView extends GetView<NovelDetailPageController> {
  const NovelDetailPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<NovelDetailPageController>(builder: (logic) {
      final model = logic.novelData.value;
      return Stack(alignment: Alignment.topCenter, children: [
        Container(
            width: screen.screenWidth,
            height: screen.screenHeight,
            color: Color(0xFF071222)),
        ImageLoader.withP(model?.coverImg ?? "",
                width: screen.screenWidth, height: Dimens.pt726 + Dimens.pt100)
            .load(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: getCommonAppBar("", actions: [
            GestureDetector(
                onTap: () => logic.scaffoldKey.currentState?.openDrawer(),
                child: Padding(
                    padding: EdgeInsets.only(right: Dimens.pt25),
                    child: Image.asset(R.assetsImgIconReaderChapter,
                        width: Dimens.pt34))),
            GestureDetector(
                onTap: () => logic.addCollectComic(logic.novelData.value),
                child: Padding(
                    padding: EdgeInsets.only(right: Dimens.pt25),
                    child: Image.asset(
                        logic.isCollect.value
                            ? R.assetsImgIconNovalCollected
                            : R.assetsImgIconNovalCollect,
                        width: Dimens.pt40)))
          ]),
          key: logic.scaffoldKey,
          drawer: _buildChapterEndDrawer(logic),
          body: LoadingView(
            loading: !logic.initOk.value,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
                  child: buildPayTypeWidget(model?.novelPayType,
                      width: Dimens.pt78,
                      height: Dimens.pt46,
                      fontSize: Dimens.pt26)),
              SizedBox(height: Dimens.pt450),
              Container(
                  width: screen.screenWidth,
                  padding: EdgeInsets.all(Dimens.pt30),
                  margin: EdgeInsets.symmetric(horizontal: Dimens.pt30),
                  decoration: BoxDecoration(
                      color: Color(0xFF081324),
                      borderRadius: BorderRadius.circular(Dimens.pt6)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${model?.title}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white, fontSize: Dimens.pt42)),
                        SizedBox(height: Dimens.pt20),
                        Row(children: [
                          ...List.generate(
                              model?.author?.length ?? 0,
                              (index) => Text("作者：${model?.author?[index]} ",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.4),
                                      fontSize: Dimens.pt22)))
                        ]),
                        SizedBox(height: Dimens.pt20),
                        if ((model?.novelTags ?? []).isNotEmpty)
                          SizedBox(
                              height: Dimens.pt35,
                              child: ListView.separated(
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () => Get.toNamed(
                                                Routes.TAG_DETAIL_PAGE,
                                                arguments: {
                                                  "id":
                                                      "${model?.novelTags?[index].id ?? 0}",
                                                  "title": model
                                                          ?.novelTags?[index]
                                                          .name ??
                                                      "",
                                                  "mediaType":
                                                      MediaType.novel.index
                                                }),
                                        child: Container(
                                            height: Dimens.pt35,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimens.pt20),
                                            alignment: Alignment.center,
                                            color: Colors.white.withOpacity(.1),
                                            child: Text(
                                                "#${model?.novelTags?[index].name ?? ''}",
                                                style: TextStyle(
                                                    fontSize: Dimens.pt22,
                                                    color: Colors.white))));
                                  },
                                  separatorBuilder: (context, index) =>
                                      SizedBox(width: Dimens.pt20),
                                  itemCount: model?.novelTags?.length ?? 0,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal)),
                        SizedBox(height: Dimens.pt20),
                        getHengLine(
                            color: Colors.white.withOpacity(.3), h: Dimens.pt1),
                        SizedBox(height: Dimens.pt20),
                        Row(children: [
                          Image.asset(R.assetsImgIconWatch, width: Dimens.pt28),
                          SizedBox(width: Dimens.pt8),
                          Text(getShowWatchNumberStr(model?.watchTimes ?? 0),
                              style: TextStyle(
                                  color: Colors.white, fontSize: Dimens.pt24)),
                          SizedBox(width: Dimens.pt25),
                          getHengLine(
                              color: Colors.white.withOpacity(.5),
                              w: Dimens.pt1,
                              h: Dimens.pt22),
                          SizedBox(width: Dimens.pt25),
                          Text("已更新${model?.chapterCount ?? 0}章",
                              style: TextStyle(
                                  color: Colors.white, fontSize: Dimens.pt24)),
                          Spacer(),
                          Text("可免费看${logic.freeChapterCount}章",
                              style: TextStyle(
                                  color: Colors.white, fontSize: Dimens.pt24)),
                        ])
                      ])),
              Container(
                  width: screen.screenWidth,
                  padding: EdgeInsets.all(Dimens.pt30),
                  margin: EdgeInsets.symmetric(horizontal: Dimens.pt30),
                  decoration: BoxDecoration(
                      color: Color(0xFF0D1F3A),
                      borderRadius: BorderRadius.circular(Dimens.pt6)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("简介",
                            style: TextStyle(
                                color: Colors.white, fontSize: Dimens.pt34)),
                        SizedBox(height: Dimens.pt20),
                        Text("${model?.desc}",
                            maxLines: 7,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.6),
                                fontSize: Dimens.pt26))
                      ])),
              SizedBox(height: Dimens.pt25),
              Spacer(),
              if (logic.chapterList.isNotEmpty)
                Row(children: [
                  Expanded(
                      child: GestureDetector(
                    child: Container(
                        height: Dimens.pt96,
                        alignment: Alignment.center,
                        color: Color(0xFF0D1F3A),
                        child: Text(
                            logic.chapterList[logic.readChapterIndex.value]
                                    ?.title ??
                                '',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white, fontSize: Dimens.pt30))),
                  )),
                  GestureDetector(
                    onTap: () => logic.startReadComicAndRecord(),
                    child: Container(
                      width: Dimens.pt280,
                      height: Dimens.pt96,
                      alignment: Alignment.center,
                      color: AppColors.mainRed,
                      child: Text(
                          logic.readChapterNum.value > 0
                              ? "续看第${logic.readChapterNum.value}章"
                              : '开始阅读',
                          style: TextStyle(
                              fontSize: Dimens.pt36, color: Colors.white)),
                    ),
                  )
                ]),
              SizedBox(height: Dimens.pt20 + screen.paddingBottom)
            ]),
          ),
        )
      ]);
      // return Scaffold(
      //     appBar: getCommonAppBar(logic.novelName.value, actions: [
      //       GestureDetector(
      //           onTap: () => showShareAccountDialog(),
      //           child: Padding(
      //               padding: EdgeInsets.only(right: Dimens.pt25),
      //               child: Image.asset(R.assetsImgIconNovalCollect,
      //                   width: Dimens.pt40)))
      //     ]),
      //     backgroundColor: theme.getColor(ThemeColor.bg),
      //     body: logic.initOk.value
      //         ? NestedScrollView(
      //             headerSliverBuilder:
      //                 (BuildContext context, bool innerBoxIsScrolled) {
      //               return <Widget>[
      //                 SliverToBoxAdapter(
      //                     child: Obx(() => buildNovelCoverHeader(logic))),
      //                 SliverToBoxAdapter(child: SizedBox(height: Dimens.pt25)),
      //                 SliverToBoxAdapter(
      //                     child: Obx(() => buildNovelDescInfo(logic))),
      //               ];
      //             },
      //             body: Padding(
      //                 padding: EdgeInsets.symmetric(horizontal: Dimens.pt20),
      //                 child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       getHengLine(
      //                           paddingTop: Dimens.pt30,
      //                           paddingBottom: Dimens.pt30,
      //                           color: Get.find<ThemeManager>()
      //                               .getColor(ThemeColor.textGrey),
      //                           h: Dimens.pt1,
      //                           w: screen.screenWidth - Dimens.pt50),
      //                       CoverBanner(
      //                           //广告minSwiperAds
      //                           aspectRatio: 700 / 198,
      //                           adsType: AdsType.longVideoSwiperAds,
      //                           onItemClick: (Advertise model) {
      //                             AppPages.jumpRouter(
      //                                 path: model.href, id: model.id);
      //                           }),
      //                       SizedBox(height: Dimens.pt30),
      //                       buildCommonTabBar(
      //                           controller: logic.tabController,
      //                           tabs:
      //                               logic.tabList.map((e) => Text(e)).toList()),
      //                       SizedBox(height: Dimens.pt25),
      //                       Expanded(
      //                           child: TabBarView(
      //                               controller: logic.tabController,
      //                               children: [
      //                             buildRecommendNovels(logic),
      //                             CommentRefreshView(
      //                                 postId: logic.novelId.value,
      //                                 type: CommentType.CT_Novel,
      //                                 topInput: false,
      //                                 comments: 10)
      //                           ])),
      //                       getHengLine(
      //                           color: theme
      //                               .getColor(ThemeColor.textGrey)
      //                               .withOpacity(.5),
      //                           h: Dimens.pt1,
      //                           w: screen.screenWidth),
      //                       buildNovelChapterView(logic),
      //                     ])))
      //         : getLoadingWidget());
    });
  }

  Widget _buildChapterEndDrawer(NovelDetailPageController logic) {
    return Container(
        width: Dimens.pt600 + Dimens.pt40,
        // padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: Dimens.pt30 + screen.paddingTop),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
            child: Text(logic.novelName.value,
                style:
                    TextStyle(fontSize: Dimens.pt40, color: Color(0xFF333332))),
          ),
          SizedBox(height: Dimens.pt20),
          Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimens.pt30, vertical: Dimens.pt8),
              margin: EdgeInsets.only(right: Dimens.pt60),
              color: Color(0xFFF3F3F3),
              child: Row(children: [
                Text("共${logic.chapterList.length}章",
                    style: TextStyle(
                        fontSize: Dimens.pt30, color: Color(0xFF666666))),
                Spacer(),
                GestureDetector(
                    onTap: () => logic.reverseChapterOrder(),
                    child: Row(children: [
                      Text("正序",
                          style: TextStyle(
                              fontSize: Dimens.pt30,
                              color: !logic.isReverseOrder.value
                                  ? AppColors.mainRed
                                  : Color(0xFF666666))),
                      SizedBox(width: Dimens.pt20),
                      getHengLine(
                          h: Dimens.pt26,
                          w: Dimens.pt2,
                          color: Color(0xFF666666).withOpacity(.5)),
                      SizedBox(width: Dimens.pt20),
                      Text("倒序",
                          style: TextStyle(
                              fontSize: Dimens.pt30,
                              color: logic.isReverseOrder.value
                                  ? AppColors.mainRed
                                  : Color(0xFF666666)))
                    ]))
              ])),
          SizedBox(height: Dimens.pt40),
          Expanded(
              child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          logic.startReadComicAndRecord(
                              startChapterId: logic.chapterList[index]?.id);
                        },
                        child: Text(logic.chapterList[index]?.title ?? "",
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: logic.readChapterIndex.value == index
                                    ? AppColors.mainRed
                                    : Color(0xFF666666).withOpacity(.9))));
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(height: Dimens.pt30),
                  itemCount: logic.chapterList.length))
        ]));
  }

  Widget buildNovelChapterView(NovelDetailPageController logic) {
    return Obx(() {
      List<Chapter?> chapterList = logic.chapterList;
      bool isVip =
          logic.novelData.value?.novelPayType == PaymentType.vipPaymentType;
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
                      type: MediaType.novel,
                      comicsPayType: logic.novelData.value?.comicsPayType ??
                          PaymentType.vipPaymentType,
                      price: logic.novelData.value?.price ?? 0,
                      coverImg: logic.novelData.value?.coverImg ?? "",
                      isSeries: logic.novelData.value?.isSerial ?? false);
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
                                            "第${chapterList[index]?.chapterNum}章",
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
                            ? "续看第${logic.readChapterNum.value}章"
                            : '开始阅读',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Dimens.pt28,
                            color: Get.find<ThemeManager>()
                                .getColor(ThemeColor.bg)))))
          ]));
    });
  }

  Widget buildRecommendNovels(NovelDetailPageController logic) {
    return PagePullView<MediaInfo>(
        key: Key("pullKey_novels_recommend"),
        dataGetter: (int pageNum, int size) async {
          MediaList? media = await ApiRes.getRecommendNovels(
              id: logic.novelId.value, pageNum: pageNum);
          return media?.novelList ?? [];
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          return gridViewBuilder(list.cast<MediaInfo>(),
              crossAxisCount: 3,
              childAspectRatio: 226 / 435,
              onTap: (index) => logic.switchNovelPage(list[index].id),
              type: MediaType.novel);
        });
  }

  Widget buildNovelDescInfo(NovelDetailPageController logic) {
    final model = logic.novelData.value;
    bool collected = logic.isCollect.value;
    ThemeManager theme = Get.find<ThemeManager>();
    String type = (model?.updateStatus == 1) ? "连载中-更新" : "已完结-共";
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: Column(children: [
          // SizedBox(height: Dimens.pt20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () => logic.addCollectComic(model),
              child: Container(
                  height: Dimens.pt46,
                  width: Dimens.pt144,
                  color: Get.find<ThemeManager>().getColor(
                      collected ? ThemeColor.textGrey : ThemeColor.textYellow),
                  child: Center(
                      child: Text(collected ? "已加入" : "加入书架",
                          style: TextStyle(
                              color: Get.find<ThemeManager>()
                                  .getColor(ThemeColor.bg),
                              fontSize: Dimens.pt26)))),
            ),
            Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimens.pt20, vertical: Dimens.pt8),
                color: model?.updateStatus == 1
                    ? theme.getColor(ThemeColor.red).withOpacity(.2)
                    : theme.getColor(ThemeColor.textYellow).withOpacity(.2),
                child: Text("$type${model?.chapterCount ?? 0}章",
                    style: TextStyle(
                        color: model?.updateStatus == 1
                            ? theme.getColor(ThemeColor.red)
                            : theme.getColor(ThemeColor.textYellow),
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
                onTap: ()=> Get.toNamed(Routes.INVITED_PAGE),
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

  Widget buildNovelCoverHeader(NovelDetailPageController logic) {
    final model = logic.novelData.value;
    ThemeManager theme = Get.find<ThemeManager>();

    return Stack(alignment: Alignment.bottomCenter, children: [
      ImageLoader.withP(model?.coverImg ?? "",
              width: screen.screenWidth, height: Dimens.pt560)
          .load(),
      Container(
          width: screen.screenWidth,
          height: Dimens.pt560,
          color: theme.getColor(ThemeColor.bg).withOpacity(.7)),
      Positioned(
          right: Dimens.pt92,
          bottom: Dimens.pt70,
          child: Stack(alignment: Alignment.topRight, children: [
            ImageLoader.withP(model?.coverImg,
                    width: Dimens.pt274, height: Dimens.pt400)
                .load(),
            Positioned(
                right: Dimens.pt15,
                bottom: Dimens.pt15,
                child: Container(
                    width: Dimens.pt55,
                    height: Dimens.pt55,
                    alignment: Alignment.center,
                    color: theme.getColor(ThemeColor.bg).withOpacity(.5),
                    child: Image.asset(R.assetsImgIconNovel,
                        width: Dimens.pt33,
                        color: theme.getColor(ThemeColor.primary))))
          ])),
      Container(
          width: screen.screenWidth,
          padding: EdgeInsets.symmetric(
              horizontal: Dimens.pt25, vertical: Dimens.pt20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPayTypeWidget(
                    model?.novelPayType ?? PaymentType.freePaymentType,
                    price: model?.price ?? 0,
                    width: Dimens.pt80,
                    height: Dimens.pt44,
                    fontSize: Dimens.pt28),
                SizedBox(height: Dimens.pt20),
                SizedBox(
                    width: Dimens.pt350,
                    child: Text("${model?.title}",
                        style: TextStyle(
                            color: Get.find<ThemeManager>()
                                .getColor(ThemeColor.primary),
                            fontSize: Dimens.pt32))),
                SizedBox(height: Dimens.pt20),
                Text("作者：${model?.author}",
                    style: TextStyle(
                        color: Get.find<ThemeManager>()
                            .getColor(ThemeColor.primary),
                        fontSize: Dimens.pt24)),
                SizedBox(height: Dimens.pt20),
                if ((model?.novelTags ?? []).isNotEmpty)
                  SizedBox(
                      height: Dimens.pt45,
                      child: ListView.separated(
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => Get.toNamed(Routes.TAG_DETAIL_PAGE,
                                  arguments: {
                                    "id": "${model?.novelTags?[index].id ?? 0}",
                                    "title":
                                        model?.novelTags?[index].name ?? "",
                                    "mediaType": MediaType.novel.index
                                  }),
                              child: Container(
                                  height: Dimens.pt50,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.pt20),
                                  alignment: Alignment.center,
                                  color: Get.find<ThemeManager>()
                                      .getColor(ThemeColor.bgGrey),
                                  child: Text(
                                      model?.novelTags?[index].name ?? "",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: Get.find<ThemeManager>()
                                              .getColor(ThemeColor.primary)))),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(width: Dimens.pt20),
                          itemCount: model?.novelTags?.length ?? 0,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal))
              ]))
    ]);
  }
}
