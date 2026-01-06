import 'package:acgn_client/app/data/ads_type.dart';
import 'package:acgn_client/app/model/comic_info_model.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/ad_view.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/app/widget/reader_common_widget.dart';
import 'package:acgn_client/plugins_utils/VideoPlayer/src/player_setting_panel.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/novel_reader_page_controller.dart';

class NovelReaderPageView extends GetView<NovelReaderPageController> {
  const NovelReaderPageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<NovelReaderPageController>(builder: (logic) {
      return Stack(alignment: Alignment.center, children: [
        /// 小说内容
        GestureDetector(
            onTap: logic.closeUtilsPanel,
            onLongPress: () => () {},
            child: Scaffold(
                backgroundColor: AppColors
                    .novelBackgroundColors[logic.currentBackgroundIndex.value],
                key: logic.scaffoldKey,
                drawer: _buildChapterEndDrawer(logic),
                body: logic.initOk.value
                    ? buildNovelContent(logic)
                    : getLoadingWidget())),

        // /// 头部工具栏
        Obx(() => buildReaderAppBar(
            showBar: logic.showUtilityBar.value,
            isStore: logic.isCollect.value,
            onAddStore: () => logic.addStore(),
            bg: AppColors
                .novelBackgroundColors[logic.currentBackgroundIndex.value],
            textColor:
                AppColors.novelTextColors[logic.currentBackgroundIndex.value],
            title: logic.title.value)),
        //
        /// 时间、页码显示工具
        // buildReadNumberTipView(logic),
        //
        /// 底部工具栏
        buildReaderUtilityBar(logic.novelData.value!,
            showBar: logic.showUtilityBar.value,
            sliderValue: logic.sliderValue.value,
            onChangeChapter: (bool isNext) =>
                logic.onChangeChapter(isNext: isNext),
            onSliderValueChanged: (value) => logic.onSliderValueChanged(value),
            showDarkModel: !logic.showDarkModel.value,
            isNovelModel: true,
            readNum: logic.readNum.value,
            readChapterId: logic.chapterId.value,
            onReadNewChapter: (Chapter? chapter) =>
                logic.onReadNewChapter(chapter),
            currentBackgroundIndex: logic.currentBackgroundIndex.value,
            onShowChapterList: () {
              logic.closeUtilsPanel();
              logic.scaffoldKey.currentState?.openDrawer();
            },

            // setDarkModelFunc: () => logic.setDarkModelFunc(),
            openSettingFunc: () => logic.openSettingFunc(),
            chapterList: logic.chapterList),

        if (logic.showSettingBar.value)
          IgnorePointer(
              ignoring: true,
              child: Container(
                  width: screen.screenWidth,
                  height: screen.screenHeight,
                  color: Colors.black.withOpacity(.5))),

        /// 设置工具栏
        buildReaderSettingBar(
            showSettingBar: logic.showSettingBar.value,
            autoPlay: logic.showAutoPlay.value,
            isNovelModel: true,
            currentBackgroundIndex: logic.currentBackgroundIndex.value,
            onAutoPlayChanged: (value) => logic.onAutoPlayChanged(value),
            onChangeFontSize: (value) {
              if (value > 10.0 && value < 40.0) {
                logic.currentFontSize.value = value;
              }
            },
            fontSize: logic.currentFontSize.value,
            onChangeBgColor: (value) =>
                logic.currentBackgroundIndex.value = value,
            groundOpacity: logic.groundOpacity.value,
            onGroundOpacityChanged: (value) =>
                logic.onGroundOpacityChanged(value)),

        /// 黑色背景 亮度调节
        IgnorePointer(
            ignoring: true,
            child: Container(
                width: screen.screenWidth,
                height: screen.screenHeight,
                color: Colors.black.withOpacity(logic.groundOpacity.value > .8
                    ? 0.8
                    : logic.groundOpacity.value)))
      ]);
    });
  }

  Widget _buildChapterEndDrawer(NovelReaderPageController logic) {
    Color bg =
        AppColors.novelBackgroundColors[logic.currentBackgroundIndex.value];
    Color textColor =
        AppColors.novelTextColors[logic.currentBackgroundIndex.value];
    return Container(
      width: Dimens.pt600 + Dimens.pt40,
      // padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
      color: bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: Dimens.pt30 + screen.paddingTop),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
          child: Text(logic.title.value,
              style: TextStyle(fontSize: Dimens.pt40, color: textColor)),
        ),
        SizedBox(height: Dimens.pt20),
        Container(
            padding: EdgeInsets.symmetric(
                horizontal: Dimens.pt30, vertical: Dimens.pt8),
            margin: EdgeInsets.only(right: Dimens.pt60),
            color: textColor.withOpacity(.1),
            child: Row(children: [
              Text("共${logic.chapterList.length}章",
                  style: TextStyle(fontSize: Dimens.pt30, color: textColor)),
              Spacer(),
              GestureDetector(
                  onTap: () => logic.reverseChapterOrder(),
                  child: Row(children: [
                    Text("正序",
                        style: TextStyle(
                            fontSize: Dimens.pt30,
                            color: !logic.isReverseOrder.value
                                ? AppColors.mainRed
                                : textColor)),
                    SizedBox(width: Dimens.pt20),
                    getHengLine(
                        h: Dimens.pt26,
                        w: Dimens.pt2,
                        color: textColor.withOpacity(.5)),
                    SizedBox(width: Dimens.pt20),
                    Text("倒序",
                        style: TextStyle(
                            fontSize: Dimens.pt30,
                            color: logic.isReverseOrder.value
                                ? AppColors.mainRed
                                : textColor))
                  ]))
            ])),
        SizedBox(height: Dimens.pt40),
        Expanded(
            child: ListView.separated(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () =>
                          logic.onReadNewChapter(logic.chapterList[index]),
                      child: Text(logic.chapterList[index].title ?? "",
                          style: TextStyle(
                              fontSize: Dimens.pt26,
                              color: textColor.withOpacity(.9))));
                },
                separatorBuilder: (context, index) =>
                    SizedBox(height: Dimens.pt30),
                itemCount: logic.chapterList.length))
      ]),
    );
  }

  Widget buildNovelContent(NovelReaderPageController logic) {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification) {
            logic.scrolling.value = true;

            // 如果正在自动滚动，用户手动滚动时停止自动滚动
            if (!logic.showAutoPlay.value) {
              // 标记正在手动滚动
              logic.showUtilityBar.value = false;
              logic.showSettingBar.value = false;
              logic.setManualScrolling(true);
            }
          } else if (notification is ScrollEndNotification) {
            logic.scrolling.value = false;
            // 如果开启了自动播放，在滚动结束时重新开始自动滚动
            if (logic.showAutoPlay.value) {
              logic.startAutoScroll();
            }
          }
          return true;
        },
        child: SingleChildScrollView(
            controller: logic.scrollController,
            physics: const BouncingScrollPhysics(),
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimens.pt20 + screen.paddingTop),
                      AdView(
                          type: AdsType.minSwiperAds,
                          width: Dimens.pt700,
                          height: Dimens.pt195),
                      SizedBox(height: Dimens.pt20),
                      Text(logic.title.value,
                          style: TextStyle(
                              fontSize: logic.currentFontSize.value,
                              color: AppColors.novelTextColors[
                                  logic.currentBackgroundIndex.value])),
                      SizedBox(height: Dimens.pt25),
                      Text(logic.chapterContent.value,
                          style: TextStyle(
                              fontSize: logic.currentFontSize.value,
                              letterSpacing: 1.2,
                              height: 1.5,
                              color: AppColors.novelTextColors[
                                  logic.currentBackgroundIndex.value])),
                      SizedBox(height: Dimens.pt20 + screen.paddingBottom)
                    ]))));
  }
}
