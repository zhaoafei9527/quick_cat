import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/common_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

/// 构建主页面所有专题
/// [topic] 主题数据
/// [onItemClick] 点击事件
/// [showMore] 是否显示更多按钮
/// [type] 主题类型
/// [showChangeMore] 是否显示切换更多按钮

Widget buildMediaTopicWidget(TopicList topic, MediaType type,
    {ValueChanged<int>? onItemClick,
    bool showMore = true,
    bool showChangeMore = false}) {
  /// 添加默认的item点击事件
  if (null == onItemClick && (topic.list ?? []).isNotEmpty) {
    onItemClick = (index) {
      var model = topic.list![index];
      if (model.id != null) itemOnTap(model, type);
    };
  }

  // 创建一个可观察的TopicList
  final Rx<TopicList> observableTopic = topic.obs;
  // 创建加载状态控制器
  final RxBool isLoading = false.obs;
  // 获取主题类型
  topic.coverType ??= (type == MediaType.comic || type == MediaType.novel)
      ? CoverType.coverVertical.index
      : CoverType.coverHorizontal.index;
  // final CoverType coverType = CoverType.values[topic.coverType ?? 1];

  Widget child = Container();
  if (topic.name == "素人无码") {
    print(
        "showType:${topic.showType}==${topic.contentType}==${topic.coverType}===${type}");
  }
  // 视频才会有五宫格
  if (topic.showType == TopicShowType.fiveGrid &&
      (type == MediaType.videoLong ||
          type == MediaType.cartoon ||
          type == MediaType.darkWeb)) {
    child = FiveGridBuilder(observableTopic, type: type);
  } else if (topic.showType == TopicShowType.sixGridThree) {
    // 小
    child = SixVerticalGridBuilder(observableTopic, type: type);
  } else if (topic.showType == TopicShowType.nineGridThree) {
    // 小
    child = SixVerticalGridBuilder(observableTopic, type: type);
  } else if (topic.showType == TopicShowType.sixGridTwo) {
    // 大
    double aspectRatio = 226 / 405;
    if (type != MediaType.comic && type != MediaType.novel) {
      aspectRatio = 226 / 365;
    }
    if (topic.coverType == CoverType.coverHorizontal.index) {
      aspectRatio = 345 / 250;
    }
    child = SixVerticalGridBuilder(observableTopic,
        type: type, crossAxisCount: 2, childAspectRatio: aspectRatio);
  } else if (topic.showType == TopicShowType.nineGridThree) {
    // 小
    child = SixVerticalGridBuilder(observableTopic, type: type);
  } else if (topic.showType == TopicShowType.scrollHorizontal) {
    child = ScrollHorizontalBuilder(observableTopic, type: type);
  } else if (topic.showType == TopicShowType.bigCoverList) {
    child = BigCoverListBuilder(observableTopic, type: type);
  } else {
    child = ScrollHorizontalBuilder(observableTopic, type: type);
  }

  return Container(
      margin: (topic.list ?? []).isNotEmpty
          ? EdgeInsets.only(bottom: Dimens.pt8)
          : null,
      child: Column(children: [
        child,
        // ChangeMoreCoversBuilder(
        //     isLoading: isLoading,
        //     onMoreTap: () => onTapMediaTopic(topic, type),
        //     onChangeTap: () => _changeMediaList(
        //         observableTopic, topic.id ?? 0, isLoading, type))
      ]));
}

/// 大封面列表
class BigCoverListBuilder extends StatelessWidget {
  final Rx<TopicList> topic;
  final ValueChanged<int>? onItemClick;
  final MediaType type;

  const BigCoverListBuilder(this.topic,
      {this.onItemClick, super.key, required this.type});

  List<MediaInfo> get mediaList => topic.value.list ?? [];

  CoverType get coverType => CoverType.values[topic.value.coverType ?? 1];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(children: [
          SizedBox(height: Dimens.pt25),
          ...List.generate(
              mediaList.length,
              (index) => SizedBox(
                  width: screen.screenWidth,
                  height: Dimens.pt444 + Dimens.pt20,
                  child: getMediaCoverItemWidget(mediaList[index], type,
                      coverType: coverType,
                      width: screen.screenWidth,
                      height: Dimens.pt400)))
        ]));
  }
}

/// 横向滚动列表
class ScrollHorizontalBuilder extends StatelessWidget {
  final Rx<TopicList> topic;
  final ValueChanged<int>? onItemClick;
  final MediaType type;

  ScrollHorizontalBuilder(this.topic,
      {this.onItemClick, super.key, required this.type});

  List<MediaInfo> get mediaList => topic.value.list ?? [];

  CoverType get coverType => CoverType.values[topic.value.coverType ?? 1];
  double height = Dimens.pt380;
  double width = Dimens.pt260;

  @override
  Widget build(BuildContext context) {
    if (type == MediaType.videoLong || type == MediaType.darkWeb) {
      height = Dimens.pt152;
      width = Dimens.pt270;
    }
    if (coverType == CoverType.coverHorizontal) {
      height = Dimens.pt152;
    }
    return Obx(() => Container(
        width: screen.screenWidth,
        height: coverType == CoverType.coverVertical
            ? Dimens.pt470 + Dimens.pt20
            : Dimens.pt200,
        margin: EdgeInsets.symmetric(vertical: Dimens.pt30),
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => getMediaCoverItemWidget(
                mediaList[index], type,
                height: height, width: width),
            separatorBuilder: (context, index) => SizedBox(width: Dimens.pt10),
            itemCount: mediaList.length)));
  }
}

class SixHorizontalGridBuilder extends StatelessWidget {
  final Rx<TopicList> topic;
  final ValueChanged<int>? onItemClick;
  final MediaType type;
  final CoverType? coverType;

  const SixHorizontalGridBuilder(this.topic,
      {this.onItemClick, super.key, required this.type, this.coverType});

  List<MediaInfo> get mediaList => topic.value.list ?? [];

  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(top: Dimens.pt25, bottom: Dimens.pt45),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, //横向数量
            crossAxisSpacing: Dimens.pt10,
            mainAxisSpacing: Dimens.pt10,
            childAspectRatio: 345 / 243),
        itemCount: mediaList.length,
        itemBuilder: (c, index) {
          return getMediaCoverItemWidget(mediaList[index], type);
        }));
  }
}

class FiveGridBuilder extends StatelessWidget {
  final Rx<TopicList> topic;
  final ValueChanged<int>? onItemClick;
  final MediaType type;

  const FiveGridBuilder(this.topic,
      {super.key, this.onItemClick, required this.type});

  List<MediaInfo> get mediaList => topic.value.list ?? [];

  CoverType get coverType => CoverType.values[topic.value.coverType ?? 1];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      MediaInfo firstMedia = mediaList.first;
      List<MediaInfo> sublist = mediaList.sublist(1, 5);
      if (mediaList.isEmpty || mediaList.length <= 2) {
        return Container();
      }
      return Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: Dimens.pt20),
        SizedBox(
            width: screen.screenWidth,
            height: Dimens.pt444 + Dimens.pt4,
            child: getMediaCoverItemWidget(firstMedia, type,
                coverType: coverType,
                height: Dimens.pt400,
                width: screen.screenWidth)),
        gridViewBuilder(sublist,
            crossAxisCount: 2,
            childAspectRatio: 345 / 250,
            type: type,
            height: Dimens.pt200,
            width: Dimens.pt350 + Dimens.pt2,
            coverType: coverType)
      ]);
    });
  }
}

Widget buildCommonMediaGrid(List<MediaInfo> mediaList,
    {MediaType mediaType = MediaType.videoLong,
    Function(int)? onTap,
    Function(int pageNum)? dataGetter,
    double? paddingTop}) {
  if (mediaType == MediaType.comic || mediaType == MediaType.novel) {
    return gridViewBuilder(mediaList,
        type: mediaType, paddingTop: paddingTop, onTap: onTap);
  } else if (mediaType == MediaType.videoLong ||
      mediaType == MediaType.darkWeb) {
    return gridViewBuilder(mediaList,
        type: mediaType,
        crossAxisCount: 2,
        childAspectRatio: 345 / 250,
        height: Dimens.pt200,
        onTap: onTap,
        paddingTop: paddingTop,
        width: Dimens.pt350 + Dimens.pt2);
  } else if (mediaType == MediaType.videoShort) {
    return MasonryGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: Dimens.pt10,
        mainAxisSpacing: Dimens.pt10,
        padding: EdgeInsets.only(top: Dimens.pt12),
        itemCount: mediaList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          bool isH = (mediaList[index].coverData?.width ?? 0) >
              (mediaList[index].coverData?.high ?? 0);
          return SizedBox(
              height: isH ? Dimens.pt250 : Dimens.pt560,
              width: Dimens.pt340 + Dimens.pt5,
              child: getMediaCoverItemWidget(mediaList[index], mediaType,
                  onTap: () => onTap != null
                      ? onTap.call(index)
                      : shortVideoItemOnTap(
                          index: index,
                          mediaList: mediaList,
                          dataGetter: dataGetter),
                  height: isH ? Dimens.pt200 : Dimens.pt500,
                  width: Dimens.pt340 + Dimens.pt5));
        });
  } else if (mediaType == MediaType.cartoon) {
    return MasonryGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: Dimens.pt10,
        mainAxisSpacing: Dimens.pt10,
        itemCount: mediaList.length,
        shrinkWrap: true,
        padding: EdgeInsets.only(top: Dimens.pt12),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          bool isH = (mediaList[index].coverData?.width ?? 0) >=
              (mediaList[index].coverData?.high ?? 0);

          return SizedBox(
              height: isH ? Dimens.pt250 : Dimens.pt560,
              width: Dimens.pt340 + Dimens.pt5,
              child: getMediaCoverItemWidget(mediaList[index], mediaType,
                  onTap: () => onTap != null
                      ? onTap.call(index)
                      : itemOnTap(mediaList[index], mediaType),
                  height: isH ? Dimens.pt200 : Dimens.pt500,
                  width: Dimens.pt340 + Dimens.pt5));
        });
  } else {
    return Container();
  }
}

Widget gridViewBuilder(List<MediaInfo> mediaList,
    {int? crossAxisCount,
    double? childAspectRatio,
    MediaType type = MediaType.videoLong,
    double? paddingTop,
    double? width,
    double? height,
    Function(int)? onTap,
    CoverType? coverType}) {
  return GridView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      padding:
          EdgeInsets.only(top: paddingTop ?? Dimens.pt15, bottom: Dimens.pt45),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount ?? 3, //横向数量
          crossAxisSpacing: Dimens.pt10,
          mainAxisSpacing: Dimens.pt10,
          childAspectRatio: childAspectRatio ?? 226 / 435),
      itemCount: mediaList.length,
      itemBuilder: (c, index) {
        return getMediaCoverItemWidget(mediaList[index], type,
            onTap: () => onTap != null
                ? onTap.call(index)
                : itemOnTap(mediaList[index], type),
            coverType: coverType,
            width: width,
            height: height);
      });
}

class SixVerticalGridBuilder extends StatelessWidget {
  final Rx<TopicList> topic;
  final ValueChanged<int>? onItemClick;
  final MediaType type;
  final int? crossAxisCount;
  final double? childAspectRatio;

  SixVerticalGridBuilder(this.topic,
      {this.onItemClick,
      super.key,
      required this.type,
      this.crossAxisCount,
      this.childAspectRatio});

  List<MediaInfo> get mediaList => topic.value.list ?? [];

  CoverType get coverType => CoverType.values[topic.value.coverType ?? 1];

  double width = Dimens.pt236;
  double height = Dimens.pt330;
  double aspectRatio = 226 / 425;

  @override
  Widget build(BuildContext context) {
    if ((crossAxisCount ?? 3) == 2 && coverType == CoverType.coverHorizontal) {
      aspectRatio = 335 / 255;
      width = Dimens.pt335;
      height = Dimens.pt197 + Dimens.pt1;
    } else if ((crossAxisCount ?? 3) == 2 &&
        coverType == CoverType.coverVertical) {
      aspectRatio = 335 / 520;
      width = Dimens.pt335;
      height = Dimens.pt430 + Dimens.pt8;
    }
    return Obx(() => GridView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(top: Dimens.pt25, bottom: Dimens.pt45),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount ?? 3, //横向数量
            crossAxisSpacing: Dimens.pt10,
            mainAxisSpacing: Dimens.pt10,
            childAspectRatio: aspectRatio),
        itemCount: mediaList.length,
        itemBuilder: (c, index) {
          return getMediaCoverItemWidget(mediaList[index], type,
              width: width, height: height, coverType: coverType);
        }));
  }
}

class ChangeMoreCoversBuilder extends StatelessWidget {
  final Function? onChangeTap;
  final Function? onMoreTap;
  final RxBool? isLoading;

  const ChangeMoreCoversBuilder(
      {super.key, this.onChangeTap, this.onMoreTap, this.isLoading});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return Stack(alignment: Alignment.center, children: [
      Container(
          width: screen.screenWidth,
          margin: EdgeInsets.only(bottom: Dimens.pt30),
          color: theme.getColor(ThemeColor.bgGrey),
          height: Dimens.pt72,
          child: Row(children: [
            GestureDetector(
                onTap: onChangeTap != null ? () => onChangeTap?.call() : null,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.pt120),
                    child: Text("换一换",
                        style: TextStyle(
                            fontSize: Dimens.pt30,
                            color: onChangeTap != null
                                ? theme.getColor(ThemeColor.textGrey)
                                : theme
                                    .getColor(ThemeColor.textGrey)
                                    .withOpacity(0.5))))),
            Container(
                width: Dimens.pt4,
                height: Dimens.pt30,
                color: theme.getColor(ThemeColor.textGrey)),
            GestureDetector(
                onTap: onMoreTap != null ? () => onMoreTap?.call() : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt120),
                  child: Text("查看更多",
                      style: TextStyle(
                          fontSize: Dimens.pt30,
                          color: onMoreTap != null
                              ? theme.getColor(ThemeColor.textGrey)
                              : theme
                                  .getColor(ThemeColor.textGrey)
                                  .withOpacity(0.5))),
                ))
          ])),
      Obx(() {
        return (isLoading?.value ?? false)
            ? Container(
                width: screen.screenWidth,
                height: Dimens.pt72,
                color: theme.getColor(ThemeColor.bg).withOpacity(.6),
                margin: EdgeInsets.only(bottom: Dimens.pt30),
                child: getLoadingWidget(
                    color: theme.getColor(ThemeColor.primary),
                    size: Dimens.pt20))
            : SizedBox();
      })
    ]);
  }
}

Widget topicHeaderBuilder(TopicList topic,
    {bool showMore = true, int type = 1, bool? showRank}) {
  return Row(children: [
    Text(topic.name ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: Dimens.pt32,
            fontWeight: FontWeight.w600,
            color: Colors.white)),
    Spacer(),
    if (showMore)
      GestureDetector(
          onTap: () => onTapMediaTopic(topic, MediaType.values[type],
              showRank: showRank),
          child: Row(children: [
            Text("主题简介",
                style:
                    TextStyle(fontSize: Dimens.pt26, color: Color(0xFFA3A3A7))),
            SizedBox(width: Dimens.pt5),
            Image.asset(R.assetsImgIconArrowRight,
                width: Dimens.pt40, color: Colors.white),
          ]))
  ]);
}

/// 漫画封面
class ComicItemCover extends StatelessWidget {
  final MediaInfo? model;
  final double? height;
  final double? width;
  final Function? onTap;
  final bool? showRank;
  final int? index;

  const ComicItemCover(
      {super.key,
      this.model,
      this.width,
      this.showRank,
      this.index,
      this.height,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    String type = (model?.isSerial ?? false) ? "连载中-更新" : "已完结-共";
    return GestureDetector(
        onTap: () => (onTap ?? () => itemOnTap(model!, MediaType.comic))(),
        child: SizedBox(
            width: width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(alignment: Alignment.topRight, children: [
                ImageLoader.withP(model?.coverImg,
                        width: width, height: height ?? Dimens.pt330)
                    .load(),
                Container(
                    margin: EdgeInsets.only(right: Dimens.pt30),
                    child: buildPayTypeWidget(
                        model?.comicsPayType ?? PaymentType.vipPaymentType,
                        price: model?.price,
                        isAds: model?.isAds ?? false)),
                if (showRank ?? false)
                  Positioned(
                      left: 0,
                      bottom: 0,
                      child: Transform.translate(
                        offset: Offset(0, Dimens.pt50),
                        child: Text("${index ?? 1}",
                            style: TextStyle(
                                fontSize: Dimens.pt140,
                                fontWeight: FontWeight.bold,
                                color: theme.getColor(ThemeColor.primary))),
                      ))
              ]),
              SizedBox(height: Dimens.pt10),
              Expanded(
                  child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(model?.title ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: Dimens.pt28,
                                    color: theme.getColor(
                                        (model?.isAds ?? false)
                                            ? ThemeColor.textYellow
                                            : ThemeColor.primary))),
                            SizedBox(height: Dimens.pt10),
                            if (!(model?.isAds ?? false))
                              Container(
                                  color: (model?.isSerial ?? false)
                                      ? theme
                                          .getColor(ThemeColor.red)
                                          .withOpacity(.2)
                                      : theme
                                          .getColor(ThemeColor.textYellow)
                                          .withOpacity(.2),
                                  padding: EdgeInsets.symmetric(
                                      vertical: Dimens.pt5,
                                      horizontal: Dimens.pt10),
                                  child: Text("$type${model?.newChapter ?? 0}话",
                                      style: TextStyle(
                                          fontSize: Dimens.pt22,
                                          color: (model?.isSerial ?? false)
                                              ? theme.getColor(ThemeColor.red)
                                              : theme.getColor(
                                                  ThemeColor.textYellow))))
                          ])))
            ])));
  }
}

Widget getMediaCoverItemWidget(MediaInfo media, MediaType type,
    {CoverType? coverType, double? height, double? width, Function? onTap}) {
  if (type == MediaType.comic) {
    return ComicItemCover(
        model: media, height: height, width: width, onTap: onTap);
  } else if (type == MediaType.novel) {
    return novelItemCover(media, height: height, width: width, onTap: onTap);
  } else {
    coverType ??= CoverType.coverHorizontal;
    return videoItemCover(media,
        height: height,
        width: width,
        coverType: coverType,
        type: type,
        onTap: onTap);
  }
}

Widget novelItemCover(MediaInfo model,
    {double? height, double? width, Function? onTap}) {
  ThemeManager theme = Get.find<ThemeManager>();
  // 如果是连载中，显示更新状态
  String type = (model.updateStatus == 1) ? "连载中" : "已完结";
  return GestureDetector(
      onTap: () => (onTap ?? () => itemOnTap(model, MediaType.novel))(),
      child: SizedBox(
          width: width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(alignment: Alignment.topRight, children: [
              ImageLoader.withP(model.coverImg,
                      width: width,
                      height: height ?? Dimens.pt330,
                      radius: Dimens.pt12)
                  .load(),
              Container(
                  margin: EdgeInsets.only(right: Dimens.pt15, top: Dimens.pt15),
                  child: buildPayTypeWidget(
                      model.novelPayType ?? PaymentType.freePaymentType,
                      price: model.price,
                      isAds: model.isAds ?? false))
            ]),
            SizedBox(height: Dimens.pt10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(model.title ?? "",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: Dimens.pt28,
                          color: (model.isAds ?? false)
                              ? AppColors.mainRed
                              : Colors.white)),
                  SizedBox(height: Dimens.pt10),
                  if (!(model.isAds ?? false))
                    Text("共${model.chapterCount ?? 0}章 · $type",
                        style: TextStyle(
                            fontSize: Dimens.pt24, color: Color(0xFFA3A3A7)))
                ]))
          ])));
}

Widget videoItemCover(MediaInfo model,
    {double? height,
    double? width,
    CoverType? coverType,
    MediaType? type,
    Function? onTap}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return GestureDetector(
      onTap: () =>
          (onTap ?? () => itemOnTap(model, type ?? MediaType.videoLong))(),
      child: SizedBox(
          width: width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(alignment: Alignment.topRight, children: [
              ImageLoader.withP(model.coverImg,
                      width: width, radius: Dimens.pt12, height: height)
                  .load(),
              if (!(model.isAds ?? false))
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                        height: Dimens.pt60,
                        width: width,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                              theme.getColor(ThemeColor.bg).withOpacity(.0),
                              theme.getColor(ThemeColor.bg).withOpacity(.8),
                            ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(R.assetsImgIconVideo,
                                  width: Dimens.pt31),

                              SizedBox(width: Dimens.pt5),
                              Text(getShowWatchNumberStr(model.watchTimes ?? 0),
                                  style: TextStyle(
                                      fontSize: Dimens.pt22,
                                      color: AppColors.textColorWhite)),
                              Spacer(),
                              // Text(TimeUtil.getHHNNSS(model.playTime ?? 0),
                              //     style: TextStyle(
                              //         fontSize: Dimens.pt22,
                              //         color: theme.getColor(ThemeColor.primary)))
                            ]))),
              Positioned(
                  right: Dimens.pt15,
                  top: Dimens.pt15,
                  child: buildPayTypeWidget(
                      model.payType ?? PaymentType.vipPaymentType,
                      price: model.price,
                      isAds: model.isAds ?? false))
            ]),
            SizedBox(height: Dimens.pt10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(model.title ?? "",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: Dimens.pt26,
                          color: (model.isAds ?? false)
                              ? AppColors.textYellowColor
                              : AppColors.textColorWhite))
                ]))
          ])));
}

// 换一换
Future<void> _changeMediaList(Rx<TopicList> observableTopic, int topicId,
    RxBool isLoading, MediaType type) async {
  try {
    isLoading.value = true;
    String apiPath = "";
    if (type == MediaType.novel) {
      apiPath = "novelTopic";
    } else if (type == MediaType.comic) {
      apiPath = "comicsTopic";
    } else {
      apiPath = "media/topic";
    }
    MediaList? model =
        await ApiRes.changeTopicList(id: topicId, apiPath: apiPath);
    observableTopic.update((val) {
      if (type != MediaType.comic && type != MediaType.novel) {
        val?.list = model?.mediaList ?? [];
      } else {
        val?.list = model?.list ?? [];
      }
    });
  } finally {
    isLoading.value = false;
  }
}

// 查看更多 查看专题详情
void onTapMediaTopic(TopicList topic, MediaType type, {bool? showRank}) {
  if (topic.id != null) {
    Get.toNamed(Routes.TOPIC_DETAIL_PAGE, arguments: {
      "topicId": topic.id ?? 0,
      "mediaType": type.index,
      "coverType": topic.coverType ?? CoverType.coverVertical.index,
      "title": topic.name,
      "showRank": showRank ?? false,
    });
  }
}

List<MediaInfo> getMediaListOfList(MediaList? list, MediaType type) {
  if (type == MediaType.comic) {
    return list?.comicsList ?? [];
  } else if (type == MediaType.novel) {
    return list?.novelList ?? [];
  } else if (type == MediaType.cartoon) {
    return list?.mediaList ?? [];
  } else if (type == MediaType.videoShort) {
    return list?.mediaList ?? [];
  } else if (type == MediaType.videoLong) {
    return list?.mediaList ?? [];
  } else {
    return list?.list ?? [];
  }
}

void shortVideoItemOnTap(
    {int? index,
    Function(int pageNum)? dataGetter,
    List<MediaInfo>? mediaList}) {
  Get.toNamed(Routes.SHORT_VIDEO_PLAYER, arguments: {
    "initIndex": index,
    "dataGetter": dataGetter,
    "mediaList": mediaList
  });
}

void itemOnTap(MediaInfo model, MediaType type) {
  if (type == MediaType.comic) {
    Get.toNamed(Routes.COMIC_DETAIL_PAGE,
        arguments: {"comicId": "${model.id ?? 0}", "title": model.title ?? ""});
  } else if (type == MediaType.cartoon) {
    Get.toNamed(Routes.VIDEO_PLAYER_PAGE,
        arguments: {"id": "${model.id}", "mediaType": MediaType.cartoon.index});
  } else if (type == MediaType.novel) {
    Get.toNamed(Routes.NOVEL_DETAIL_PAGE,
        arguments: {"novelId": "${model.id ?? 0}", "title": model.title ?? ""});
  } else if (type == MediaType.videoLong) {
    Get.toNamed(Routes.VIDEO_PLAYER_PAGE, arguments: {
      "id": "${model.id}",
      "mediaType": MediaType.videoLong.index
    });
  } else if (type == MediaType.videoShort) {
    Get.toNamed(Routes.SHORT_VIDEO_PLAYER, arguments: {"initIndex": 0});
  } else if (type == MediaType.darkWeb) {
    Get.toNamed(Routes.VIDEO_PLAYER_PAGE,
        arguments: {"id": "${model.id}", "mediaType": MediaType.darkWeb.index});
  }
}
