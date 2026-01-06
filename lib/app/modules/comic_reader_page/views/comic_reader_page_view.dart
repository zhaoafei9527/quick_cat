import 'package:acgn_client/app/model/comic_info_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/app/widget/reader_common_widget.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/comic_reader_page_controller.dart';

class ComicReaderPageView extends GetView<ComicReaderPageController> {
  const ComicReaderPageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<ComicReaderPageController>(builder: (logic) {
      return Stack(alignment: Alignment.topCenter, children: [
        /// 漫画图片内容
        GestureDetector(
            onTap: logic.closeUtilsPanel,
            onLongPress: () => () {},
            child: Scaffold(
                backgroundColor: theme.getColor(ThemeColor.bg),
                body: logic.initOk.value
                    ? buildComicPics(logic)
                    : getLoadingWidget())),

        /// 黑色背景
        IgnorePointer(
            ignoring: true,
            child: Container(
                width: screen.screenWidth,
                height: screen.screenHeight,
                color: Colors.black.withOpacity(logic.groundOpacity.value > .8
                    ? 0.8
                    : logic.groundOpacity.value))),

        /// 头部工具栏
        Obx(() => buildReaderAppBar(
            showBar: logic.showUtilityBar.value,
            isStore: logic.isCollect.value,
            onAddStore: () => logic.addStore(),
            title: logic.title.value)),

        /// 时间、页码显示工具
        buildReadNumberTipView(logic),

        /// 底部工具栏
        if (logic.initOk.value)
          buildReaderUtilityBar(logic.comicsData.value!,
              showBar: logic.showUtilityBar.value,
              sliderValue: logic.sliderValue.value,
              isNovelModel: false,
              readNum: logic.readNum.value,
              readChapterId: logic.chapterId.value,
              onReadNewChapter: (Chapter? chapter) =>
                  logic.onReadNewChapter(chapter),
              onChangeChapter: (bool isNext) =>
                  logic.onChangeChapter(isNext: isNext),
              onSliderValueChanged: (value) =>
                  logic.onSliderValueChanged(value),
              showDarkModel: !logic.showDarkModel.value,
              setDarkModelFunc: () => logic.setDarkModelFunc(),
              openSettingFunc: () => logic.openSettingFunc(),
              chapterList: logic.chapterList),

        /// 设置工具栏
        buildReaderSettingBar(
            showSettingBar: logic.showSettingBar.value,
            autoPlay: logic.showAutoPlay.value,
            isNovelModel: false,
            onAutoPlayChanged: (value) => logic.onAutoPlayChanged(value),
            groundOpacity: logic.groundOpacity.value,
            onGroundOpacityChanged: (value) =>
                logic.onGroundOpacityChanged(value)),
      ]);
    });
  }

  Widget buildCommentInputView(
      ComicReaderPageController logic, ThemeManager theme) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: logic.sendComment,
        child: Container(
            width: screen.screenWidth,
            height: Dimens.pt68,
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt16),
            color: theme.getColor(ThemeColor.bgGrey),
            child: Row(children: [
              Text("我怀疑你想发评论,但是我没有证据",
                  style: TextStyle(
                      fontSize: Dimens.pt22, color: const Color(0xFF505050))),
              const Spacer(),
              Image.asset(R.assetsImgIconSend,
                  width: Dimens.pt68,
                  color: Get.find<ThemeManager>().getColor(ThemeColor.textGrey))
            ])));
  }

  Widget buildReadNumberTipView(ComicReaderPageController logic) {
    return Obx(() {
      ThemeManager theme = Get.find<ThemeManager>();
      return Positioned(
          bottom: Dimens.pt50,
          child: AnimatedOpacity(
              opacity: !logic.scrolling.value ? 1 : .5,
              duration: Duration(milliseconds: 300),
              child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimens.pt30, vertical: Dimens.pt15),
                  color: theme.getColor(ThemeColor.bg),
                  child: Text.rich(
                      TextSpan(text: "第${logic.chapterNum}话 ", children: [
                        TextSpan(
                            text: "${logic.readNum.value + 1}",
                            style: TextStyle(
                                color: theme.getColor(ThemeColor.textYellow))),
                        TextSpan(text: "/${logic.chapterPicList.length} "),
                        TextSpan(
                            text: logic.currentTime.value,
                            style: TextStyle(
                                color: theme.getColor(ThemeColor.textGrey))),
                      ]),
                      style: TextStyle(
                          fontSize: Dimens.pt24,
                          color: theme.getColor(ThemeColor.primary))))));
    });
  }

  Widget buildComicPics(ComicReaderPageController logic) {
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

            // 如果正在自动滚动到指定位置，不更新readNum
            if (logic.isAutoScrollingToPosition) {
              return true;
            }

            // 计算当前可见区域的中心点
            double centerY = notification.metrics.pixels +
                notification.metrics.viewportDimension / 2;

            // 计算每个图片的高度
            double itemHeight = screen.screenWidth *
                (logic.chapterPicList[0].high ?? 0) /
                (logic.chapterPicList[0].width ?? 1);

            // 计算当前中心点对应的图片索引
            int currentIndex = (centerY / itemHeight).floor();

            // 确保索引在有效范围内
            if (currentIndex >= 0 &&
                currentIndex < logic.chapterPicList.length) {
              logic.readNum.value = currentIndex;
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
        child: ListView.builder(
            controller: logic.scrollController,
            physics: logic.canRead.value
                ? ClampingScrollPhysics()
                : NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            // 增加缓存范围
            cacheExtent: screen.screenHeight * 4,
            // 保持item状态
            addAutomaticKeepAlives: false,
            // 添加重绘边界
            addRepaintBoundaries: true,
            padding: EdgeInsets.zero,
            itemCount: logic.chapterPicList.length,
            itemBuilder: (context, index) {
              // 预加载前后图片
              if (index > 0) {
                _preloadImage(logic.chapterPicList[index - 1]);
              }
              if (index < logic.chapterPicList.length - 1) {
                _preloadImage(logic.chapterPicList[index + 1]);
              }

              return Container(
                  color: Colors.white,
                  child: MediaQuery.removePadding(
                    removeTop: false,
                    context: context,
                    child: RepaintBoundary(
                        child: GestureDetector(
                      onTap: () {
                        if (logic.chapterPicList[index].isAds ?? false) {
                          AppPages.jumpRouter(
                              path: logic.chapterPicList[index].adsUrl,
                              id: logic.chapterPicList[index].adsId);
                        }
                      },
                      child: ImageLoader.withP(
                              logic.chapterPicList[index].comicsPic,
                              width: screen.screenWidth,
                              height: screen.screenWidth *
                                  (logic.chapterPicList[index].high ??
                                      Dimens.pt195) /
                                  (logic.chapterPicList[index].width ??
                                      Dimens.pt690),
                              fit: BoxFit.contain)
                          .load(),
                    )),
                  ));
            }));
  }

  void _preloadImage(dynamic pic) {
    if (pic == null) return;
    ImageLoader.withP(pic.comicsPic,
            width: screen.screenWidth,
            height: screen.screenWidth * (pic.high ?? 0) / (pic.width ?? 1))
        .load();
  }

  Widget buildReaderSliderBar(
      {double value = .0, double total = 100, Function? onSetup}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return StatefulBuilder(builder: (context, setState) {
      return LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              setState(() {
                // 计算拖动位置相对于容器宽度的比例
                double newValue =
                    (details.localPosition.dx / constraints.maxWidth)
                        .clamp(0.0, 1.0);
                value = newValue;
                onSetup?.call(value);
              });
            },
            child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                      height: Dimens.pt50,
                      decoration: BoxDecoration(
                          color: theme.getColor(ThemeColor.textBlack),
                          borderRadius: BorderRadius.circular(Dimens.pt50))),
                  Stack(alignment: Alignment.centerRight, children: [
                    FractionallySizedBox(
                        widthFactor: value < .1 ? .1 : value,
                        child: Container(
                            height: Dimens.pt50,
                            decoration: BoxDecoration(
                                color: theme.getColor(ThemeColor.slider),
                                borderRadius:
                                    BorderRadius.circular(Dimens.pt50)))),
                    Container(
                        width: Dimens.pt50,
                        height: Dimens.pt50,
                        decoration: BoxDecoration(
                            color: theme.getColor(ThemeColor.textGrey),
                            borderRadius: BorderRadius.circular(Dimens.pt50)))
                  ])
                ]));
      });
    });
  }

  Widget buildUtilItemView(String icon, String label, {Function? onTap}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap?.call(),
        child: Column(children: [
          Image.asset(icon,
              width: Dimens.pt46,
              height: Dimens.pt40,
              color: theme.getColor(ThemeColor.primary)),
          SizedBox(height: Dimens.pt5),
          Text(label,
              style: TextStyle(
                  fontSize: Dimens.pt22,
                  color: theme.getColor(ThemeColor.primary)))
        ]));
  }
}
