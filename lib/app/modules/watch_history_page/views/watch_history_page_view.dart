import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/model/post_list_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/app/widget/full_bg.dart';
import 'package:quick_cat_client/app/widget/post_item.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/watch_history_page_controller.dart';

class WatchHistoryPageView extends GetView<WatchHistoryPageController> {
  const WatchHistoryPageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<WatchHistoryPageController>(
        builder: (WatchHistoryPageController logic) {
      return Scaffold(
        backgroundColor: theme.getColor(ThemeColor.bg),
        appBar: getCommonAppBar("历史记录", actions: [
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: Dimens.pt30),
            SizedBox(
                child: buildCommonTabBar(
                    controller: logic.tabController,
                    insetsWidth: Dimens.pt8,
                    fontSize: Dimens.pt28,
                    isScrollable: true,
                    unselectedLabelColor: AppColors.textGrey,
                    alignment: TabAlignment.center,
                    tabs: logic.tabList.map((e) => Text(e)).toList())),
            SizedBox(height: Dimens.pt35),
            Expanded(
                child: TabBarView(controller: logic.tabController, children: [
              ...List.generate(logic.tabList.length, (index) {
                MediaType type = logic.typeList[index];
                if (type == MediaType.post) {
                  return _buildHistoryPostMediaView();
                } else {
                  return _buildHistoryMediaView(type);
                }
              })
            ])),
            SizedBox(height: screen.paddingBottom)
          ]),
          buildEditPageUtilView(logic.editModel.value,
              isAllSelect: logic.allSelect.value,
              haveSel: logic.selectIds.isNotEmpty,
              onToggleAll: logic.toggleAllSelect,
              onDelete: logic.deleteHistoryOfIds)
        ]),
      );
    });
  }

  Widget _buildHistoryPostMediaView() {
    MediaType type = MediaType.post;
    ThemeManager theme = Get.find<ThemeManager>();
    WatchHistoryPageController logic = Get.find<WatchHistoryPageController>();
    return PagePullView(
        key: Key("key_watch_history_view_post_${logic.refreshTag.value}"),
        enablePullUp: false,
        dataGetter: (int pageNum, int size) async {
          List<PostBrief>? posts =
              await WatchRecord.getWatchRecord(MediaType.post);
          logic.currentMedias[MediaType.post] = posts ?? [];
          return posts;
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          List<PostBrief> mediaList =
              (logic.currentMedias[type] ?? []).cast<PostBrief>();
          return ListView.separated(
              itemBuilder: (c, index) => GestureDetector(
                  onTap: () => logic.mediaItemOnTapPost(mediaList[index]),
                  child: Obx(
                      () => Stack(alignment: Alignment.topCenter, children: [
                            PostItem(postBrief: list[index]),
                            if (logic.editModel.value)
                              Container(
                                  height: Dimens.pt300,
                                  alignment: Alignment.center,
                                  color: theme
                                      .getColor(ThemeColor.bg)
                                      .withOpacity(.9),
                                  child: Image.asset(
                                      logic.selectIds.contains(
                                              mediaList[index].base?.id ?? 0)
                                          ? R.assetsImgIconEditSelected
                                          : R.assetsImgIconEditSelect,
                                      width: Dimens.pt50))
                          ]))),
              separatorBuilder: (c, index) => SizedBox(height: Dimens.pt25),
              itemCount: mediaList.length ?? 0);
        });
  }

  Widget _buildHistoryMediaView(MediaType type) {
    ThemeManager theme = Get.find<ThemeManager>();
    WatchHistoryPageController logic = Get.find<WatchHistoryPageController>();
    return PagePullView(
        key: Key(
            "key_watch_history_view_${type.index}_${logic.refreshTag.value}"),
        enablePullUp: false,
        dataGetter: (int pageNum, int size) async {
          List<MediaInfo>? medias = await WatchRecord.getWatchRecord(type);
          logic.currentMedias[type] = medias ?? [];
          return medias;
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          if (type == MediaType.post) {
            return ListView.separated(
                itemBuilder: (c, index) => PostItem(postBrief: list[index]),
                separatorBuilder: (c, index) => SizedBox(height: Dimens.pt25),
                itemCount: list.length ?? 0);
          } else {
            bool isComics = type == MediaType.comic || type == MediaType.novel;
            int crossAxisCount = isComics ? 3 : 2;
            double aspectRatio = isComics ? 226 / 435 : 345 / 243;

            double? width = isComics ? Dimens.pt238 : Dimens.pt345;
            double? height = isComics ? Dimens.pt330 : Dimens.pt195;
            if(type == MediaType.videoShort){
              crossAxisCount = 2;
              aspectRatio = 9 / 15;
              width = Dimens.pt340;
              height = Dimens.pt500;
            }

            List<MediaInfo> mediaList =
                (logic.currentMedias[type] ?? []).cast<MediaInfo>();
            return GridView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, //横向数量
                    crossAxisSpacing: Dimens.pt10,
                    mainAxisSpacing: Dimens.pt10,
                    childAspectRatio: aspectRatio),
                itemCount: mediaList.length,
                itemBuilder: (c, index) {
                  MediaInfo? model = mediaList[index];
                  return Obx(() => GestureDetector(
                      onTap: () => logic.mediaItemOnTap(model, type),
                      child: Stack(children: [
                        getMediaCoverItemWidget(mediaList[index], type,
                            width: width,
                            height: height,
                            coverType: CoverType.coverVertical),
                        if (logic.editModel.value)
                          Container(
                              height: height,
                              alignment: Alignment.center,
                              color:
                                  theme.getColor(ThemeColor.bg).withOpacity(.7),
                              child: Image.asset(
                                  logic.selectIds.contains(model.id ?? 0)
                                      ? R.assetsImgIconEditSelected
                                      : R.assetsImgIconEditSelect,
                                  width: Dimens.pt50))
                      ])));
                });
          }
        });
  }
}
