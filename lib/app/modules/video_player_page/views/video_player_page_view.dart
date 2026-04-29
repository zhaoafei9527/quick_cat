// 🐦 Flutter imports:
import 'dart:async';

import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/comment_dialog.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/comment_refresh_view.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/fijk_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/utils/app_util.dart';

// import 'package:quick_cat_client/app/widget/common_app_bar.dart';
// import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/global_player_controller.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../../../../plugins_utils/ImageLoader/ImageLoader.dart';

// import '../../../../plugins_utils/VideoPlayer/global_player.dart';
import '../../../../r.dart';
import '../../../../utils/common_util.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/screen.dart';
import '../../../../utils/time_util.dart';
import '../../../data/ads_type.dart';
import '../../../model/home/config_model_model.dart';
import '../../../views/page_pull_view.dart';
import '../../../widget/common_widget.dart';
import '../../../widget/cover_banner.dart';
import '../controllers/video_player_page_controller.dart';

class VideoPlayerPageView extends GetView<VideoPlayerPageController> {
  const VideoPlayerPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<VideoPlayerPageController>(
        builder: (VideoPlayerPageController logic) {
      ThemeManager theme = Get.find<ThemeManager>();
      return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, a) async {
            // if (didPop) return; // 已被其他路由处理
            final playerManager = FIJKPlayerManager();
            if (!playerManager.isShrinkModel) {
              playerManager.disposePlayer();
            }
            return;
          },
          child: LoadingView(
              backgroundColor: theme.getColor(ThemeColor.bg),
              loading: !logic.initOk.value,
              child: buildPlayerDetailPage(logic)));
    });
  }

  buildPlayerDetailPage(VideoPlayerPageController logic) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (logic.showLinePanel.value) logic.showLinePanel.value = false;
          FocusScope.of(Get.context!).unfocus();
        },
        child: Stack(children: [
          Scaffold(
              backgroundColor: theme.getColor(ThemeColor.bg),
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screen.paddingTop),
                    Stack(alignment: Alignment.topLeft, children: [
                      if (logic.changing.value)
                        buildInitializeView(isBuffering: true)
                      else
                        FIJKVideoPlayer(
                            url: logic.videoUrl.value,
                            autoPlay: false,
                            mediaInfo: logic.mediaPlayModel?.mediaInfo,
                            cover: logic.coverImg),
                      _BeforePlayAds(key: ValueKey(logic.videoUrl.value)),
                    ]),
                    if (!shareKeys.isVip())
                      GestureDetector(
                          onTap: () => AppUtils.jumpToHome(index: 2),
                          child: Image.asset(R.assetsImgTipPlayer,
                              width: screen.screenWidth)),
                    SizedBox(height: Dimens.pt25),
                    SizedBox(
                        height: Dimens.pt55,
                        child: Row(children: [
                          buildCommonTabBar(
                              controller: logic.tabController,
                              insets: Dimens.pt12,
                              insetsWidth: 4,
                              boxColor: Color(0xFF6954E7),
                              isScrollable: false,
                              fontSize: Dimens.pt28,
                              alignment: TabAlignment.center,
                              tabs: logic.tabList.map((e) => Text(e)).toList()),
                          Text(getShowWatchNumberStr(logic.comments.value),
                              style: TextStyle(
                                  fontSize: Dimens.pt24,
                                  color: Colors.white.withOpacity(.5)))
                        ])),
                    SizedBox(height: Dimens.pt5),
                    getHengLine(color: Colors.white.withOpacity(.1)),
                    SizedBox(height: Dimens.pt25),
                    Expanded(
                        child: Stack(alignment: Alignment.topRight, children: [
                      TabBarView(controller: logic.tabController, children: [
                        NestedScrollView(
                            headerSliverBuilder: (_, __) {
                              return [
                                SliverToBoxAdapter(child: _buildVideoInfoView())
                              ];
                            },
                            body: buildRecommendVideoView(logic)),
                        Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: Dimens.pt25),
                            child: CommentRefreshView(
                                postId: logic.videoId,
                                topInput: false,
                                type: CommentType.CT_Video,
                                comments: 10))
                      ]),
                      _buildFindAccountPanel()
                    ]))
                  ])),
          logic.changing.value
              ? Container(
                  width: screen.screenWidth,
                  height: screen.screenHeight,
                  color: Colors.black.withOpacity(.7),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(
                            radius: 16,
                            color: theme.getColor(ThemeColor.primary)),
                        SizedBox(height: 20),
                        Text("加载中",
                            style:
                                TextStyle(color: theme.getColor(ThemeColor.bg)))
                      ]))
              : const SizedBox()
        ]));
  }

  Widget _buildVideoInfoView() {
    ThemeManager theme = Get.find<ThemeManager>();
    VideoPlayerPageController logic = Get.find<VideoPlayerPageController>();
    MediaInfo? media = logic.mediaPlayModel?.mediaInfo;
    List<MediaInfo> relatedMedias = logic.relatedMediaList;
    List<MediaInfo> relatedComics = logic.relatedComicList;
    MediaInfo collectMedia = logic.collectMedia.value;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // _buildPlayerUtils(),
      _buildVideoPlayerInfo(logic),
      Container(
          height: Dimens.pt1,
          color: theme.getColor(ThemeColor.primary).withOpacity(.1)),
      SizedBox(height: Dimens.pt20),
      // if (relatedMedias.isNotEmpty) ...[
      //   _buildRelatedMedia(relatedMedias, media, theme), // 关联影片
      //   SizedBox(height: Dimens.pt25)
      // ],
      // if (relatedComics.isNotEmpty) ...[
      //   _buildRelatedComic(relatedComics, theme),
      //   SizedBox(height: Dimens.pt25)
      // ], // 关联漫画
      _buildAdsView(),
      // SizedBox(height: Dimens.pt25),
      if (collectMedia.id != null && collectMedia.id! > 0) ...[
        _buildMediaEpisode(collectMedia, theme), // 推荐合集
        SizedBox(height: Dimens.pt25)
      ],
      SizedBox(height: Dimens.pt30),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: Text("更多推荐",
              style: TextStyle(
                  fontSize: Dimens.pt32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)))
    ]);
  }

  Widget _buildRelatedComic(List<MediaInfo> relatedComics, ThemeManager theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("相关漫画",
          style: TextStyle(
              fontSize: Dimens.pt38,
              color: theme.getColor(ThemeColor.primary))),
      SizedBox(height: Dimens.pt25),
      SizedBox(
          height: Dimens.pt500,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: Dimens.pt25),
              itemBuilder: (c, index) {
                return getMediaCoverItemWidget(
                    relatedComics[index], MediaType.comic,
                    onTap: () =>
                        itemOnTap(relatedComics[index], MediaType.comic),
                    width: Dimens.pt260,
                    height: Dimens.pt380);
              },
              separatorBuilder: (c, index) => SizedBox(width: Dimens.pt5),
              itemCount: relatedComics.length)),
    ]);
  }

  Widget _buildRelatedMedia(
      List<MediaInfo> relateMedias, MediaInfo? media, ThemeManager theme) {
    VideoPlayerPageController logic = Get.find<VideoPlayerPageController>();
    return Column(children: [
      Container(
          width: screen.screenWidth,
          height: Dimens.pt133,
          color: theme.getColor(ThemeColor.bgGrey),
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(media?.title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: Dimens.pt30,
                          color: theme.getColor(ThemeColor.primary))),
                  SizedBox(height: Dimens.pt10),
                  Text("${relateMedias.length}部关联影片",
                      style: TextStyle(
                          fontSize: Dimens.pt22,
                          color: theme.getColor(ThemeColor.textGrey))),
                ])),
            Image.asset(R.assetsImgIconArrowRight,
                width: Dimens.pt40, color: theme.getColor(ThemeColor.primary)),
          ])),
      SizedBox(height: Dimens.pt25),
      SizedBox(
          height: Dimens.pt200,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: Dimens.pt25),
              itemBuilder: (c, index) {
                return GestureDetector(
                  onTap: () =>
                      logic.switchVideoInPage(relateMedias[index].id ?? 0),
                  child: Column(children: [
                    Stack(alignment: Alignment.topRight, children: [
                      ImageLoader.withP(relateMedias[index].coverImg ?? "",
                              width: Dimens.pt270, height: Dimens.pt152)
                          .load(),
                      Positioned(
                          right: Dimens.pt25,
                          child: buildPayTypeWidget(
                              relateMedias[index].payType ??
                                  PaymentType.freePaymentType,
                              price: relateMedias[index].price ?? 0,
                              width: Dimens.pt80,
                              height: Dimens.pt40)),
                      if (relateMedias[index].id == media?.id)
                        Container(
                            width: Dimens.pt270,
                            height: Dimens.pt152,
                            color:
                                theme.getColor(ThemeColor.bg).withOpacity(.8),
                            child: Center(
                                child: Text("正在播放",
                                    style: TextStyle(
                                        fontSize: Dimens.pt30,
                                        color: theme
                                            .getColor(ThemeColor.primary)))))
                    ]),
                    SizedBox(height: Dimens.pt5),
                    SizedBox(
                        width: Dimens.pt260,
                        child: Text(relateMedias[index].title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: Dimens.pt28,
                                color: theme.getColor(ThemeColor.primary))))
                  ]),
                );
              },
              separatorBuilder: (c, index) => SizedBox(width: Dimens.pt5),
              itemCount: relateMedias.length)),
    ]);
  }

  Widget _buildMediaEpisode(MediaInfo? media, ThemeManager theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("推荐合集",
            style: TextStyle(
                fontSize: Dimens.pt38,
                color: theme.getColor(ThemeColor.primary))),
        SizedBox(height: Dimens.pt25),
        Row(children: [
          ImageLoader.withP(media?.coverImg ?? "",
                  width: Dimens.pt356, height: Dimens.pt200)
              .load(),
          SizedBox(width: Dimens.pt25),
          Expanded(
              child: SizedBox(
                  height: Dimens.pt200,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("动漫3D性爱合集",
                            style: TextStyle(
                                fontSize: Dimens.pt30,
                                color: theme.getColor(ThemeColor.primary))),
                        SizedBox(height: Dimens.pt10),
                        Row(children: [
                          Image.asset(R.assetsImgIconCoin, width: Dimens.pt35),
                          SizedBox(width: Dimens.pt8),
                          Text("28金币",
                              style: TextStyle(
                                  fontSize: Dimens.pt24,
                                  color: theme.getColor(ThemeColor.textGrey))),
                        ]),
                        Spacer(),
                        GestureDetector(
                            child: Container(
                                width: Dimens.pt164,
                                height: Dimens.pt56,
                                decoration: BoxDecoration(
                                    color:
                                        theme.getColor(ThemeColor.textYellow)),
                                child: Center(
                                    child: Text("解锁合集",
                                        style: TextStyle(
                                            fontSize: Dimens.pt24,
                                            color: theme
                                                .getColor(ThemeColor.bg)))))),
                      ])))
        ])
      ]),
    );
  }

  Widget buildRecommendVideoView(VideoPlayerPageController logic) {
    return PagePullView<MediaInfo>(
        dataGetter: (int pageNum, int size) async {
          MediaList? media = await logic.getRecommendMediaData(
              pageNum: pageNum, type: logic.mediaType);
          return getMediaListOfList(media, logic.mediaType);
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: buildCommonMediaGrid(list.cast<MediaInfo>(),
                  mediaType: logic.mediaType,
                  onTap: (index) => logic.switchVideoInPage(list[index].id)));
        });
  }

  Widget _buildAdsView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
      child: CoverBanner(
          //广告longVideoSwiperAds
          aspectRatio: 700 / 198,
          adsType: AdsType.homeSwiperAds,
          onItemClick: (Advertise model) {
            AppPages.jumpRouter(path: model.href, id: model.id);
          }),
    );
  }

  Widget _buildVideoPlayerInfo(VideoPlayerPageController logic) {
    ThemeManager theme = Get.find<ThemeManager>();
    MediaInfo? mediaInfo = logic.mediaPlayModel?.mediaInfo;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // SizedBox(height: Dimens.pt20),
          Text(mediaInfo?.title ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: Dimens.pt32, color: Colors.white)),

          SizedBox(height: Dimens.pt40),
          if ((mediaInfo?.tagList?.length ?? 0) > 0)
            SizedBox(
                height: Dimens.pt52,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (c, i) => GestureDetector(
                        onTap: () async {
                          FIJKPlayerManager manage = FIJKPlayerManager();
                          manage.player?.pause();
                          var res = await Get.toNamed(Routes.TAG_DETAIL_PAGE,
                              arguments: {
                                "id": "${mediaInfo?.tagList?[i].id}",
                                "title": mediaInfo?.tagList?[i].name ?? "",
                                "mediaType": logic.mediaType.index,
                                "backResultMark": true
                              });
                          if (res != null) {
                            logic.switchVideoInPage(res.id);
                          }
                        },
                        child: Container(
                            alignment: Alignment.center,
                            padding:
                                EdgeInsets.symmetric(horizontal: Dimens.pt30),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(Dimens.pt45),
                                color: Color(0xFF222433)),
                            child: Center(
                                child: Text(
                                    "#${mediaInfo?.tagList?[i].name ?? " "}",
                                    style: TextStyle(
                                        fontSize: Dimens.pt24,
                                        color: Colors.white))))),
                    separatorBuilder: (c, i) => SizedBox(width: Dimens.pt24),
                    itemCount: mediaInfo?.tagList?.length ?? 0)),
          SizedBox(height: Dimens.pt30),
          getHengLine(color: Colors.white.withOpacity(.1)),
          SizedBox(height: Dimens.pt30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt80),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Obx(() {
                  //   if (logic.paymentType.value ==
                  //       PaymentType.coinPaymentType.index) {
                  //     return _buildVideoNumber(
                  //       icon: R.assetsImgIconGold,
                  //       color: theme.getColor(ThemeColor.red),
                  //       text:
                  //           "${(logic.mediaPlayModel?.mediaInfo?.price ?? 0) ~/ 100}金币",
                  //     );
                  //   } else if (logic.paymentType.value ==
                  //       PaymentType.vipPaymentType.index) {
                  //     return _buildVideoNumber(
                  //         icon: R.assetsImgIconVideoVip,
                  //         color: theme.getColor(ThemeColor.textYellow),
                  //         text: "VIP");
                  //   } else {
                  //     return _buildVideoNumber(
                  //         icon: R.assetsImgIconVideoFree,
                  //         color: theme.getColor(ThemeColor.spring),
                  //         text: "免费");
                  //   }
                  // }),
                  _buildVideoNumber(
                      icon: R.assetsImgIconVideoDownload,
                      // onTap: () => showTypeToast(msg: "功能暂未开放～"),
                      text: getShowWatchNumberStr(mediaInfo?.watchTimes ?? 0)),
                  Obx(() {
                    return _buildVideoNumber(
                        icon: logic.isCollect.value
                            ? R.assetsImgIconVideoCollected
                            : R.assetsImgIconVideoCollect,
                        onTap: () => logic.collectVideo(),
                        text: "${logic.collects.value}");
                  }),

                  _buildVideoNumber(
                      icon: R.assetsImgIconVideoShare,
                      onTap: () => showShareAccountDialog(),
                      text: "分享送VIP"),
                ]),
          ),
          SizedBox(height: Dimens.pt30),
          getHengLine(color: Colors.white.withOpacity(.1)),
        ]));
  }

  Widget _buildVideoNumber(
      {String? icon, String? text, Function? onTap, Color? color}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap?.call(),
        child: Column(children: [
          Image.asset(icon ?? R.assetsImgIconVideoCollect, width: Dimens.pt42),
          SizedBox(height: Dimens.pt20),
          Text(text ?? "",
              style: TextStyle(
                  fontSize: Dimens.pt24, color: color ?? Colors.white))
        ]));
  }

  Widget _buildPlayerUtils() {
    ThemeManager theme = Get.find<ThemeManager>();
    VideoPlayerPageController logic = Get.find<VideoPlayerPageController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
      child: Row(children: [
        Obx(() => GestureDetector(
            onTap: () {
              FIJKPlayerManager manager = FIJKPlayerManager();
              logic.showBarrage.value = !logic.showBarrage.value;
              manager.barrageController
                  ?.setShowBarrage(logic.showBarrage.value);
            },
            child: Image.asset(
                logic.showBarrage.value
                    ? R.assetsImgIconPlayerBarrageOn
                    : R.assetsImgIconPlayerBarrage,
                height: Dimens.pt48))),
        SizedBox(width: Dimens.pt20),
        Expanded(
            child: Container(
          height: Dimens.pt62,
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt20),
          decoration: BoxDecoration(color: theme.getColor(ThemeColor.bgGrey)),
          child: TextField(
              maxLength: 16,
              maxLines: 1,
              minLines: 1,
              controller: logic.barrageField,
              textInputAction: TextInputAction.search,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: theme.getColor(ThemeColor.primary),
                  fontSize: Dimens.pt28),
              onSubmitted: (text) => logic.sendBarrage(),
              decoration: InputDecoration(
                  hoverColor: theme.getColor(ThemeColor.textGrey),
                  suffixIconConstraints: BoxConstraints(maxHeight: Dimens.pt28),
                  hintText: "弹幕君需要您的协助",
                  counterText: '',
                  hintStyle: TextStyle(
                      color: theme.getColor(ThemeColor.textGrey),
                      fontSize: Dimens.pt28),
                  contentPadding: EdgeInsets.only(left: Dimens.pt8),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17.5),
                      borderSide: const BorderSide(color: Colors.transparent)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17.5),
                      borderSide: const BorderSide(color: Colors.transparent)),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17.5),
                      borderSide:
                          const BorderSide(color: Colors.transparent)))),
        )),
        SizedBox(width: Dimens.pt20),
        GestureDetector(
            onTap: () => logic.sendBarrage(),
            child: Obx(() => Container(
                width: Dimens.pt88,
                height: Dimens.pt62,
                decoration: BoxDecoration(
                    color: logic.barrageText.value.isNotEmpty
                        ? theme.getColor(ThemeColor.textYellow)
                        : theme.getColor(ThemeColor.bgGrey)),
                child: Align(
                    alignment: Alignment.center,
                    child: Text("发送",
                        style: TextStyle(
                            fontSize: Dimens.pt24,
                            color: logic.barrageText.value.isNotEmpty
                                ? theme.getColor(ThemeColor.bg)
                                : theme.getColor(ThemeColor.textGrey)))))))
      ]),
    );
  }

  Widget buildInitializeView({bool isBuffering = false}) {
    ThemeManager theme = Get.find<ThemeManager>();
    VideoPlayerPageController logic = Get.find<VideoPlayerPageController>();
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(alignment: Alignment.center, children: [
          Container(
              color: isBuffering
                  ? theme.getColor(ThemeColor.bg).withOpacity(.7)
                  : theme.getColor(ThemeColor.bg)),
          if (logic.coverImg.isNotEmpty && !isBuffering)
            ImageLoader.withP(logic.coverImg, showShimmer: false).load(),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CupertinoActivityIndicator(
                radius: 16, color: theme.getColor(ThemeColor.primary)),
            SizedBox(height: 20),
            Text("加载中", style: TextStyle(color: theme.getColor(ThemeColor.bg)))
          ])
        ]));
  }

  Widget _buildFindAccountPanel() {
    ThemeManager theme = Get.find<ThemeManager>();
    VideoPlayerPageController logic = Get.find<VideoPlayerPageController>();
    List<String> line = ["普通线路", "高速线路", "会员专属"];
    return Obx(() => Transform.translate(
        offset: Offset(-Dimens.pt25, -Dimens.pt25),
        child: Visibility(
            visible: logic.showLinePanel.value,
            child: Container(
              width: Dimens.pt160,
              height: Dimens.pt212,
              padding: EdgeInsets.symmetric(vertical: Dimens.pt15),
              decoration: BoxDecoration(
                  color: theme.getColor(ThemeColor.primary),
                  border:
                      Border.all(color: theme.getColor(ThemeColor.primary))),
              child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => logic.changeVideoLine(index, line[index]),
                        child: Center(
                          child: Text(line[index],
                              style: TextStyle(
                                  fontSize: Dimens.pt25,
                                  color: index == logic.shareKeys!.lineIndex
                                      ? theme.getColor(ThemeColor.textYellow)
                                      : theme.getColor(ThemeColor.bg))),
                        ));
                  },
                  separatorBuilder: (context, index) => getHengLine(
                      color: Color(0xFFF1F1F1),
                      paddingTop: Dimens.pt15,
                      paddingBottom: Dimens.pt15,
                      h: Dimens.pt2),
                  itemCount: line.length),
            ))));
  }
}

class _BeforePlayAds extends StatefulWidget {
  const _BeforePlayAds({Key? key}) : super(key: key);

  @override
  State<_BeforePlayAds> createState() => _BeforePlayAdsState();
}

class _BeforePlayAdsState extends State<_BeforePlayAds> {
  int adsTime = 6;
  Timer? adsTimer;
  late Future<dynamic> _adsFuture;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _adsFuture = getCommentAds(type: AdsType.beforePlayingAds);
    adsTimer = Timer.periodic(const Duration(seconds: 1), (time) {
      if (!mounted || _closed) return;
      if (adsTime > 0) {
        adsTime -= 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_closed) setState(() {});
        });
      }
      if (adsTime <= 0) {
        _closeFromBuild();
      }
    });
  }

  void _closeFromBuild() {
    if (_closed) return;
    _closed = true;
    adsTimer?.cancel();
    adsTimer = null;
    adsTime = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
      final playerManager = FIJKPlayerManager();
      playerManager.playMark = true;
      playerManager.player?.start();
    });
  }

  @override
  void dispose() {
    adsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    if (adsTime <= 0) return const SizedBox();
    return FutureBuilder(
        future: _adsFuture,
        builder: (context, snapshot) {
          final connectionDone =
              snapshot.connectionState == ConnectionState.done;
          if (adsTime <= 0) {
            return const SizedBox();
          }
          if (connectionDone) {
            final data = snapshot.data;
            // 无数据或异常 -> 跳过广告
            if (data == null) {
              _closeFromBuild();

              return const SizedBox();
            }
            // VIP 且配置为不展示广告 -> 跳过广告
            final shareKeys = Get.find<ShareKeys>();
            final bool vipSkip = shareKeys.isVip() && !(data?.vipShow ?? false);
            if (vipSkip) {
              _closeFromBuild();
              return const SizedBox();
            }
          }

          return GestureDetector(
            onTap: () {
              FIJKPlayerManager manager = FIJKPlayerManager();
              manager.player?.stop();
              AppPages.jumpRouter(
                  path: snapshot.data?.href ?? "", id: snapshot.data?.id);
            },
            child: Stack(alignment: Alignment.topRight, children: [
              AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ImageLoader.withP(snapshot.data?.cover ?? "",
                          width: screen.screenWidth)
                      .load()),
              Container(
                  width: Dimens.pt440,
                  height: Dimens.pt40,
                  color: Colors.black.withOpacity(.7),
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("$adsTime | 会员关闭此广告",
                            style: TextStyle(
                                fontSize: Dimens.pt26, color: Colors.white)),
                        Text("特惠获得会员",
                            style: TextStyle(
                                fontSize: Dimens.pt26,
                                color: theme.getColor(ThemeColor.textYellow)))
                      ]))
            ]),
          );
        });
  }
}
