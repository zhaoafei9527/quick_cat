import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/episode_preview.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/comment_refresh_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/episode_preview_page_controller.dart';

class EpisodePreviewPageView extends GetView<EpisodePreviewPageController> {
  const EpisodePreviewPageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<EpisodePreviewPageController>(builder: (logic) {
      EpisodeItem prev = logic.previousPreview.value;
      EpisodeItem next = logic.nextPreview.value;
      EpisodeItem now = logic.nowPreview.value;
      return Scaffold(
        key: logic.drawerKey,
        backgroundColor: theme.getColor(ThemeColor.bg),
        appBar: getCommonAppBar("新番预告", actions: [
          GestureDetector(
              onTap: () => logic.drawerStatus.value
                  ? logic.drawerKey.currentState?.closeEndDrawer()
                  : logic.drawerKey.currentState?.openEndDrawer(),
              child: Icon(Icons.menu,
                  size: Dimens.pt45,
                  color: theme.getColor(ThemeColor.textYellow))),
          SizedBox(width: Dimens.pt25)
        ]),
        endDrawer: _buildEndDrawerView(),
        body: !logic.loading.value
            ? SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    ImageLoader.withP(logic.nowPreview.value.coverImg,
                            height: Dimens.pt330, width: screen.screenWidth)
                        .load(),
                    SizedBox(height: Dimens.pt25),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                if ((prev.year ?? 0) > 0) ...[
                                  Icon(Icons.arrow_back_ios_new,
                                      size: Dimens.pt30,
                                      color: theme
                                          .getColor(ThemeColor.textYellow)),
                                  GestureDetector(
                                      onTap: () =>
                                          logic.getPreviewDetailNetData(
                                              prev.id ?? 0),
                                      child: Text(
                                          "${prev.year}年${prev.month}月新番表",
                                          style: TextStyle(
                                              fontSize: Dimens.pt28,
                                              color: theme.getColor(
                                                  ThemeColor.textYellow))))
                                ],
                                Spacer(),
                                if ((next.year ?? 0) > 0) ...[
                                  GestureDetector(
                                    onTap: () => logic
                                        .getPreviewDetailNetData(next.id ?? 0),
                                    child: Text(
                                        "${next.year}年${next.month}月新番表",
                                        style: TextStyle(
                                            fontSize: Dimens.pt28,
                                            color: theme.getColor(
                                                ThemeColor.textYellow))),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: Dimens.pt30,
                                      color:
                                          theme.getColor(ThemeColor.textYellow))
                                ]
                              ]),
                              SizedBox(height: Dimens.pt40),
                              Text("${now.year}年${now.month}月新番列表",
                                  style: TextStyle(
                                      fontSize: Dimens.pt38,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          theme.getColor(ThemeColor.primary))),
                              SizedBox(height: Dimens.pt5),
                              Text(now.desc ?? "",
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      color:
                                          theme.getColor(ThemeColor.textGrey))),
                              SizedBox(height: Dimens.pt40),
                              SizedBox(height: Dimens.pt25),
                              Text("新番详情介绍",
                                  style: TextStyle(
                                      fontSize: Dimens.pt38,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          theme.getColor(ThemeColor.primary))),
                              SizedBox(height: Dimens.pt25),
                              buildNowPreviewDetailList(),
                              SizedBox(
                                  height: screen.screenHeight / 2,
                                  child: CommentRefreshView(
                                      postId: logic.nowPreviewId,
                                      topInput: true,
                                      type: CommentType.CT_Preview,
                                      comments: 10)),
                              SizedBox(height: screen.paddingBottom)
                            ])),
                  ]))
            : getLoadingWidget(),
      );
    });
  }

  Widget buildNowPreviewDetailList() {
    ThemeManager theme = Get.find<ThemeManager>();
    return Obx(() {
      EpisodePreviewPageController logic =
          Get.find<EpisodePreviewPageController>();
      return Column(
          children: List.generate(logic.previewList.length, (index) {
        MediaInfo? media = logic.previewList[index].mediaInfo;
        ListElement previewList = logic.previewList[index];
        bool noMedia = (previewList.mediaId ?? 0) <= 0;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Stack(children: [
              ImageLoader.withP(
                      noMedia ? previewList.coverImg : media?.coverImg,
                      width: Dimens.pt270,
                      height: Dimens.pt390)
                  .load(),
              Container(
                  width: Dimens.pt115,
                  alignment: Alignment.center,
                  color: theme.getColor(ThemeColor.bg).withOpacity(.6),
                  height: Dimens.pt45,
                  child: Text(
                      TimeUtil.buildYYMMDDToNormal(
                          previewList.publishedAt ?? "",
                          showYear: false),
                      style: TextStyle(
                          fontSize: Dimens.pt26,
                          color: theme.getColor(ThemeColor.primary))))
            ]),
            SizedBox(width: Dimens.pt25),
            Expanded(
                child: SizedBox(
                    height: Dimens.pt390,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!noMedia)
                            GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.VIDEO_PLAYER_PAGE,
                                      arguments: {
                                        "id": "${media?.id}",
                                        "mediaType": MediaType.videoLong.index
                                      });
                                },
                                child: Container(
                                    width: Dimens.pt270,
                                    height: Dimens.pt81,
                                    color: theme.getColor(
                                        previewList.status == 1
                                            ? ThemeColor.spring
                                            : ThemeColor.textYellow),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.play_circle_outline,
                                              size: Dimens.pt38,
                                              color: theme
                                                  .getColor(ThemeColor.bg)),
                                          SizedBox(width: Dimens.pt10),
                                          Text(
                                              previewList.status == 1
                                                  ? "预告片"
                                                  : "正片",
                                              style: TextStyle(
                                                  fontSize: Dimens.pt28,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme
                                                      .getColor(ThemeColor.bg)))
                                        ]))),
                          SizedBox(height: Dimens.pt15),
                          Text(
                              noMedia
                                  ? previewList.title ?? ""
                                  : media?.title ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: Dimens.pt28,
                                  color: theme.getColor(ThemeColor.primary))),
                          SizedBox(height: Dimens.pt15),
                          if (!noMedia)
                            Container(
                                margin: EdgeInsets.only(right: Dimens.pt30),
                                child: buildPayTypeWidget(
                                    media?.payType ??
                                        PaymentType.vipPaymentType,
                                    price: media?.price)),
                          SizedBox(height: Dimens.pt50),
                          Text(
                              "${TimeUtil.buildChineseYYMMDD(previewList.publishedAt ?? "")} 上市",
                              style: TextStyle(
                                  fontSize: Dimens.pt24,
                                  color: theme.getColor(ThemeColor.textGrey)))
                        ])))
          ]),
          SizedBox(height: Dimens.pt10),
          Text(previewList.desc ?? "",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: Dimens.pt24,
                  color: theme.getColor(ThemeColor.textGrey))),
          SizedBox(height: Dimens.pt20),
          if (media?.tagList?.isNotEmpty ?? false)
            SizedBox(
                height: Dimens.pt44,
                width: screen.screenWidth,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.TAG_DETAIL_PAGE, arguments: {
                            "id": "${media?.tagList?[index].id}",
                            "title": media?.tagList?[index].name ?? "",
                            "mediaType": MediaType.cartoon.index
                          });
                        },
                        child: Container(
                            alignment: Alignment.center,
                            padding:
                                EdgeInsets.symmetric(horizontal: Dimens.pt15),
                            height: Dimens.pt47,
                            color: theme.getColor(ThemeColor.bgGrey),
                            child: Text(media?.tagList?[index].name ?? "",
                                style: TextStyle(
                                    fontSize: Dimens.pt26,
                                    color:
                                        theme.getColor(ThemeColor.primary))))),
                    separatorBuilder: (context, index) =>
                        SizedBox(width: Dimens.pt25),
                    itemCount: media?.tagList?.length ?? 0)),
          SizedBox(height: Dimens.pt20),
          SizedBox(
              height: Dimens.pt160,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => GestureDetector(
                        onTap: () => Get.toNamed(Routes.PREVIEW_IMAGE_VIEWER,
                            arguments: {
                              "title": media?.title ?? "",
                              "images": previewList.images
                            }),
                        child: ImageLoader.withP(
                          previewList.images?[index].comicsPic ?? "",
                          width: Dimens.pt216,
                          height: Dimens.pt160,
                        ).load(),
                      ),
                  separatorBuilder: (context, index) =>
                      SizedBox(width: Dimens.pt25),
                  itemCount: previewList.images?.length ?? 0)),
          SizedBox(height: Dimens.pt25)
        ]);
      }));
    });
  }

  Widget _buildEndDrawerView() {
    ThemeManager theme = Get.find<ThemeManager>();
    EpisodePreviewPageController logic =
        Get.find<EpisodePreviewPageController>();
    if (logic.tabController == null) {
      return Container();
    }
    return Container(
        width: Dimens.pt450,
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        color: theme.getColor(ThemeColor.bg),
        child: Column(children: [
          SizedBox(height: screen.paddingTop + Dimens.pt20),
          SizedBox(
              height: Dimens.pt66,
              child: buildCommonTabBar(
                  controller: logic.tabController,
                  insets: Dimens.pt38,
                  isScrollable: true,
                  alignment: TabAlignment.start,
                  tabs: logic.yearList.map((e) => Text("$e")).toList())),
          SizedBox(height: Dimens.pt20),
          Expanded(
              child: TabBarView(controller: logic.tabController, children: [
            ...List.generate(logic.yearList.length, (index) {
              return logic.currentIndex.value == index
                  ? logic.episodeList.isNotEmpty
                      ? ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, key) {
                            EpisodeItem prv = logic.episodeList[key];
                            return GestureDetector(
                                onTap: () =>
                                    logic.getPreviewDetailNetData(prv.id ?? 0),
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ImageLoader.withP(prv.coverImg,
                                              height: Dimens.pt98,
                                              width: Dimens.pt400)
                                          .load(),
                                      Container(
                                          width: Dimens.pt400,
                                          height: Dimens.pt98,
                                          color: theme
                                              .getColor(ThemeColor.bg)
                                              .withOpacity(.6)),
                                      Text("${prv.year}年${prv.month}月新番表",
                                          style: TextStyle(
                                              fontSize: Dimens.pt26,
                                              color: theme.getColor(
                                                  ThemeColor.textYellow)))
                                    ]));
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: Dimens.pt25),
                          itemCount: logic.episodeList.length)
                      : buildCommonEmptyView("什么也没找到～")
                  : getLoadingWidget();
            })
          ]))
        ]));
  }
}
