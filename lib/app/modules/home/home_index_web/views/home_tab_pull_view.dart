import 'dart:ffi';

import 'package:acgn_client/app/data/ads_type.dart';
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/model/home/config_model_model.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/modules/home/home_index_web/controllers/home_index_web_controller.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/views/page_pull_view.dart';
import 'package:acgn_client/app/views/pull_refresh_view.dart';
import 'package:acgn_client/app/widget/colored_marquee.dart';
import 'package:acgn_client/app/widget/comic_topic_builder.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/app/widget/cover_banner.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/app_util.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

typedef AsyncListValueGetter<V> = Function({int pageNum, int id});

class HomeTabBarPullView<V> extends StatefulWidget {
  final int id;
  final int type;
  final CategoryShowType? showType;
  final AsyncListValueGetter<V> dataGetter;
  final Function(TopicList)? topicBuilder;

  const HomeTabBarPullView({
    super.key,
    this.id = 0,
    this.showType,
    required this.type,
    this.topicBuilder,
    required this.dataGetter,
  });

  @override
  State<HomeTabBarPullView> createState() => _HomeComicCateTabBarViewState();
}

class _HomeComicCateTabBarViewState extends State<HomeTabBarPullView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<TopicList> topicList = [];
  List<MediaInfo> mediaList = [];
  int pageNum = 1;
  double getBalanceIng = .0;

  int get id => widget.id;
  TabController? sortTabController;
  List<String> tabList = ["最新更新", "最高人气", "最多收藏"];
  PullRefreshController pullRefreshController = PullRefreshController();
  List<gridItemModel> gridList = [];

  @override
  void initState() {
    loadData();
    sortTabController = TabController(length: tabList.length, vsync: this);
    ShareKeys shareKeys = Get.find<ShareKeys>();
    gridList = shareKeys.gridItemMap?[MediaType.values[widget.type]] ?? [];
    if (widget.type == MediaType.comic.index ||
        widget.type == MediaType.novel.index) {
      tabList[2] = "最多收藏";
    } else {
      tabList[2] = "最多评论";
    }
    super.initState();
  }

  loadData() async {
    pageNum = 1;
    TopicList? model = await widget.dataGetter(id: id, pageNum: pageNum);
    if (widget.showType == CategoryShowType.topicShowType) {
      topicList.assignAll(model?.topicList ?? []);
    } else {
      mediaList.assignAll(model?.list ?? []);
    }
    bool isEmpty = (widget.showType == CategoryShowType.topicShowType
        ? (model?.topicList ?? []).isEmpty
        : (model?.list ?? []).isEmpty);
    pullRefreshController.requestSuccess(isFirstPage: true, isEmpty: isEmpty);
    setState(() {});
  }

  void loadMoreData() async {
    var page = pageNum += 1;
    TopicList? model = await widget.dataGetter(id: id, pageNum: page);
    if (model != null) {
      pageNum = page;
      if (widget.showType == CategoryShowType.topicShowType) {
        topicList.addAll((model.topicList ?? []));
      } else {
        mediaList.addAll(model.list ?? []);
      }

      bool hasMore = (widget.showType == CategoryShowType.topicShowType
          ? (model.topicList ?? []).length >= 10
          : (model.list ?? []).length >= 10);

      pullRefreshController.requestSuccess(
          isFirstPage: false, hasMore: hasMore);
      setState(() {});
    } else {
      pullRefreshController.requestFail(isFirstPage: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.showType == CategoryShowType.topicShowType
        ? PullRefreshView(
            controller: pullRefreshController,
            onLoading: () => loadMoreData(),
            onRefresh: () => loadData(),
            child: buildTopicTypeContent())
        : widget.showType == CategoryShowType.bigListShowType
            ? buildBigListTypeContent()
            : widget.showType == CategoryShowType.aiShowType
                ? buildAiRecommendList()
                : Container();
  }

  Widget buildAiRecommendList() {
    return NestedScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (_, __) =>
            [SliverToBoxAdapter(child: buildTopGridWidget())],
        body: Column(children: [
          Expanded(
              child: PagePullView<MediaInfo>(
                  key: Key("pullKey_${widget.type}"),
                  dataGetter: (int pageNum, int size) async {
                    MediaList? media =
                        await widget.dataGetter(pageNum: pageNum, id: id);
                    return getMediaListOfList(
                        media, MediaType.values[widget.type]);
                  },
                  emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
                  widgetBuilder: (BuildContext context, List<dynamic> list,
                      Widget? child) {
                    MediaType mediaType = MediaType.values[widget.type];

                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                        child: buildCommonMediaGrid(list.cast<MediaInfo>(),
                            mediaType: mediaType, paddingTop: .0));
                  }))
        ]));
  }

  Widget buildBigListTypeContent() {
    return NestedScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(child: buildTopGridWidget()),
              SliverToBoxAdapter(
                  child: buildCommonTabBar(
                      controller: sortTabController,
                      insets: Dimens.pt38,
                      isScrollable: true,
                      alignment: TabAlignment.center,
                      tabs: tabList.map((e) => Text(e)).toList()))
            ],
        body: Column(children: [
          SizedBox(height: Dimens.pt20),
          Expanded(
              child: TabBarView(
                  controller: sortTabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                ...List.generate(tabList.length, (index) {
                  return buildPagePullView(index);
                })
              ]))
        ]));
  }

  Widget buildPagePullView(int index) {
    return PagePullView<MediaInfo>(
        key: Key("pullKey_$index"),
        dataGetter: (int pageNum, int size) async {
          TopicList? media = await widget.dataGetter(pageNum: pageNum, id: id);
          return media?.list ?? [];
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          MediaType mediaType = MediaType.values[widget.type];
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: buildCommonMediaGrid(list.cast<MediaInfo>(),
                  mediaType: mediaType));
        });
  }

  Widget buildTopicTypeContent() {
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: buildTopGridWidget()),
      SliverList(
          delegate: SliverChildBuilderDelegate((c, index) {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            child: Column(children: [
              topicHeaderBuilder(topicList[index],
                  type: widget.type, showMore: true),
              widget.topicBuilder?.call(topicList[index])
            ]));
      },
              childCount: topicList.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false))
    ]);
  }

  Widget buildTopGridWidget() {
    ThemeManager theme = Get.find<ThemeManager>();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    bool isComics = widget.type == MediaType.comic.index ||
        widget.type == MediaType.novel.index;
    return Column(children: [
      CoverBanner(
          //广告homeSwiperAds
          aspectRatio: 750 / 336,
          adsType: AdsType.homeSwiperAds,
          onItemClick: (Advertise model) {
            AppPages.jumpRouter(path: model.href, id: model.id);
          }),
      SizedBox(height: Dimens.pt25),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}

Widget buildRunningLightView() {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  return shareKeys.runningLight != null
      ? Column(
          children: [
            Image.asset(R.assetsImgLineRunlight, width: double.infinity),
            SizedBox(
                height: Dimens.pt86,
                child: Row(children: [
                  Image.asset(R.assetsImgIconBroadcast, width: Dimens.pt48),
                  SizedBox(width: Dimens.pt20),
                  Expanded(
                      child: MarqueeRich(
                          text: TextSpan(
                              style: TextStyle(fontSize: Dimens.pt28),
                              children: [
                                TextSpan(
                                    text: shareKeys.runningLight?.title ?? "",
                                    style: TextStyle(
                                        color: AppColors.primaryColor)),
                                TextSpan(
                                    text: shareKeys.runningLight?.content ?? "",
                                    style: TextStyle(
                                        color: AppColors.textColorWhite))
                              ]),
                          velocity: 1.2,
                          gap: 30,
                          height: Dimens.pt72))
                ])),
            Image.asset(R.assetsImgLineRunlight, width: double.infinity),
          ],
        )
      : SizedBox();
}

Widget buildHeaderAdsView() {
  HomeIndexWebController homeIndex = Get.find<HomeIndexWebController>();
  //广告homeGameIconAds
  return Obx(
    () => homeIndex.gameAdList.isNotEmpty
        ? Container(
            height: Dimens.pt132,
            margin: EdgeInsets.only(bottom: Dimens.pt25),
            // padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (c, i) {
                  return GestureDetector(
                      onTap: () {
                        AppPages.jumpRouter(path: homeIndex.gameAdList[i].href);
                      },
                      child: ImageLoader.withP(
                              homeIndex.gameAdList[i].cover ?? "",
                              width: Dimens.pt132)
                          .load());
                },
                separatorBuilder: (c, i) => SizedBox(width: Dimens.pt10),
                itemCount: homeIndex.gameAdList.length))
        : SizedBox(),
  );
}
