import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/model/comic_info_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String label = "话";

Future showComicChapterDialog(
    {required BuildContext context,
    required List<Chapter?> chapterList,
    String coverImg = "",
    int? readChapterId,
    int? readNum,
    bool? isBuy,
    MediaType type = MediaType.comic,
    PaymentType comicsPayType = PaymentType.freePaymentType,
    int? price,
    Function(Chapter?)? onTap,
    bool isSeries = false}) async {
  ThemeManager theme = Get.find<ThemeManager>();
  bool sortAsc = true; // 正序
  bool isList = true; // 列表模式
  String comicTypeStr = isSeries ? "连载中" : "已完结";
  if (type == MediaType.novel) label = "章";

  return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
          builder: (c1, setState) => Container(
              width: screen.screenWidth,
              height: Dimens.pt800,
              padding: EdgeInsets.symmetric(
                  horizontal: Dimens.pt25, vertical: Dimens.pt27),
              color: theme.getColor(ThemeColor.bg),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text("全部章节",
                          style: TextStyle(
                              fontSize: Dimens.pt26,
                              color: theme.getColor(ThemeColor.primary))),
                      const Spacer(),
                      GestureDetector(
                          onTap: () => setState(() {
                                sortAsc = !sortAsc;
                                chapterList.sort((a, b) {
                                  if (sortAsc) {
                                    return a!.chapterNum!
                                        .compareTo(b!.chapterNum!);
                                  } else {
                                    return b!.chapterNum!
                                        .compareTo(a!.chapterNum!);
                                  }
                                });
                              }),
                          child: Row(children: [
                            Image.asset(
                                sortAsc
                                    ? R.assetsImgIconShortBottom
                                    : R.assetsImgIconShortTop,
                                width: Dimens.pt40),
                            SizedBox(width: Dimens.pt6),
                            Text(sortAsc ? "正序" : "倒序",
                                style: TextStyle(
                                    fontSize: Dimens.pt24,
                                    color: theme.getColor(ThemeColor.primary))),
                          ])),
                      SizedBox(width: Dimens.pt30),
                      GestureDetector(
                          onTap: () => setState(() {
                                isList = !isList;
                              }),
                          child: Row(children: [
                            Image.asset(
                                isList
                                    ? R.assetsImgIconShortTypeList
                                    : R.assetsImgIconShortTypeMini,
                                width: Dimens.pt40),
                            SizedBox(width: Dimens.pt6),
                            Text(isList ? "列表模式" : "缩略模式",
                                style: TextStyle(
                                    fontSize: Dimens.pt24,
                                    color: theme.getColor(ThemeColor.primary)))
                          ]))
                    ]),
                    Text("$comicTypeStr | 共${chapterList.length}$label | 不定时更新",
                        style: TextStyle(
                            fontSize: Dimens.pt20,
                            color: theme.getColor(ThemeColor.textGrey))),
                    SizedBox(height: Dimens.pt20),
                    Expanded(
                        child: isList
                            ? buildListChapterWidget(
                                chapterList, coverImg, comicsPayType,
                                readChapterId: readChapterId,
                                readNum: readNum,
                                type: type,
                                isBuy: isBuy,
                                price: price, onTap: (chapter) {
                                onTap?.call(chapter);
                                // Get.back(result: chapter);
                              })
                            : buildMiniChapterWidget(
                                chapterList, coverImg, comicsPayType,
                                onTap: (chapter) {
                                onTap?.call(chapter);
                                Get.back(result: chapter);
                              })),
                  ]))));
}

Widget buildListChapterWidget(
    List<Chapter?> chapterList, String coverImg, PaymentType comicsPayType,
    {required Function(Chapter?) onTap,
    MediaType type = MediaType.comic,
    int? readChapterId,
    int? readNum,
    bool? isBuy,
    price}) {
  ThemeManager theme = Get.find<ThemeManager>();
  int current = chapterList.indexWhere((e) => e?.id == readChapterId);
  return ListView.separated(
      itemBuilder: (context, index) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap.call(chapterList[index]),
          child: Stack(alignment: Alignment.topRight, children: [
            Container(
                width: screen.screenWidth,
                height: Dimens.pt90,
                padding: EdgeInsets.all(Dimens.pt10),
                color: theme.getColor(ThemeColor.bgGrey),
                child: Row(children: [
                  ImageLoader.withP(coverImg,
                          width: Dimens.pt125, height: Dimens.pt70)
                      .load(),
                  SizedBox(width: Dimens.pt15),
                  Expanded(
                      child: Text(
                          "第${chapterList[index]?.chapterNum}$label ${chapterList[index]?.title}",
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: Dimens.pt24,
                              overflow: TextOverflow.ellipsis,
                              color: theme.getColor(ThemeColor.primary)))),
                  SizedBox(width: Dimens.pt30),
                  if (readChapterId == chapterList[index]?.id)
                    Text(
                        type == MediaType.novel
                            ? "${current + 1}/${chapterList.length}"
                            : "${readNum ?? 0}/${chapterList[index]?.pageNum}",
                        style: TextStyle(
                            fontSize: Dimens.pt24,
                            color: theme.getColor(ThemeColor.textGrey))),
                  SizedBox(width: Dimens.pt110)
                ])),
            Container(
                margin: EdgeInsets.only(right: Dimens.pt25),
                child: buildPayTypeWidget(
                    (chapterList[index]?.isFree ?? false)
                        ? PaymentType.freePaymentType
                        : price > 0
                            ? PaymentType.coinPaymentType
                            : PaymentType.vipPaymentType,
                    isChapter: true,
                    isBuy: isBuy,
                    price: price))
          ])),
      separatorBuilder: (context, index) => SizedBox(height: Dimens.pt30),
      itemCount: chapterList.length);
}

Widget buildMiniChapterWidget(
    List<Chapter?> chapterList, coverImg, PaymentType? comicsPayType,
    {required Function(Chapter?) onTap}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return GridView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: Dimens.pt5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, //横向数量
          crossAxisSpacing: Dimens.pt15,
          mainAxisSpacing: Dimens.pt25,
          childAspectRatio: 128 / 76),
      itemCount: chapterList.length,
      itemBuilder: (c, index) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(chapterList[index]),
          child: Stack(alignment: Alignment.topRight, children: [
            Container(
                width: Dimens.pt128,
                height: Dimens.pt76,
                alignment: Alignment.center,
                color: theme.getColor(ThemeColor.textBlack),
                child: Text("第${chapterList[index]?.chapterNum}$label ",
                    style: TextStyle(
                        fontSize: Dimens.pt24,
                        color: theme.getColor(ThemeColor.primary)))),
            Container(
                width: Dimens.pt16,
                height: Dimens.pt16,
                margin: EdgeInsets.only(right: Dimens.pt15),
                color: Get.find<ThemeManager>()
                    .getColor((chapterList[index]?.isFree ?? false)
                        ? ThemeColor.spring
                        : comicsPayType == PaymentType.coinPaymentType
                            ? ThemeColor.red
                            : ThemeColor.textYellow))
          ]),
        );
      });
}
