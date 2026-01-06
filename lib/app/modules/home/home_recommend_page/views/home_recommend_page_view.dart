// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/modules/home/home_index_web/views/home_index_web_view.dart';
import 'package:quick_cat_client/app/modules/home/home_index_web/views/home_tab_pull_view.dart';

import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/full_bg.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../../../../../r.dart';
import '../../../../data/ads_type.dart';
import '../../../../routes/app_pages.dart';
import '../../../../themes/app_colors.dart';
import '../../../../widget/cover_banner.dart';
import '../controllers/home_recommend_page_controller.dart';

class HomeRecommendPageView extends GetView<HomeRecommendPageController> {
  const HomeRecommendPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<HomeRecommendPageController>(
        builder: (HomeRecommendPageController logic) {
      ThemeManager theme = Get.find<ThemeManager>();
      return PageBg(
          child: Container(
              margin: EdgeInsets.only(top: screen.paddingTop + Dimens.pt30),
              child: Column(children: [
                _buildHomeHeader(logic, theme),
                SizedBox(height: Dimens.pt25),
                CoverBanner(
                    //广告homeSwiperAds
                    aspectRatio: 750 / 336,
                    adsType: AdsType.homeSwiperAds,
                    onItemClick: (Advertise model) {
                      AppPages.jumpRouter(path: model.href, id: model.id);
                    }),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimens.pt30, vertical: Dimens.pt30),
                    child: buildRunningLightView()),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GestureDetector(
                    onTap: () => logic.rankModel.value = 0,
                    child: SizedBox(
                        width: Dimens.pt208,
                        height: Dimens.pt80,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("官方精选",
                                  style: TextStyle(
                                      fontSize: Dimens.pt28,
                                      color: logic.rankModel.value == 0
                                          ? AppColors.textColorWhite
                                          : AppColors.textGreyColor)),
                              if (logic.rankModel.value == 0)
                                Container(
                                    width: Dimens.pt24,
                                    height: Dimens.pt8,
                                    margin: EdgeInsets.only(top: Dimens.pt3),
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt8)))
                            ])),
                  ),
                  SizedBox(width: Dimens.pt85),
                  GestureDetector(
                      onTap: () => logic.rankModel.value = 1,
                      child: SizedBox(
                          width: Dimens.pt208,
                          height: Dimens.pt80,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("最多下载",
                                    style: TextStyle(
                                        fontSize: Dimens.pt28,
                                        color: logic.rankModel.value == 1
                                            ? AppColors.textColorWhite
                                            : AppColors.textGreyColor)),
                                if (logic.rankModel.value == 1)
                                  Container(
                                      width: Dimens.pt24,
                                      height: Dimens.pt8,
                                      margin: EdgeInsets.only(top: Dimens.pt3),
                                      decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                              Dimens.pt8)))
                              ])))
                ]),
                SizedBox(height: Dimens.pt30),
                Expanded(
                    child:
                        TabBarView(controller: logic.tabController, children: [
                  ...List.generate(logic.cateTopList.length, (index) {
                    return _buildPagePullView(index);
                  })
                ])),
                SizedBox(height: screen.bottomNavBarH)
              ])));
    });
  }

  Widget _buildPagePullView(int index) {
    HomeRecommendPageController logic = Get.find<HomeRecommendPageController>();
    return PagePullView<HGameInfo>(
        key: Key("pullKey_${index}_${logic.rankModel.value}"),
        dataGetter: (int pageNum, int size) async {
          HGameResult? result = await ApiRes.getHGameList(
              id: logic.cateTopList[index].id, flagRank: logic.rankModel.value);
          return result?.list ?? [];
        },
        enablePullDown: false,
        enablePullUp: false,
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          // 根据数据随机打乱顺序
          bool isRandom = logic.cateTopList[index].isRandom ?? false;
          if (isRandom) {
            int num = logic.cateTopList[index].line ?? 0;
            // 打乱前num个数据
            if (list.length > num && num > 1) {
              List<HGameInfo> subList = list.sublist(0, num).cast<HGameInfo>();
              subList.shuffle();
              list.replaceRange(0, num, subList);
            } else {
              list.shuffle();
            }
          }

          return Obx(
            () => _buildGameListView(list.cast<HGameInfo>(),
                isGame: logic.cateTopList[index].desc == "游戏"),
          );
        });
  }

  Widget _buildGameListView(List<HGameInfo> hGameList, {bool isGame = false}) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    List<HGameInfo> games = [];
    if (hGameList.isEmpty) return const SizedBox();
    bool isVip = shareKeys.isVip();
    for (var game in hGameList) {
      if (((game.showType ?? 1) == 1 && !isVip) || (game.showType ?? 1) == 0) {
        games.add(game);
      }
    }
    HomeRecommendPageController logic = Get.find<HomeRecommendPageController>();
    if (logic.rankModel.value == 1) {
      return _buildRankListView(games);
    }

    return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isGame ? 1 : 4,
            crossAxisSpacing: Dimens.pt14,
            mainAxisSpacing: Dimens.pt20,
            childAspectRatio: isGame ? 690 / 317 : 150 / 200),
        itemCount: games.length,
        itemBuilder: (BuildContext context, int index) {
          HGameInfo? bean = games[index];
          if (isGame) {
            return _buildGameItem(bean);
          }
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                AppPages.jumpRouter(path: bean.url ?? "");
                ApiRes.clickHGame(id: bean.id ?? 0);
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ImageLoader.withP(bean.cover ?? "",
                            width: isGame ? Dimens.pt345 : Dimens.pt150,
                            radius: Dimens.pt20,
                            height: isGame ? Dimens.pt180 : Dimens.pt150)
                        .load(),
                    SizedBox(height: Dimens.pt10),
                    Text(bean.name ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: Dimens.pt22,
                            color: AppColors.textColorWhite))
                  ]));
        });
  }

  Container _buildGameItem(HGameInfo bean) {
    return Container(
        color: Color(0xFF211C27),
        padding: EdgeInsets.all(Dimens.pt24),
        child: Column(children: [
          Row(children: [
            ImageLoader.withP(bean.cover ?? "",
                    width: Dimens.pt343, height: Dimens.pt180)
                .load(),
            SizedBox(width: Dimens.pt20),
            Expanded(
                child: SizedBox(
                    height: Dimens.pt180,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(bean.name ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: Dimens.pt28,
                                  color: AppColors.textColorWhite)),
                          SizedBox(height: Dimens.pt10),
                          Text("7.8分",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: Dimens.pt24,
                                  color: AppColors.textYellowColor)),
                          SizedBox(height: Dimens.pt10),
                          Expanded(
                              child: Wrap(children: [
                            ...List.generate(bean.tags?.length ?? 0, (index) {
                              return Container(
                                  margin: EdgeInsets.only(
                                      right: Dimens.pt10, top: Dimens.pt10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.pt10,
                                      vertical: Dimens.pt4),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(Dimens.pt6),
                                      border: Border.all(
                                          color: AppColors.textYellowColor)),
                                  child: Text(bean.tags?[index].tagName ?? "",
                                      style: TextStyle(
                                          fontSize: Dimens.pt22,
                                          color: AppColors.textYellowColor)));
                            })
                          ]))
                        ])))
          ]),
          Spacer(),
          Container(
              height: Dimens.pt70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.pt6),
                  border: Border.all(
                      color: AppColors.textYellowColor, width: Dimens.pt1)),
              alignment: Alignment.center,
              child: Text("立即试玩",
                  style: TextStyle(
                      fontSize: Dimens.pt28, color: AppColors.textYellowColor)))
        ]));
  }

  GridView _buildRankListView(List<HGameInfo> games) {
    return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: Dimens.pt14,
            mainAxisSpacing: Dimens.pt20,
            childAspectRatio: 690 / 110),
        itemCount: games.length,
        itemBuilder: (BuildContext context, int index) {
          HGameInfo? bean = games[index];
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                AppPages.jumpRouter(path: bean.url ?? "");
                ApiRes.clickHGame(id: bean.id ?? 0);
              },
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                ImageLoader.withP(bean.cover ?? "",
                        width: Dimens.pt110,
                        radius: Dimens.pt22,
                        height: Dimens.pt110)
                    .load(),
                SizedBox(width: Dimens.pt24),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(bean.name ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: Dimens.pt28,
                              color: AppColors.textColorWhite)),
                      SizedBox(height: Dimens.pt10),
                      Text(bean.desc ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: Dimens.pt24, color: AppColors.textGrey))
                    ])),
                SizedBox(width: Dimens.pt55),
                Container(
                    width: Dimens.pt120,
                    height: Dimens.pt60,
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(Dimens.pt8)),
                    child: Center(
                        child: Text("下载",
                            style: TextStyle(
                                fontSize: Dimens.pt28,
                                color: AppColors.bgColor1))))
              ]));
        });
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
      HomeRecommendPageController logic, ThemeManager theme) {
    return Container(
      height: Dimens.pt60,
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return Obx(() => GestureDetector(
                  onTap: () => logic.changeTabIndex(index),
                  child: Container(
                      height: Dimens.pt56,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt20),
                      decoration: BoxDecoration(
                          color: logic.currentTabIndex.value == index
                              ? AppColors.primaryColor
                              : AppColors.textGreyColor,
                          borderRadius: BorderRadius.circular(Dimens.pt8)),
                      child: Text(logic.cateTopList[index].name ?? "",
                          style: TextStyle(
                              fontSize: Dimens.pt28,
                              color: AppColors.textColorWhite))),
                ));
          },
          separatorBuilder: (context, index) => SizedBox(width: Dimens.pt20),
          itemCount: logic.cateTopList.length,
          scrollDirection: Axis.horizontal),
    );
  }
}
