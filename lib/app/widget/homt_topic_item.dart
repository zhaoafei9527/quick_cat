// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/widget/application_iterm.dart';
import 'package:quick_cat_client/app/widget/recommend_iterm.dart';
import 'package:quick_cat_client/app/widget/search_video_cover.dart';
import 'package:quick_cat_client/app/widget/short_video_cover.dart';
import '../../utils/dimens.dart';
import '../data/enum.dart';
import 'long_video_cover.dart';

Widget getTopicWidget(TopicList topic,
    {ValueChanged<int>? itemOnTap, bool showMore = true}) {
  return Column(children: [
    SizedBox(height: Dimens.pt20),
    buildTopicItemHeader(topic.id, topic.name ?? ""),
    SizedBox(height: Dimens.pt10),
    if ((topic.list ?? []).isNotEmpty ||
        (topic.appList ?? []).isNotEmpty)
      buildTopicItem(topic)
  ]);
}

Widget buildTopicItem(TopicList topic, {ValueChanged<int>? itemOnTap}) {
  Widget child = Container();
  // if (topic.showType == TopicShowType.FourGrid) {
  //   child = buildFourGridWidget(topic.mediaList ?? []);
  // } else if (topic.showType == TopicShowType.SixGrid) {
  //   child = buildSixGridWidget(topic.mediaList ?? []);
  // } else if (topic.showType == TopicShowType.LongListView) {
  //   child = buildLongListViewWidget(topic.mediaList ?? []);
  // } else if (topic.showType == TopicShowType.LongColumnListView) {
  // } else if (topic.showType == TopicShowType.ActivityListView) {
  //   child = buildApplicationListViewWidget(topic.appList ?? []);
  // } else if (topic.showType == TopicShowType.RecommendListView) {
  //   child = buildRecommendListViewWidget(topic.mediaList ?? []);
  // } else {
  //   child = Container();
  // }
  return child;
}


//四宫格
Widget buildFourGridWidget(List<MediaInfo> mediaList,
    {double? width, int? rowNumber}) {
  var childAspectRatio = 154 / 140;
  return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rowNumber ?? 2, //横向数量
          crossAxisSpacing: Dimens.pt10,
          mainAxisSpacing: Dimens.pt8,
          childAspectRatio: childAspectRatio),
      itemCount: mediaList.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        MediaInfo model = mediaList[index];
        return LongVideoCover(model);
      });
}

//六宫格
Widget buildSixGridWidget(List<MediaInfo> mediaList,
    {double? width, int? rowNumber}) {
  var childAspectRatio = 100 / 207;
  return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rowNumber ?? 3, //横向数量
          crossAxisSpacing: Dimens.pt10,
          mainAxisSpacing: Dimens.pt8,
          childAspectRatio: childAspectRatio),
      itemCount: mediaList.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        MediaInfo model = mediaList[index];
        return ShortVideoCover(model, width: width);
      });
}

//长视频横排
Widget buildLongListViewWidget(List<MediaInfo> mediaList,
    {double? width, double? height, int? rowNumber}) {
  return SizedBox(
    height: Dimens.pt210,
    child: ListView.separated(
        // padding: EdgeInsets.symmetric(vertical: Dimens.pt10),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          MediaInfo model = mediaList[index];
          return ShortVideoCover(model,
              width: width ?? Dimens.pt120, isPlayer: true);
        },
        separatorBuilder: (c, i) {
          return SizedBox(width: Dimens.pt12);
        },
        itemCount: mediaList.length),
  );
}

//其他游戏
Widget buildApplicationListViewWidget(List<AppTopicInfo> mediaList,
    {double? width, double? height, int? rowNumber}) {
  return SizedBox(
    height: Dimens.pt127,
    child: ListView.separated(
        // padding: EdgeInsets.symmetric(vertical: Dimens.pt10),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          AppTopicInfo model = mediaList[index];
          return ApplicationIterm(model);
        },
        separatorBuilder: (c, i) {
          return SizedBox(width: Dimens.pt15);
        },
        itemCount: mediaList.length),
  );
}

//推荐视频样式
Widget buildRecommendListViewWidget(List<MediaInfo> mediaList,
    {double? width, double? height, int? rowNumber}) {
  return SizedBox(
      height: Dimens.pt288,
      // margin: EdgeInsets.only(bottom: Dimens.pt8),
      child: GridView.builder(
          itemCount: mediaList.length,
          shrinkWrap: true,
          // padding: EdgeInsets.symmetric(horizontal: Dimens.pt12),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, //横向数量
              crossAxisSpacing: Dimens.pt10,
              mainAxisSpacing: Dimens.pt12,
              childAspectRatio: 88 / 165),
          itemBuilder: (BuildContext context, int index) {
            MediaInfo model = mediaList[index];
            return RecommendIterm(model,
                index: index + 1, maxWidth: Dimens.pt165);
          }));
}

//五宫格
// Widget buildFiveGridWidget(List<MediaInfo> mediaList, {isShortVideo = false}) {
//   MediaInfo? firstMedia = mediaList.first;
//   List<MediaInfo>? otherMedia = mediaList.sublist(1);
//
//   return Column(
//       children: [LongVideoCover(firstMedia), buildFourGridWidget(otherMedia)]);
// }

//专题头部
Widget buildTopicItemHeader(int? id, String? title, {bool showMore = true}) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(title ?? "",
        style: TextStyle(
            fontSize: Dimens.pt20,
            color: Colors.white,
            fontWeight: FontWeight.w900))
  ]);
}
