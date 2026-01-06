// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import '../../../views/page_pull_view.dart';
import '../controllers/tag_detail_page_controller.dart';

class TagDetailPageView extends GetView<TagDetailPageController> {
  const TagDetailPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<TagDetailPageController>(
        builder: (TagDetailPageController logic) {
      ThemeManager theme = Get.find<ThemeManager>();
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar:
              getCommonAppBar(logic.title.isNotEmpty ? logic.title : "标签详情"),
          body: Column(children: [
            if (logic.isAuthor)
              Expanded(child: _buildPagePullView(0))
            else ...[
              SizedBox(
                child: buildCommonTabBar(
                    controller: logic.sortTabController,
                    insets: Dimens.pt38,
                    isScrollable: true,
                    alignment: TabAlignment.center,
                    tabs: logic.tabList.map((e) => Text(e)).toList()),
              ),
              SizedBox(height: Dimens.pt25),
              Expanded(
                  child: TabBarView(
                      controller: logic.sortTabController,
                      children: [
                    ...List.generate(logic.tabList.length, (index) {
                      return _buildPagePullView(index);
                    })
                  ]))
            ]
          ]));
    });
  }

  // 视频下拉列表组建 包含漫画、动漫、视频、darkWeb。
  Widget _buildPagePullView(sortIndex) {
    TagDetailPageController logic = Get.find<TagDetailPageController>();
    return PagePullView<MediaInfo>(
        key: Key("pullKey_tag_$sortIndex"),
        dataGetter: (int pageNum, int size) async =>
            await logic.dataGetter(pageNum, sortIndex),
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: buildCommonMediaGrid(list.cast<MediaInfo>(),
                  mediaType: logic.mediaType, onTap: (index) {
                // 在上一个页面是播放器页面点击跳转时，应该返回播放器重建播放
                if (logic.mediaType == MediaType.videoShort &&
                    logic.backResultMark) {
                  Get.back(result: {"mediaList": list, "index": index});
                } else if (logic.mediaType == MediaType.videoLong &&
                    logic.backResultMark) {
                  Get.back(result: list[index]);
                } else if (logic.mediaType == MediaType.videoShort &&
                    !logic.backResultMark) {
                  shortVideoItemOnTap(
                      index: index,
                      mediaList: list.cast<MediaInfo>(),
                      dataGetter: (pageNum) async =>
                          await logic.dataGetter(pageNum, sortIndex));
                } else {
                  itemOnTap(list[index], logic.mediaType);
                }
              }));
        });
  }
}
