// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../../../utils/dimens.dart';
import '../../../model/home/topic_list_model.dart';
import '../../../views/page_pull_view.dart';
import '../../../widget/common_app_bar.dart';
import '../../../widget/common_widget.dart';
import '../controllers/topic_detail_page_controller.dart';

class TopicDetailPageView extends GetView<TopicDetailPageController> {
  const TopicDetailPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<TopicDetailPageController>(
        builder: (TopicDetailPageController logic) {
      ThemeManager theme = Get.find<ThemeManager>();
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar:
              getCommonAppBar(logic.title.isNotEmpty ? logic.title : "专题详情"),
          body: Column(children: [
            SizedBox(
              child: buildCommonTabBar(
                  controller: logic.sortTabController,
                  insets: Dimens.pt35,
                  insetsWidth: Dimens.pt8,
                  fontSize: Dimens.pt28,
                  isScrollable: true,
                  unselectedLabelColor: AppColors.textGrey,
                  alignment: TabAlignment.center,
                  tabs: logic.tabList.map((e) => Text(e)).toList()),
            ),
            SizedBox(height: Dimens.pt25),
            Expanded(
                child:
                    TabBarView(controller: logic.sortTabController, children: [
              ...List.generate(logic.tabList.length, (index) {
                return buildPagePullView(index);
              })
            ]))
          ]));
    });
  }

  // 视频下拉列表组建 包含漫画、动漫、视频、darkWeb。
  Widget buildPagePullView(sortIndex) {
    TopicDetailPageController logic = Get.find<TopicDetailPageController>();
    return PagePullView<MediaInfo>(
        key: Key("pullKey_$sortIndex"),
        dataGetter: (int pageNum, int size) async {
          List<MediaInfo> media = await logic.dataGetterFunction(
              pageNum: pageNum, sortType: sortIndex);
          return media;
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: buildCommonMediaGrid(list.cast<MediaInfo>(),
                  mediaType: logic.mediaType));
        });
  }
}
