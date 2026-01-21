// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../plugins_utils/VideoPlayer/fjik_tiktok_player.dart';
import '../../../data/share_key.dart';
import '../../../model/home/topic_list_model.dart';
import '../../../views/page_pull_view.dart';
import '../controllers/short_video_player_controller.dart';

class ShortVideoPlayerView extends GetView<ShortVideoPlayerController> {
  const ShortVideoPlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<ShortVideoPlayerController>(
        builder: (ShortVideoPlayerController logic) {
      return Scaffold(
        key: logic.scaffoldKey,
        endDrawer: _buildTagEndDrawer(logic),
        body: Stack(alignment: Alignment.topLeft, children: [
          if (logic.mediaList.isNotEmpty)
            Container(
                color: Colors.black,
                height: screen.screenHeight,
                padding: EdgeInsets.only(
                    bottom: screen.paddingBottom, top: screen.paddingTop),
                child: Center(
                    child: FijkTiktokFeedPage(
                        medias: logic.mediaList,
                        firstPlay: true,
                        initIndex: logic.initIndex,
                        onVideoPlay: (int videoId) =>
                            logic.playVideoOfId(videoId),
                        onLoadMore: (int pageNum) => logic.dataGetter != null
                            ? logic.dataGetter!(pageNum)
                            : logic.getMediasNetData(pageNum: pageNum),
                        controller: logic.tiktokPlayer)))
          else
            Container(
                height: screen.screenHeight,
                color: theme.getColor(ThemeColor.bg),
                child: LoadingView(
                    loading: !logic.initOk.value,
                    child: buildCommonEmptyView("没有找到数据"))),
          _buildPageHeader(logic),
        ]),
      );
    });
  }

  Widget _buildTagEndDrawer(ShortVideoPlayerController logic) {
    ThemeManager theme = Get.find<ThemeManager>();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    if (logic.tabController == null) {
      return Container();
    }
    return Container(
        width: Dimens.pt450,
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        color: theme.getColor(ThemeColor.bg),
        child: Column(children: [
          SizedBox(height: screen.paddingTop + Dimens.pt20),
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
                                        width: Dimens.pt400,
                                        height: Dimens.pt98,
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Dimens.pt25),
                                        color:
                                            theme.getColor(ThemeColor.bgGrey),
                                        child: Text(list[index].name ?? "",
                                            style: TextStyle(
                                                fontSize: Dimens.pt26,
                                                color: theme.getColor(
                                                    ThemeColor.textGrey)))));
                              },
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: Dimens.pt25),
                              itemCount: list.length);
                        });
                  })))
        ]));
  }

  Widget _buildPageHeader(ShortVideoPlayerController logic) {
    ThemeManager theme = Get.find<ThemeManager>();
    return Container(
        width: screen.screenWidth,
        height: Dimens.pt60,
        margin: EdgeInsets.only(top: screen.paddingTop + Dimens.pt55),
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: Row(children: [
          GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: Dimens.pt0),
                  child: Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: Dimens.pt42))),
          SizedBox(width: Dimens.pt15),
          Expanded(
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // logic.tiktokPlayer.togglePause(true);
                    Get.back();
                    Get.toNamed(Routes.SEARCH_PAGE);
                  },
                  child: Container(
                    height: Dimens.pt64,
                    decoration: BoxDecoration(
                      color: AppColors.bgColor,
                      borderRadius: BorderRadius.circular(Dimens.pt30),
                    ),
                    child: Row(children: [
                      SizedBox(width: Dimens.pt32),
                      Image.asset(R.assetsImgIconSearchEs, width: Dimens.pt35),
                      SizedBox(width: Dimens.pt20),
                      Text("输入关键字搜索更多内容",
                          style: TextStyle(
                              fontSize: Dimens.pt24,
                              color: AppColors.textColorWhite.withOpacity(.6)))
                    ]),
                  ))),
        ]));
  }
}
