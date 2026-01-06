import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../conf/api_res.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/screen.dart';
import '../../../data/enum.dart';
import '../../../model/home/config_model_model.dart';
import '../../../model/home/topic_list_model.dart';
import '../../../themes/theme_manager.dart';
import '../../../widget/common_widget.dart';
import '../../home/home_index_web/views/home_index_web_view.dart';
import '../../home/home_index_web/views/home_tab_pull_view.dart';
import '../controllers/ai_recommend_page_controller.dart';

class AiRecommendPageView extends GetView<AiRecommendPageController> {
  const AiRecommendPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AiRecommendPageController>(
        builder: (AiRecommendPageController logic) {
          ThemeManager theme = Get.find<ThemeManager>();
          return Scaffold(
              backgroundColor: theme.getColor(ThemeColor.bg),
              body: Container(
                  margin: EdgeInsets.only(top: screen.paddingTop + Dimens.pt20),
                  child: Column(
                    children: [
                      _buildHomeHeader(logic, theme),
                      SizedBox(height: Dimens.pt32),
                      Expanded(
                          child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: logic.tabController,
                              children: [
                                _buildAiTabBarView(),
                                // AiChangeFacePage(),
                                // AiOffClothesPage(),
                                // AiGenerateGirlPage(),
                              ])),
                      SizedBox(height: screen.bottomNavBarH)
                    ],
                  )));
        });
  }


  Widget _buildAiTabBarView() {
    AiRecommendPageController logic = Get.find();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      buildCommonTabBar(
          controller: logic.aiTabController,
          insets: Dimens.pt38,
          isScrollable: false,
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
          alignment: TabAlignment.center,
          tabs: logic.aiTabList.map((e) => Text(e.name ?? "")).toList()),
      SizedBox(height: Dimens.pt32),
      Expanded(
          child: TabBarView(
              controller: logic.aiTabController,
              children: logic.aiTabList
                  .map((category) => _buildCategoryPage(category))
                  .toList()))
    ]);
  }

  Widget _buildCategoryPage(MediaCategory category) {
    return HomeTabBarPullView<TopicList>(
        id: category.id ?? 0,
        type: category.type ?? MediaType.comic.index,
        showType: category.showType,
        dataGetter: ({int pageNum = 1, int id = 0}) async {
          return await ApiRes.getAiRecommendData(
              pageNum: pageNum, type: category.type ?? MediaType.comic.index);
        });
  }

  Widget _buildHomeHeader(
      AiRecommendPageController logic, ThemeManager theme) {
    return Container(
        height: Dimens.pt60,
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: Row(children: [
          ...List.generate(
              logic.cateTopList.length,
                  (index) => buildHeaderTab(
                  index: index,
                  title: logic.cateTopList[index],
                  isSelected: logic.currentTabIndex.value == index,
                  onTap: () => logic.changeTabIndex(index),
                  theme: theme))
        ]));
  }
}
