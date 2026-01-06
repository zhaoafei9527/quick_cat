// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/fjik_tiktok_player.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/modules/home/home_post_page/views/post_recommend_view.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/keep_alive_wrapper.dart';
import '../../../../../r.dart';
import '../../../../../utils/screen.dart';
import '../controllers/home_post_page_controller.dart';

class HomePostPageView extends GetView<HomePostPageController> {
  const HomePostPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<HomePostPageController>(
        builder: (HomePostPageController logic) {
      return Scaffold(
          backgroundColor: AppColors.transparent,
          key: logic.scaffoldKey,
          endDrawer: _buildTagEndDrawer(logic),
          body: Stack(children: [
            Column(children: [
              if (logic.mediaList.isNotEmpty)
                Expanded(
                  child: Container(
                      color: Colors.black,
                      child: Center(
                          child: FijkTiktokFeedPage(
                              medias: logic.mediaList,
                              firstPlay: false,
                              initIndex: logic.initIndex,
                              onVideoPlay: (int videoId) =>
                                  logic.playVideoOfId(videoId),
                              onLoadMore: (int pageNum) => logic.dataGetter !=
                                      null
                                  ? logic.dataGetter!(pageNum)
                                  : logic.getMediasNetData(pageNum: pageNum),
                              controller: logic.tiktokPlayer))),
                )
              else
                Expanded(
                    child: Container(
                        color: AppColors.bgColor,
                        child: LoadingView(
                            loading: !logic.initOk.value,
                            child: buildCommonEmptyView("没有找到数据")))),
              Container(
                  height: screen.bottomNavBarH + Dimens.pt40,
                  color: Colors.black)
            ]),
            _buildPageHeader(logic)
          ]));
    });
  }

  Widget _buildPageHeader(HomePostPageController logic) {
    return Container(
      width: screen.screenWidth,
      height: Dimens.pt60,
      margin: EdgeInsets.only(top: screen.paddingTop + Dimens.pt55),
      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
      child: Row(children: [
        Spacer(),
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              logic.scaffoldKey.currentState?.openEndDrawer();
            },
            child: Image.asset(R.assetsImgIconTiktokTopic, width: Dimens.pt38))
      ]),
    );
  }

  Widget _buildTagEndDrawer(HomePostPageController logic) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    if (logic.tabController == null) {
      return Container();
    }
    return Container(
        width: Dimens.pt450,
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        color: AppColors.bgColor,
        child: Column(children: [
          SizedBox(height: screen.paddingTop + Dimens.pt20),
          Row(children: [
            Spacer(),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(Get.context!).pop();
                },
                child: Icon(Icons.close,
                    size: Dimens.pt40, color: AppColors.textColorWhite))
          ]),
          SizedBox(
              height: Dimens.pt66,
              child: buildCommonTabBar(
                  controller: logic.tabController,
                  insets: Dimens.pt38,
                  isScrollable: true,
                  alignment: TabAlignment.start,
                  tabs: shareKeys.mediaTagType
                      .map((e) => Text("${e.name}"))
                      .toList())),
          SizedBox(height: Dimens.pt20),
          Expanded(
              child: TabBarView(
                  controller: logic.tabController,
                  children:
                      List.generate(shareKeys.mediaTagType.length, (index) {
                    return PagePullView<TagList>(
                        key: Key("pullKey_tagType_$index"),
                        dataGetter: (int pageNum, int size) async {
                          TagTypeNetModel? model = await ApiRes.getTagListById(
                              shareKeys.mediaTagType[index].id ?? 0);
                          return model?.tagTypeList?[0].list ?? [];
                        },
                        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
                        widgetBuilder: (BuildContext context,
                            List<dynamic> list, Widget? child) {
                          return ListView.separated(
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () => logic.toTagPage(
                                        list[index].id ?? 0,
                                        name: list[index].name),
                                    child: Container(
                                        width: Dimens.pt374,
                                        height: Dimens.pt54,
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Dimens.pt25),
                                        decoration: BoxDecoration(
                                            color: Color(0xFF23232A),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(Dimens.pt45))),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(list[index].name ?? "",
                                                  style: TextStyle(
                                                      fontSize: Dimens.pt26,
                                                      color: AppColors
                                                          .textColorWhite))
                                            ])));
                              },
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: Dimens.pt25),
                              itemCount: list.length);
                        });
                  })))
        ]));
  }
}
