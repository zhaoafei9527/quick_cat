import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/views/page_pull_view.dart';
import 'package:acgn_client/app/widget/comic_topic_builder.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/category_detail_page_controller.dart';

class CategoryDetailPageView extends GetView<CategoryDetailPageController> {
  const CategoryDetailPageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<CategoryDetailPageController>(builder: (logic) {
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("筛选"),
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Dimens.pt25),
                    Expanded(child: buildCategoryView())
                  ])));
    });
  }

  // 视频下拉列表组建 包含漫画、动漫、视频、darkWeb。
  Widget buildPagePullView() {
    CategoryDetailPageController logic =
        Get.find<CategoryDetailPageController>();
    return Obx(() {
      // 使用所有筛选条件作为 key 的一部分，当任何条件变化时都会触发重建
      String tagKey = logic.tagTypeChooseId[logic.typeSort[logic.typeIndex.value].index]?.id
              .toString() ??
          "";
      String filterKey = "${logic.comicTypeIndex.value}_"
          "${logic.updateStatusIndex.value}_"
          "${logic.payStatusIndex.value}_"
          "${logic.sortIndex.value}";

      return PagePullView<MediaInfo>(
          key: Key("pullKey_${logic.typeIndex.value}_${tagKey}_$filterKey"),
          dataGetter: (int pageNum, int size) async {
            List<MediaInfo> media = await logic.dataGetterFunction(
                logic.typeSort[logic.typeIndex.value],
                pageNum: pageNum);
            return media;
          },
          emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
          widgetBuilder:
              (BuildContext context, List<dynamic> list, Widget? child) {
            return Padding(
                padding: EdgeInsets.zero,
                child: buildCommonMediaGrid(list.cast<MediaInfo>(),
                    mediaType: logic.typeSort[logic.typeIndex.value],
                    dataGetter: (int pageNum) async {
                  List<MediaInfo> media = await logic.dataGetterFunction(
                      logic.typeSort[logic.typeIndex.value],
                      pageNum: pageNum);
                  return media;
                }));
          });
    });
  }

  Widget buildCategoryView() {
    return NestedScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(child: categoryFilterView()),
            ],
        body: Column(children: [
          SizedBox(height: Dimens.pt20),
          Expanded(child: buildPagePullView()),
        ]));
  }

  Widget categoryFilterView() {
    CategoryDetailPageController logic = Get.find();

    return Obx(() {
      MediaType type = logic.typeSort[logic.typeIndex.value];

      List<Tag> tagList = logic.showTagMapList[type.index] ?? [];

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildCategoryTagsView(
            tags: logic.sortList,
            onTap: (index) => logic.sortIndex.value = index,
            activeIndex: logic.sortIndex.value),
        SizedBox(height: Dimens.pt25),
        buildCategoryTagsView(
            tags: tagList.map((e) => e.name ?? "").toList(),
            onTap: (index) => logic.onTagTypeChange(type.index, tagList[index]),
            activeIndex: tagList.indexWhere((tag) =>
                tag.id == (logic.tagTypeChooseId[type.index]?.id ?? 0))),
        if (type == MediaType.novel) ...[
          SizedBox(height: Dimens.pt25),
          buildCategoryTagsView(
              tags: logic.updateStatus,
              onTap: (index) => logic.updateStatusIndex.value = index,
              activeIndex: logic.updateStatusIndex.value),
        ],
        SizedBox(height: Dimens.pt25),
        buildCategoryTagsView(
            tags: logic.payStatus,
            onTap: (index) => logic.payStatusIndex.value = index,
            activeIndex: logic.payStatusIndex.value),
        SizedBox(height: Dimens.pt25),
        buildCategoryTagsView(
            tags: logic.tabList,
            onTap: (index) => logic.typeIndex.value = index,
            activeIndex: logic.typeIndex.value)
      ]);
    });
  }

  Widget buildCategoryTagsView(
      {List<String>? tags = const [],
      int? activeIndex,
      String? fixString,
      Function(int)? onTap}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return SizedBox(
        height: Dimens.pt48,
        width: screen.screenWidth,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
                onTap: () => onTap?.call(index),
                child: buildTagWrap(
                    selected: (activeIndex == index),
                    child: Text("${tags?[index]}${fixString ?? ''}",
                        style: TextStyle(
                            fontSize: Dimens.pt24, color: Colors.white)))),
            separatorBuilder: (content, index) => SizedBox(width: Dimens.pt25),
            itemCount: tags?.length ?? 0));
  }

  Wrap buildTagsView(List<Tag> tagList, List<Tag> tagCount, int type,
      {bool open = false}) {
    ThemeManager theme = Get.find<ThemeManager>();
    CategoryDetailPageController logic =
        Get.find<CategoryDetailPageController>();
    return Wrap(
        spacing: Dimens.pt10,
        alignment: WrapAlignment.start,
        children: [
          ...tagList.map((tag) => Obx(() {
                return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => logic.onTagTypeChange(type, tag),
                    child: buildTagItem(tag,
                        isSelected:
                            tag.id == (logic.tagTypeChooseId[type]?.id ?? 0)));
              })),
        ]);
  }

  Widget buildTagItem(Tag tag, {bool isSelected = false}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return buildTagWrap(
        child: Text(tag.name ?? "",
            maxLines: 1,
            style: TextStyle(
                fontSize: Dimens.pt26,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.getColor(ThemeColor.primary)
                    : theme.getColor(ThemeColor.textGrey))));
  }
}

Widget buildTagWrap({Widget? child, double? width, bool? selected}) {
  return Container(
      height: Dimens.pt48,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt14),
      decoration: BoxDecoration(
          color: (selected ?? false) ? AppColors.mainRed : null,
          borderRadius: BorderRadius.circular(Dimens.pt6)),
      child: child);
}
