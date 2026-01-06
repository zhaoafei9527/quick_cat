import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/app/widget/full_bg.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/book_store_page_controller.dart';

class BookStorePageView extends GetView<BookStorePageController> {
  const BookStorePageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<BookStorePageController>(builder: (logic) {
      double editHeight = Dimens.pt100 + screen.paddingBottom;
      return Scaffold(
          appBar: getCommonAppBar("书架", actions: [
            GestureDetector(
                onTap: () {
                  logic.editModel.value = !logic.editModel.value;
                  logic.selectIds.clear();
                },
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                    child: Text("编辑",
                        style: TextStyle(
                            fontSize: Dimens.pt28,
                            color: theme.getColor(ThemeColor.textYellow)))))
          ]),
          body: Stack(alignment: Alignment.bottomCenter, children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimens.pt30),
                      SizedBox(
                          child: buildCommonTabBar(
                              controller: logic.cateTabController,
                              insets: Dimens.pt38,
                              isScrollable: false,
                              alignment: TabAlignment.center,
                              tabs:
                                  logic.cateTab.map((e) => Text(e)).toList())),
                      SizedBox(height: Dimens.pt35),
                      SizedBox(
                          height: Dimens.pt40,
                          child: ListView.separated(
                              padding:
                                  EdgeInsets.symmetric(horizontal: Dimens.pt10),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (content, index) {
                                return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => logic.sortIndex.value = index,
                                    child: Obx(() => Text(logic.sortTab[index],
                                        style: TextStyle(
                                            color: theme.getColor(
                                                logic.sortIndex.value == index
                                                    ? ThemeColor.primary
                                                    : ThemeColor.textGrey),
                                            fontWeight: FontWeight.w600,
                                            fontSize: Dimens.pt26))));
                              },
                              separatorBuilder: (context, index) =>
                                  SizedBox(width: Dimens.pt30),
                              itemCount: logic.sortTab.length)),
                      SizedBox(height: Dimens.pt35),
                      Expanded(
                          child: TabBarView(
                              controller: logic.cateTabController,
                              children: [
                            buildPullRefreshView(type: MediaType.comic),
                            buildPullRefreshView(type: MediaType.novel)
                          ]))
                    ])),
            buildEditPageUtilView(logic.editModel.value,
                isAllSelect: logic.allSelect.value,
                haveSel: logic.selectIds.isNotEmpty,
                onToggleAll: logic.toggleAllSelect,
                onDelete: logic.delBookIfIds)
          ]));
    });
  }

  Widget buildPullRefreshView({MediaType type = MediaType.comic}) {
    ThemeManager theme = Get.find<ThemeManager>();
    BookStorePageController logic = Get.find<BookStorePageController>();
    String apiPath = type == MediaType.comic
        ? ApiRes.bookStoreComicPath
        : ApiRes.bookStoreNovelPath;
    return PagePullView(
        key: Key(
            "bookStorePullKey_${type.index}_${logic.sortIndex.value}_${logic.refreshTag.value}"),
        dataGetter: (int pageNum, int size) async {
          MediaList? media = await ApiRes.getBookStoreNetData(
              apiPath: apiPath,
              pageNum: pageNum,
              sort: SortMediaType.values[logic.sortIndex.value]);
          if (pageNum == 1) {
            logic.currentMedias[type] = media?.list ?? [];
          } else if (pageNum > 1) {
            logic.currentMedias[type]?.assignAll(media?.list ?? []);
          }

          return media?.list ?? [];
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          List<MediaInfo> mediaList = logic.currentMedias[type] ?? [];
          return GridView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, //横向数量
                  crossAxisSpacing: Dimens.pt10,
                  mainAxisSpacing: Dimens.pt10,
                  childAspectRatio: 226 / 435),
              itemCount: mediaList.length,
              itemBuilder: (c, index) {
                MediaInfo? model = mediaList[index];
                return Obx(
                  () => GestureDetector(
                    onTap: () {
                      if (logic.editModel.value) {
                        logic.toggleSelect(model.id ?? 0);
                      } else {
                        itemOnTap(mediaList[index], type);
                      }
                    },
                    child: Stack(children: [
                      getMediaCoverItemWidget(mediaList[index], type,
                          coverType: CoverType.coverVertical),
                      if (logic.editModel.value)
                        Container(
                            height: Dimens.pt330,
                            alignment: Alignment.center,
                            color:
                                theme.getColor(ThemeColor.bg).withOpacity(.7),
                            child: Image.asset(
                                logic.selectIds.contains(model.id ?? 0)
                                    ? R.assetsImgIconEditSelected
                                    : R.assetsImgIconEditSelect,
                                width: Dimens.pt50))
                    ]),
                  ),
                );
              });
        });
  }
}
