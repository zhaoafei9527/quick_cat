import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/views/page_pull_view.dart';
import 'package:acgn_client/app/widget/comic_topic_builder.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/common_util.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:acgn_client/utils/time_util.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../model/home/topic_list_model.dart';
import '../controllers/rank_list_page_controller.dart';

class RankListPageView extends GetView<RankListPageController> {
  const RankListPageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();

    return GetX<RankListPageController>(builder: (logic) {
      return Scaffold(
          appBar: getCommonAppBar("排行榜"),
          backgroundColor: theme.getColor(ThemeColor.bg),
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(R.assetsImgBgRankPage, width: screen.screenWidth),
            SizedBox(height: Dimens.pt25),
            buildCommonTabBar(
                controller: logic.tabController,
                insets: Dimens.pt38,
                isScrollable: false,
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
                alignment: TabAlignment.center,
                tabs: logic.cateList.map((e) => Text(e.value)).toList()),
            SizedBox(
                height: Dimens.pt66,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: Dimens.pt35),
                    itemBuilder: (context, index) => GestureDetector(
                            child: GestureDetector(
                          onTap: () => logic.sortIndex.value = index,
                          child: Center(
                              child: Obx(() => Text(logic.sortList[index],
                                  style: TextStyle(
                                    fontSize: Dimens.pt26,
                                    color: theme.getColor(
                                        logic.sortIndex.value == index
                                            ? ThemeColor.primary
                                            : ThemeColor.textGrey),
                                  )))),
                        )),
                    separatorBuilder: (context, index) =>
                        SizedBox(width: Dimens.pt50),
                    itemCount: logic.sortList.length)),
            SizedBox(height: Dimens.pt25),
            Expanded(
                child: TabBarView(
                    controller: logic.tabController,
                    children: logic.cateList
                        .map((e) => _buildPullRefreshView(type: e.key))
                        .toList()))
          ]));
    });
  }
}

Widget _buildPullRefreshView({MediaType type = MediaType.comic}) {
  RankListPageController logic = Get.find<RankListPageController>();
  return PagePullView(
      key: Key("rankListPullKey_${type.index}_${logic.sortIndex.value}"),
      dataGetter: (int pageNum, int size) async {
        MediaList? media = await ApiRes.getRankListNetData(
            pageNum: pageNum, type: type, sortType: logic.sortIndex.value);
        if (type == MediaType.comic) {
          return media?.comicsList ?? [];
        } else if (type == MediaType.novel) {
          return media?.novelList ?? [];
        } else if (type == MediaType.cartoon) {
          return media?.mediaList ?? [];
        } else if (type == MediaType.videoShort) {
          return media?.mediaList ?? [];
        } else if (type == MediaType.videoLong) {
          return media?.mediaList ?? [];
        } else {
          return media?.list ?? [];
        }
      },
      emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
      widgetBuilder: (BuildContext context, List<dynamic> list, Widget? child) {
        List<MediaInfo> mediaList = list.cast<MediaInfo>();
        return ListView.separated(
            itemBuilder: (context, index) =>
                _buildRankItem(type, mediaList[index], index),
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            separatorBuilder: (context, index) => SizedBox(height: Dimens.pt25),
            itemCount: mediaList.length);
      });
}

Widget getItemViewForType(MediaType type, MediaInfo model, index) {
  return _buildRankItem(type, model, index);
  // switch (type) {
  //   case MediaType.comic:
  //     return _buildRankItem(type, model, index);
  //   case MediaType.novel:
  //     return _buildComicNovelItem(type, model, index);
  //   case MediaType.videoShort:
  //     return _buildComicNovelItem(type, model, index);
  //   default:
  //     return Container();
  // }
}

Widget tagItem(String? name) {
  ThemeManager theme = Get.find<ThemeManager>();
  return Container(
      height: Dimens.pt42,
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt10),
      color: theme.getColor(ThemeColor.bgGrey),
      child: Text(name ?? "",
          style: TextStyle(
              fontSize: Dimens.pt24,
              color: theme.getColor(ThemeColor.primary))));
}

Widget _buildRankItem(MediaType type, MediaInfo model, int index) {
  ThemeManager theme = Get.find<ThemeManager>();
  bool isSerial = type == MediaType.novel
      ? model.updateStatus == 1
      : (model.isSerial ?? false);
  int? lastCount =
      type == MediaType.novel ? model.chapterCount : model.newChapter;
  String status = isSerial ? "连载中-更新" : "已完结-共";
  double height = Dimens.pt276;
  double coverWidth = Dimens.pt190;
  if (type == MediaType.videoLong) {
    height = Dimens.pt152;
    coverWidth = Dimens.pt270;
  }

  List<Tag>? tags = type == MediaType.novel ? model.novelTags : model.comicTags;
  List<TagList>? videoTags = model.tagList ?? [];
  PaymentType? paymentType = model.comicsPayType;
  String tip = "话";
  if (type == MediaType.novel) {
    tip = "章";
    paymentType = model.novelPayType;
  } else if (type == MediaType.comic) {
    paymentType = model.comicsPayType;
  } else {
    paymentType = model.payType;
  }

  return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => itemOnTap(model, type),
      child: SizedBox(
          height: height,
          child: Row(children: [
            Stack(alignment: Alignment.topRight, children: [
              ImageLoader.withP(model.coverImg ?? "",
                      width: coverWidth, height: height)
                  .load(),
              Container(
                  margin: EdgeInsets.only(right: Dimens.pt30),
                  child: buildPayTypeWidget(
                      paymentType ?? PaymentType.vipPaymentType,
                      price: model.price))
            ]),
            SizedBox(width: Dimens.pt25),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Text(model.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: Dimens.pt30))),
                    _r(index + 1)
                  ]),
                  SizedBox(height: Dimens.pt7),
                  if (type != MediaType.videoLong) ...[
                    Text(
                        (model.desc ?? "").isNotEmpty ? model.desc! : "暂无更多资讯～",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: Dimens.pt24,
                            color: theme.getColor(ThemeColor.textGrey))),
                    SizedBox(height: Dimens.pt10)
                  ],
                  Expanded(
                      child: SingleChildScrollView(
                          child: Wrap(
                              direction: Axis.horizontal,
                              spacing: Dimens.pt25,
                              runSpacing: Dimens.pt10,
                              alignment: WrapAlignment.start,
                              children: [
                        if (type == MediaType.comic || type == MediaType.novel)
                          ...List.generate((tags ?? []).length,
                              (index) => tagItem(tags?[index].name))
                        else
                          ...List.generate(videoTags.length,
                              (index) => tagItem(videoTags[index].name))
                      ]))),
                  SizedBox(height: Dimens.pt7),
                  Row(children: [
                    if (type == MediaType.comic || type == MediaType.novel)
                      Image.asset(R.assetsImgIconEye, width: Dimens.pt31)
                    else
                      Image.asset(R.assetsImgIconVideo,
                          width: Dimens.pt31,
                          color: theme.getColor(ThemeColor.textGrey)),
                    SizedBox(width: Dimens.pt10),
                    Text("${getShowWatchNumberStr(model.watchTimes ?? 0)}观看",
                        style: TextStyle(
                            fontSize: Dimens.pt22,
                            color: theme.getColor(ThemeColor.textGrey))),
                    Spacer(),
                    if (type == MediaType.comic || type == MediaType.novel)
                      Container(
                          color: (model.isSerial ?? false)
                              ? theme.getColor(ThemeColor.red).withOpacity(.2)
                              : theme
                                  .getColor(ThemeColor.textYellow)
                                  .withOpacity(.2),
                          padding: EdgeInsets.symmetric(
                              vertical: Dimens.pt5, horizontal: Dimens.pt10),
                          child: Text("$status$lastCount$tip",
                              style: TextStyle(
                                  fontSize: Dimens.pt22,
                                  color: isSerial
                                      ? theme.getColor(ThemeColor.red)
                                      : theme.getColor(ThemeColor.textYellow))))
                    else ...[
                      Icon(Icons.access_time_filled_sharp,
                          size: Dimens.pt32,
                          color: theme.getColor(ThemeColor.textGrey)),
                      SizedBox(width: Dimens.pt8),
                      Text(TimeUtil.getHHNNSS(model.playTime ?? 0),
                          style: TextStyle(
                              fontSize: Dimens.pt22,
                              color: theme.getColor(ThemeColor.textGrey)))
                    ]
                  ])
                ]))
          ])));
}

Widget _r(int value) {
  ThemeManager theme = Get.find<ThemeManager>();
  return Container(
      width: Dimens.pt76,
      decoration: BoxDecoration(
          border: Border.all(color: theme.getColor(ThemeColor.primary))),
      child: Center(
        child: Text("$value",
            style: TextStyle(
                fontSize: Dimens.pt30,
                fontWeight: FontWeight.w900,
                color: theme.getColor(ThemeColor.primary))),
      ));
}
