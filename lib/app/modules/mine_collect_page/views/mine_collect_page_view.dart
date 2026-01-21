// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:quick_cat_client/app/widget/full_bg.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/widget/post_item.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import '../../../../utils/dimens.dart';
import '../../../model/home/topic_list_model.dart';
import '../../../themes/app_colors.dart';
import '../../../views/page_pull_view.dart';
import '../../../widget/common_app_bar.dart';
import '../../../widget/common_widget.dart';
import '../controllers/mine_collect_page_controller.dart';

class MineCollectPageView extends GetView<MineCollectPageController> {
  const MineCollectPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<MineCollectPageController>(builder: (logic) {
      double editHeight = Dimens.pt100 + screen.paddingBottom;

      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("我的收藏", actions: [
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
            Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                child: Column(children: [
                  SizedBox(height: Dimens.pt25),
                  buildCommonTabBar(
                      controller: logic.tabController,
                      insetsWidth: Dimens.pt8,
                      fontSize: Dimens.pt28,
                      isScrollable: true,
                      unselectedLabelColor: AppColors.textGrey,
                      alignment: TabAlignment.center,
                      tabs: logic.tabList.map((e) => Text(e)).toList()),
                  SizedBox(height: Dimens.pt25),
                  Expanded(
                      child: TabBarView(
                          controller: logic.tabController,
                          children: [
                        ...List.generate(logic.tabList.length, (index) {
                          MediaType type = logic.typeList[index];

                          if (type == MediaType.post) {
                            return _buildCollectPostView(type);
                          } else {
                            return _buildCollectVideoView(type);
                          }
                        })
                      ]))
                ])),
            buildEditPageUtilView(logic.editModel.value,
                isAllSelect: logic.allSelect.value,
                haveSel: logic.selectIds.isNotEmpty,
                onToggleAll: logic.toggleAllSelect,
                onDelete: logic.deleteCollectOfIds)
          ]));
    });
  }

  Widget _buildCollectPostView(type) {
    return PagePullView(
        key: const Key("key_post"),
        dataGetter: (int pageNum, int size) async {
          MediaList? model =
              await ApiRes.getCollectList(collectType: type, pageNum: pageNum);
          return model?.postList ?? [];
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          return ListView.separated(
              itemBuilder: (c, index) => PostItem(postBrief: list[index]),
              separatorBuilder: (c, index) => SizedBox(height: Dimens.pt25),
              itemCount: list.length ?? 0);
        });
  }

  Widget _buildCollectVideoView(MediaType type) {
    ThemeManager theme = Get.find<ThemeManager>();
    MineCollectPageController logic = Get.find<MineCollectPageController>();
    return PagePullView<MediaInfo>(
        key: Key("key_${type.index}_${logic.refreshTag.value}"),
        dataGetter: (int pageNum, int size) async {
          MediaList? model =
              await ApiRes.getCollectList(collectType: type, pageNum: pageNum);
          List<MediaInfo> medias = model?.mediaList ?? [];
          if(type == MediaType.novel) medias =  model?.novelList ?? [];
          logic.currentMedias[type] = medias;
          return medias;
        },
        emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
        widgetBuilder:
            (BuildContext context, List<dynamic> list, Widget? child) {
          bool isComics = type == MediaType.comic || type == MediaType.novel;
          int crossAxisCount = isComics ? 3 : 2;
          double aspectRatio = isComics ? 226 / 435 : 345 / 243;
          double? width = isComics ? Dimens.pt238 : Dimens.pt345;
          double? height = isComics ? Dimens.pt330 : Dimens.pt195;
          List<MediaInfo> mediaList = logic.currentMedias[type] ?? [];

          return GridView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
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
        });
  }
}
