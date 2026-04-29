// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/dialog/game_notify_dialog.dart';
import 'package:quick_cat_client/app/model/game_model.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/modules/home/home_post_page/views/post_recommend_view.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/app/widget/full_bg.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:path/path.dart';

// 🌎 Project imports:
import '../../../../../r.dart';
import '../../../../../utils/dimens.dart';
import '../../../../data/ads_type.dart';
import '../../../../data/share_key.dart';
import '../../../../model/home/user_info_model.dart';
import '../../../../themes/app_colors.dart';
import '../../../../widget/cover_banner.dart';
import '../../home_index_web/views/home_index_web_view.dart';
import '../../home_index_web/views/home_tab_pull_view.dart';
import '../controllers/home_game_page_controller.dart';

class HomeGamePageView extends GetView<HomeGamePageController> {
  const HomeGamePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<HomeGamePageController>(
        builder: (HomeGamePageController logic) {
      ThemeManager theme = Get.find<ThemeManager>();
      return PageBg(bgColor: Color(0xFF0B0C13), child: _buildGamePageView());
    });
  }

  Widget _buildSeGamePageView() {
    return PagePullView<HGameInfo>(
        dataGetter: (int pageNum, int size) async {
          HGameResult? result = await ApiRes.getSeGameList(pageNum: pageNum);
          return result?.list ?? [];
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              itemBuilder: (c, index) {
                HGameInfo gameInfo = list[index] as HGameInfo;
                return GestureDetector(
                    onTap: () {
                      AppPages.jumpRouter(path: gameInfo.url ?? "");
                      ApiRes.clickSeGame(id: gameInfo.id ?? 0);
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CoverBanner(
                              //广告homeSwiperAds
                              aspectRatio: 750 / 198,
                              list: gameInfo.imgs,
                              onItemClick: (Advertise model) {
                                // AppPages.jumpRouter(path: model.href, id: model.id);
                              }),
                          Container(
                              width: Dimens.pt700,
                              color: AppColors.textBlackColor,
                              padding: EdgeInsets.all(Dimens.pt25),
                              child: Row(children: [
                                ImageLoader.withP(gameInfo.gameAvatar ?? "",
                                        width: Dimens.pt92, height: Dimens.pt92)
                                    .load(),
                                SizedBox(width: Dimens.pt25),
                                Expanded(
                                    child: Column(children: [
                                  Row(children: [
                                    Text(gameInfo.name ?? "",
                                        style: TextStyle(
                                            fontSize: Dimens.pt32,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textColorWhite)),
                                    SizedBox(width: Dimens.pt25),
                                    Expanded(
                                        child: Row(children: [
                                      ...List.generate(
                                          gameInfo.tags?.length ?? 0, (index) {
                                        return Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimens.pt10,
                                                vertical: Dimens.pt4),
                                            margin: EdgeInsets.only(
                                                right: Dimens.pt15),
                                            color: AppColors.textYellowColor,
                                            child: Text(
                                                gameInfo.tags?[index].tagName ??
                                                    "",
                                                style: TextStyle(
                                                    fontSize: Dimens.pt24,
                                                    color: AppColors.bgColor)));
                                      })
                                    ]))
                                  ]),
                                  SizedBox(height: Dimens.pt15),
                                  Text(gameInfo.desc ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: AppColors.textGrey))
                                ]))
                              ]))
                        ]));
              },
              separatorBuilder: (c, index) => SizedBox(height: Dimens.pt25),
              itemCount: list.length);
        });
  }

  Widget _buildGamePageView() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        child: CustomScrollView(slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: Dimens.pt25 + screen.paddingTop),
            buildRunningLightView(),
            SizedBox(height: Dimens.pt25),
            Stack(alignment: Alignment.centerLeft, children: [
              CoverBanner(
                  //广告homeSwiperAds
                  aspectRatio: 750 / 198,
                  adsType: AdsType.homeSwiperAds,
                  onItemClick: (Advertise model) {
                    AppPages.jumpRouter(path: model.href, id: model.id);
                  }),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildSmallUtilButton(
                  btnTxt: "福利活动",
                  onTap: () => Get.toNamed(Routes.ACTIVITY_CENTER_PAGE),
                ),
                SizedBox(height: Dimens.pt10),
                _buildSmallUtilButton(
                    btnTxt: "游戏账单",
                    onTap: () => Get.toNamed(Routes.BILL_RECORD_PAGE_VIEW,
                        arguments: {"type": 0})),
                SizedBox(height: Dimens.pt10),
                _buildSmallUtilButton(
                    btnTxt: "专属客服",
                    // onTap: ()=>showGameNotifyDialog(Get.context!),
                    onTap: () => AppUtils.goToCustomServicePage())
              ])
            ]),
            SizedBox(height: Dimens.pt10)
          ])),
          SliverPersistentHeader(
              pinned: true,
              delegate: _GameUtilsHeaderDelegate(
                  child: buildRecommendGameView(showHotGame: false))),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: Dimens.pt25),
            getHengLine(color: Color(0xFF666666)),
            SizedBox(height: Dimens.pt20),
            buildGamePlatformList(),
            // buildHistoryGameView(),
            SizedBox(height: Dimens.pt25),
            _buildGameTypesView(),
            SizedBox(height: Dimens.pt25),
            _buildGamePageListView(),
            SizedBox(height: screen.bottomNavBarH + Dimens.pt25)
          ]))
        ]));
  }

  Widget buildGamePlatformList() {
    HomeGamePageController logic = Get.find<HomeGamePageController>();
    return SizedBox(
        height: Dimens.pt85,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (c, index) => GestureDetector(
                onTap: () => logic.changeGamePlatform(index),
                child: Obx(
                  () => Container(
                      width: Dimens.pt148,
                      decoration: BoxDecoration(
                          color: logic.gamePlatformIndex.value == index
                              ? Color(0xFFFFB715)
                              : Color(0xFF858589),
                          borderRadius: BorderRadius.circular(Dimens.pt12)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageLoader.withP(
                                    logic.gamePlatformList[index].icon ?? "",
                                    height: Dimens.pt35)
                                .load(),
                            SizedBox(height: Dimens.pt2),
                            Text(logic.gamePlatformList[index].title ?? "",
                                style: TextStyle(
                                    fontSize: Dimens.pt22, color: Colors.white))
                          ])),
                )),
            separatorBuilder: (c, index) => SizedBox(width: Dimens.pt20),
            itemCount: logic.gamePlatformList.length));
  }

  Widget buildHistoryGameView() {
    int type = GameCategory.gameCategoryHT.index;

    return Obx(() {
      HomeGamePageController logic = Get.find<HomeGamePageController>();
      List<GameInfoBean> historyGameList = logic.gameTypeList[type] ?? [];
      if (historyGameList.isEmpty) {
        return SizedBox();
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Text("最近玩过",
        //     style: TextStyle(
        //         fontSize: Dimens.pt34,
        //         fontWeight: FontWeight.w600,
        //         color: AppColors.textColorWhite)),
        // SizedBox(height: Dimens.pt25),
        // SizedBox(
        //     height: Dimens.pt245,
        //     child: ListView.separated(
        //         scrollDirection: Axis.horizontal,
        //         itemBuilder: (context, index) {
        //           GameInfoBean? bean = logic.gameTypeList[type]?[index];
        //           return ImageLoader.withP(bean?.coverImg ?? "",
        //                   radius: Dimens.pt8,
        //                   width: Dimens.pt214,
        //                   height: Dimens.pt245)
        //               .load();
        //         },
        //         separatorBuilder: (context, index) =>
        //             SizedBox(width: Dimens.pt25),
        //         itemCount: historyGameList.length)),
        SizedBox(height: Dimens.pt50),
        getHengLine(color: Color(0xFF666666)),
        SizedBox(height: Dimens.pt50)
      ]);
    });
  }

  _buildSmallUtilButton({onTap, btnTxt}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: Dimens.pt150,
            height: Dimens.pt60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(.6),
                border: Border.all(color: Color(0xFFFFE0B5), width: 1)),
            child: Text(btnTxt ?? "",
                style: TextStyle(
                    fontSize: Dimens.pt26, color: AppColors.textColorWhite))));
  }

  Widget _buildGamePageListView() {
    HomeGamePageController logic = Get.find<HomeGamePageController>();
    return Obx(
      () => SizedBox(
          height: logic.gameViewHeight.value + screen.bottomNavBarH,
          child: logic.gameAreaLoading.value
              ? Center(child: getLoadingWidget())
              : logic.categoryList.isEmpty
                  ? buildCommonEmptyView("找不到游戏～")
                  : TabBarView(
                      controller: logic.gameTabController,
                      children: logic.categoryList.map((category) {
                        final int type = category.gameCategory ?? 0;
                        if (logic.gameTypeList[type] != null) {
                          return _buildGameList(type);
                        }
                        return buildCommonEmptyView("找不到游戏～");
                      }).toList())),
    );
  }

  Widget _buildGameList(int type) {
    HomeGamePageController logic = Get.find<HomeGamePageController>();
    return Obx(() => RepaintBoundary(
        child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: Dimens.pt24,
                mainAxisSpacing: Dimens.pt30,
                childAspectRatio: 162 / 200),
            itemCount: logic.gameTypeList[type]?.length ?? 0,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context, int index) {
              GameInfoBean? bean = logic.gameTypeList[type]?[index];
              return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    logic.enterLoading.value = true;
                    await logic.enterGame(
                        gameType: bean?.gameType,
                        platform: bean?.gamePlatform);
                    logic.enterLoading.value = false;
                  },
                  child: Column(children: [
                    ImageLoader.withP(bean?.coverImg ?? "",
                            width: Dimens.pt160,
                            height: Dimens.pt190)
                        .load()
                  ]));
            })));
  }

  Widget _buildGameTypesView() {
    HomeGamePageController logic = Get.find<HomeGamePageController>();
    return SizedBox(
      height: Dimens.pt60,
      width: screen.screenWidth,
      child: ListView.separated(
          controller: logic.gameTypeScrollController,
          scrollDirection: Axis.horizontal,
          itemBuilder: (c, index) => Obx(() => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                  horizontal: Dimens.pt15, vertical: Dimens.pt4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.pt8),
                border: Border.all(
                    color: logic.actionIndex.value == index
                        ? Color(0xFFFFB715)
                        : Color(0xFF858589)),
              ),
              child: GestureDetector(
                  onTap: () {
                    logic.gameTabController?.animateTo(index);
                  },
                  child: Row(children: [
                    Image.asset(
                        logic.actionIndex.value == index
                            ? logic.categoryList[index].sleIcon ?? ""
                            : logic.categoryList[index].icon ?? "",
                        width: Dimens.pt35,
                        height: Dimens.pt35),
                    SizedBox(width: Dimens.pt15),
                    Text(logic.categoryList[index].title ?? "",
                        style: TextStyle(
                            fontSize: Dimens.pt30,
                            fontWeight: logic.actionIndex.value == index
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: logic.actionIndex.value == index
                                ? Color(0xFFFFB715)
                                : Color(0xFF858589)))
                  ])))),
          separatorBuilder: (c, index) => SizedBox(width: Dimens.pt20),
          itemCount: logic.categoryList.length),
    );
  }

  Widget gameUtilItemBackground(
      {double? width, Widget? child, VoidCallback? onTap}) {
    return GestureDetector(
        onTap: () => onTap?.call(),
        child: Container(
            padding: EdgeInsets.all(Dimens.pt15),
            alignment: Alignment.center,
            child: child));
  }

  Widget _buildHomeHeader(HomeGamePageController logic, ThemeManager theme) {
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
                  theme: theme)),
          Spacer(),
          GestureDetector(
              onTap: () => Get.toNamed(Routes.BILL_RECORD_PAGE_VIEW,
                  arguments: {"type": 0}),
              child:
                  Image.asset(R.assetsImgIconMineRecored, width: Dimens.pt40)),
          SizedBox(width: Dimens.pt40),
          GestureDetector(
              onTap: () => Get.toNamed(Routes.MESSAGE_CENTER_PAGE),
              child:
                  Image.asset(R.assetsImgIconMineMessage, width: Dimens.pt40)),
        ]));
  }
}

class _GameUtilsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _GameUtilsHeaderDelegate({required this.child});

  @override
  double get minExtent => Dimens.pt200; // 固定高度

  @override
  double get maxExtent => Dimens.pt200; // 固定高度

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_GameUtilsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
