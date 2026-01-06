// 🐦 Flutter imports:
import 'dart:ui';

import 'package:quick_cat_client/app/data/address.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:quick_cat_client/app/widget/full_bg.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/keep_alive_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../data/ads_type.dart';
import '../../../../dialog/announce_dialog.dart';
import '../../../../views/round_under_line_tab_indicator.dart';
import '../../../../widget/cover_banner.dart';
import '../../home_post_page/views/post_recommend_view.dart';
import '../controllers/home_index_web_controller.dart';
import 'home_tab_pull_view.dart';

class HomeIndexWebView extends GetView<HomeIndexWebController> {
  const HomeIndexWebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<HomeIndexWebController>(
        builder: (HomeIndexWebController logic) {
      if (!logic.initOk.value) return getLoadingView();
      return GetX<ThemeManager>(
          builder: (ThemeManager theme) => PageBg(
              child: Container(
                  margin: EdgeInsets.only(top: screen.paddingTop + Dimens.pt20),
                  child: Column(children: [
                    _buildHomeHeader(logic, theme),
                    SizedBox(height: Dimens.pt28),
                    Expanded(
                        child: TabBarView(
                            controller: logic.tabController,
                            children: [
                          _buildCategoryContent(
                              tabController: logic.postCategoryTab,
                              categoryList: logic.postCategory,
                              type: MediaType.post),
                          _buildCategoryContent(
                              tabController: logic.videoCategoryTab,
                              categoryList: logic.videoCategory,
                              type: MediaType.videoLong),
                          _buildCategoryContent(
                              tabController: logic.shortCategoryTab,
                              categoryList: logic.shortCategory,
                              type: MediaType.videoShort),
                          _buildCategoryContent(
                              tabController: logic.cartoonCategoryTab,
                              categoryList: logic.cartoonCategory,
                              type: MediaType.cartoon),
                          _buildCategoryContent(
                              tabController: logic.novelCategoryTab,
                              categoryList: logic.novelCategory,
                              type: MediaType.novel),
                        ])),
                    SizedBox(height: screen.bottomNavBarH)
                  ])))

          // Scaffold(
          // key: logic.scaffoldKey,
          // backgroundColor: theme.getColor(ThemeColor.bg),
          // // endDrawer: _buildHomeIndexDrawer(logic, theme),
          // body: )
          );
    });
  }

  Widget _buildHomeHeader(HomeIndexWebController logic, ThemeManager theme) {
    int tab = logic.currentTabIndex.value;
    return Container(
        height: Dimens.pt60,
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: buildCommonTabBar(
            controller: logic.tabController,
            isScrollable: false,
            alignment: TabAlignment.center,
            tabs: logic.cateList.map((e) => Text(e)).toList()));
  }

  Widget _buildCategoryContent({
    required TabController tabController,
    required RxList<MediaCategory> categoryList,
    required MediaType type,
  }) {
    return CategoryContentView(
        tabController: tabController, categoryList: categoryList, type: type);
  }

  Widget _buildHomeIndexDrawer(
      HomeIndexWebController logic, ThemeManager theme) {
    return Stack(alignment: Alignment.topRight, children: [
      Container(
          width: Dimens.pt450,
          color: theme.getColor(ThemeColor.bg),
          padding: EdgeInsets.only(
              bottom: screen.bottomNavBarH,
              top: screen.paddingTop + Dimens.pt70),
          child: LoadingView(
              loading: logic.endDrawLoading.value,
              child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          Get.toNamed(Routes.TOPIC_DETAIL_PAGE, arguments: {
                        "topicId": "${logic.topicList[index].id}",
                        "title": logic.topicList[index].name,
                        "mediaType": logic.currentType.index
                      }),
                      child: Container(
                          height: Dimens.pt72,
                          color: theme.getColor(ThemeColor.bgGrey),
                          child: Center(
                              child: Text(logic.topicList[index].name ?? "",
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      color: theme
                                          .getColor(ThemeColor.textGrey))))),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(height: Dimens.pt25),
                  itemCount: logic.topicList.length))),
      Positioned(
          top: screen.paddingTop,
          right: Dimens.pt25,
          child: GestureDetector(
              onTap: () => logic.scaffoldKey.currentState?.closeEndDrawer(),
              child: Icon(Icons.close,
                  size: Dimens.pt50,
                  color: theme.getColor(ThemeColor.primary))))
    ]);
  }
}

class CategoryContentView extends StatefulWidget {
  final TabController tabController;
  final RxList<MediaCategory> categoryList;
  final MediaType type;

  const CategoryContentView({
    Key? key,
    required this.tabController,
    required this.categoryList,
    required this.type,
  }) : super(key: key);

  @override
  State<CategoryContentView> createState() => _CategoryContentViewState();
}

class _CategoryContentViewState extends State<CategoryContentView> {
  late int _currentIndex;
  late HomeIndexWebController logic;

  @override
  void initState() {
    super.initState();
    logic = Get.find<HomeIndexWebController>();
    logic.currentCategoryId = widget.categoryList[0].id ?? 0; // 更新当前分类ID
    _currentIndex = widget.tabController.index;
    widget.tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (_currentIndex != widget.tabController.index) {
      setState(() {
        _currentIndex = widget.tabController.index;
        logic.currentCategoryId =
            widget.categoryList[_currentIndex].id ?? 0; // 更新当前分类ID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager theme = Get.find<ThemeManager>();
    final ShareKeys shareKeys = Get.find<ShareKeys>();
    return Stack(children: [
      Column(children: [
        _buildCategoryTabBar(theme),
        SizedBox(height: Dimens.pt25),
        _buildSearchBar(),
        SizedBox(height: Dimens.pt25),
        Expanded(
            child: TabBarView(
                controller: widget.tabController,
                children: widget.categoryList
                    .asMap()
                    .map((index, value) {
                      return MapEntry(
                          index,
                          KeepAliveWrapper(
                              child: _buildCategoryPage(value, index)));
                    })
                    .values
                    .toList()))
      ])
    ]);
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        child: Row(children: [
          GestureDetector(
            onTap: ()=> Get.toNamed(Routes.SEARCH_PAGE),
            child: Container(
                width: Dimens.pt440,
                height: Dimens.pt60,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.3),
                    borderRadius: BorderRadius.circular(Dimens.pt60),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFF7F581C).withOpacity(.12),
                          blurRadius: Dimens.pt10,
                          offset: Offset(0, Dimens.pt4))
                    ]),
                child: Row(children: [
                  SizedBox(width: Dimens.pt20),
                  Image.asset(R.assetsImgIconSearch,
                      width: Dimens.pt22, height: Dimens.pt22),
                  SizedBox(width: Dimens.pt10),
                  Text("搜索你感兴趣的内容",
                      style: TextStyle(
                          fontSize: Dimens.pt24,
                          color: AppColors.textColorWhite.withOpacity(.7)))
                ])),
          ),
          Spacer(),
          GestureDetector(
              onTap: () => Get.toNamed(Routes.CATEGORY_DETAIL_PAGE),
              child: Row(children: [
                Image.asset(R.assetsImgIconHomeCate,
                    width: Dimens.pt36, height: Dimens.pt36),
                SizedBox(width: Dimens.pt8),
                Text("筛选",
                    style: TextStyle(
                        fontSize: Dimens.pt28, color: AppColors.textColorWhite))
              ])),
          Spacer(),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.MINE_COLLECT_PAGE);
            },
            child: Row(children: [
              Image.asset(R.assetsImgIconHomeCollect,
                  width: Dimens.pt36, height: Dimens.pt36),
              SizedBox(width: Dimens.pt8),
              Text("收藏",
                  style: TextStyle(
                      fontSize: Dimens.pt28, color: AppColors.textColorWhite))
            ]),
          )
        ]));
  }

  Widget _buildCategoryTabBar(ThemeManager theme) {
    return Container(
        height: Dimens.pt56,
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        child: ListView.separated(
            itemBuilder: (context, index) {
              return Obx(() => GestureDetector(
                    onTap: () => {widget.tabController.animateTo(index)},
                    child: Container(
                        height: Dimens.pt56,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: Dimens.pt20),
                        decoration: BoxDecoration(
                            color: widget.tabController.index == index
                                ? AppColors.primaryColor
                                : AppColors.textGreyColor,
                            borderRadius: BorderRadius.circular(Dimens.pt8)),
                        child: Text(widget.categoryList[index].name ?? "",
                            style: TextStyle(
                                fontSize: Dimens.pt28,
                                color: AppColors.textColorWhite))),
                  ));
            },
            separatorBuilder: (context, index) => SizedBox(width: Dimens.pt20),
            itemCount: widget.categoryList.length,
            scrollDirection: Axis.horizontal));
  }

  Widget _buildCategoryPage(MediaCategory category, int index) {
    if (widget.type == MediaType.post) {
      // 为每个 Tab 传入唯一 tag，避免 SmartRefresher 共享同一个 RefreshController

      return PostRecommendView(id: category.id ?? 0);
    }

    return HomeTabBarPullView<TopicList>(
        id: category.id ?? 0,
        type: widget.type.index,
        showType: category.showType,
        topicBuilder: (TopicList topic) {
          return buildMediaTopicWidget(topic, widget.type);
        },
        dataGetter: ({int pageNum = 1, int id = 0}) async {
          switch (widget.type) {
            case MediaType.post:
              return await ApiRes.getComicTopicList(
                  pageNum: pageNum, id: id, cateName: "comics");
            case MediaType.cartoon:
              return await ApiRes.getHomeTopicList(pageNum: pageNum, id: id);
            case MediaType.novel:
              return await ApiRes.getComicTopicList(
                  pageNum: pageNum, id: id, cateName: "novel");
            default:
              return await ApiRes.getHomeTopicList(pageNum: pageNum, id: id);
          }
        });
  }
}

Widget buildHeaderTab({
  required int index,
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
  required ThemeManager theme,
}) {
  return GestureDetector(
      onTap: onTap,
      child: Padding(
          padding: EdgeInsets.only(right: Dimens.pt30),
          child: Text(title,
              style: TextStyle(
                fontSize: isSelected ? Dimens.pt42 : Dimens.pt30,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.getColor(ThemeColor.primary)
                    : theme.getColor(ThemeColor.textGrey),
              ))));
}

Widget buildHeaderIcon({
  required VoidCallback onTap,
  required Widget child,
}) {
  return GestureDetector(
    onTap: onTap,
    child: child,
  );
}
