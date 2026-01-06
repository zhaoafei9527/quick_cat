import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/dialog/comic_chapter_dialog.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/comic_info_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildReaderSettingBar(
    {bool showSettingBar = false,
    bool isNovelModel = false,
    bool autoPlay = false,
    Function(bool)? onAutoPlayChanged,
    double? groundOpacity,
    double? fontSize,
    int? currentBackgroundIndex,
    Function(double)? onChangeFontSize,
    Function(int)? onChangeBgColor,
    Function(double)? onGroundOpacityChanged}) {
  ThemeManager theme = Get.find<ThemeManager>();

  double trans = isNovelModel ? Dimens.pt374 : Dimens.pt284;
  int index = (currentBackgroundIndex ?? 0) - 1;
  index = index < 0 ? 4 : index;
  Color bg = isNovelModel
      ? AppColors.novelBackgroundColors[index ?? 0]
      : theme.getColor(ThemeColor.bg);
  Color textColor = isNovelModel
      ? AppColors.novelTextColors[index ?? 0]
      : theme.getColor(ThemeColor.primary);

  Color slider = isNovelModel
      ? AppColors.novelSlider[index ?? 0]
      : theme.getColor(ThemeColor.primary);
  return AnimatedPositioned(
      bottom: showSettingBar ? 0 : -trans,
      duration: Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSettingBar)
            Container(
                width: Dimens.pt255,
                height: Dimens.pt85,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimens.pt84)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset(R.assetsImgIconChapterShare,
                      width: Dimens.pt44, color: Colors.black),
                  SizedBox(width: Dimens.pt10),
                  Text("分享好友",
                      style:
                          TextStyle(fontSize: Dimens.pt32, color: Colors.black))
                ])),
          SizedBox(height: Dimens.pt60),
          Container(
              height: trans,
              width: Dimens.pt600 + Dimens.pt80,
              margin: EdgeInsets.only(
                  bottom:
                      showSettingBar ? Dimens.pt40 + screen.paddingBottom : 0),
              padding: EdgeInsets.all(Dimens.pt40),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimens.pt12)),
              child: Column(children: [
                SizedBox(height: Dimens.pt20),
                if (isNovelModel)
                  buildNovelMoreSettings(
                      fontSize: fontSize,
                      textColor: Colors.black,
                      currentBackgroundIndex: currentBackgroundIndex,
                      changeFontSize: (val) => onChangeFontSize?.call(val),
                      changeBgColor: (val) => onChangeBgColor?.call(val)),
                SizedBox(height: Dimens.pt20),
                Row(children: [
                  SizedBox(width: Dimens.pt10),
                  Image.asset(R.assetsImgIconNovalLight, width: Dimens.pt42),
                  SizedBox(width: Dimens.pt50),
                  Expanded(
                      child: buildReaderSliderBar(
                          value: groundOpacity ?? .0,
                          isNovelModel: isNovelModel,
                          currentBackgroundIndex: currentBackgroundIndex,
                          onSetup: (value) =>
                              onGroundOpacityChanged?.call(value))),
                  SizedBox(width: Dimens.pt30),
                  Text("自动播放",
                      style: TextStyle(
                          fontSize: Dimens.pt24, color: Colors.black)),
                  Transform.scale(
                      scale: .65,
                      child: Switch(
                          padding: EdgeInsets.zero,
                          activeTrackColor: Colors.black.withOpacity(.2),
                          activeColor: AppColors.mainRed,
                          inactiveTrackColor: Colors.black.withOpacity(.1),
                          inactiveThumbColor: slider,
                          trackOutlineColor: MaterialStateProperty.all(
                              Colors.black.withOpacity(.1)),
                          value: autoPlay,
                          onChanged: (value) {
                            onAutoPlayChanged?.call(value);
                          }))
                ]),
                // SizedBox(height: Dimens.pt35),
                // if (!isNovelModel) buildCommentInputView(onTap: () => {}),
              ])),
        ],
      ));
}

Widget buildNovelMoreSettings(
    {double? fontSize,
    Color? textColor,
    int? currentBackgroundIndex,
    Function(double)? changeFontSize,
    Function(int)? changeBgColor}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Text("字体", style: TextStyle(fontSize: Dimens.pt28, color: textColor)),
      SizedBox(width: Dimens.pt50),
      GestureDetector(
        onTap: () => changeFontSize?.call((fontSize ?? Dimens.pt32) - 1),
        child: Container(
            width: Dimens.pt132,
            height: Dimens.pt50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: textColor?.withOpacity(.1),
                borderRadius: BorderRadius.circular(Dimens.pt68)),
            child: Text("A⁻",
                style: TextStyle(
                    fontSize: Dimens.pt32,
                    color: fontSize! < 11 ? Color(0xFF83827E) : textColor))),
      ),
      SizedBox(width: Dimens.pt25),
      Text("${(fontSize ?? Dimens.pt32).toInt()}",
          style: TextStyle(fontSize: Dimens.pt28, color: textColor)),
      SizedBox(width: Dimens.pt25),
      GestureDetector(
          onTap: () => changeFontSize?.call((fontSize ?? Dimens.pt32) + 1),
          child: Container(
              width: Dimens.pt132,
              height: Dimens.pt50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: textColor?.withOpacity(.1),
                  borderRadius: BorderRadius.circular(Dimens.pt68)),
              child: Text("A⁺",
                  style: TextStyle(
                      fontSize: Dimens.pt32,
                      color: fontSize > 38 ? Color(0xFF83827E) : textColor))))
    ]),
    SizedBox(height: Dimens.pt35),
    Row(children: [
      Text("背景", style: TextStyle(fontSize: Dimens.pt28, color: textColor)),
      SizedBox(width: Dimens.pt50),
      Expanded(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ...List.generate(
            AppColors.novelBackgroundColors.length - 1,
            (index) => GestureDetector(
                onTap: () => changeBgColor?.call(index),
                child: Container(
                    width: Dimens.pt58,
                    height: Dimens.pt58,
                    decoration: BoxDecoration(
                        color: AppColors.novelBackgroundColors[index],
                        border: Border.all(
                            color: Color(0xFF352C25),
                            width: index == currentBackgroundIndex
                                ? Dimens.pt4
                                : 0),
                        borderRadius: BorderRadius.circular(Dimens.pt58))))),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              changeBgColor?.call(AppColors.novelBackgroundColors.length - 1),
          child: Image.asset(
              currentBackgroundIndex ==
                      AppColors.novelBackgroundColors.length - 1
                  ? R.assetsImgIconNightSel
                  : R.assetsImgIconNight,
              width: Dimens.pt58),
        )
      ]))
    ])
  ]);
}

Widget buildReaderUtilityBar(MediaInfo model,
    {bool showBar = false,
    double? sliderValue,
    Function(double)? onSliderValueChanged,
    bool? showDarkModel,
    Function? openSettingFunc,
    Function? setDarkModelFunc,
    Function(Chapter?)? onReadNewChapter,
    Color? bg,
    Color? textColor,
    int? readChapterId,
    int? readNum,
    bool isNovelModel = false,
    int? currentBackgroundIndex,
    Function(bool)? onChangeChapter,
    Function? onShowChapterList,
    required List<Chapter?> chapterList}) {
  {
    double trans = Dimens.pt96;
    ThemeManager theme = Get.find<ThemeManager>();

    Color bg = isNovelModel
        ? AppColors.novelBackgroundColors[currentBackgroundIndex ?? 0]
        : theme.getColor(ThemeColor.bg);
    Color textColor = isNovelModel
        ? AppColors.novelTextColors[currentBackgroundIndex ?? 0]
        : theme.getColor(ThemeColor.primary);
    PaymentType? payType =
        isNovelModel ? model.novelPayType : model.comicsPayType;
    return AnimatedPositioned(
      bottom: showBar ? Dimens.pt40 + screen.paddingBottom : -trans,
      duration: Duration(milliseconds: 200),
      child: Container(
          width: Dimens.pt590,
          height: Dimens.pt96,
          alignment: Alignment.center,
          padding: EdgeInsets.all(Dimens.pt2),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Color(0xFFDAF33F), Color(0xFFEE0F37)]),
              borderRadius: BorderRadius.circular(Dimens.pt96)),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt50),
              width: Dimens.pt590,
              height: Dimens.pt96,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(Dimens.pt96)),
              child: Row(children: [
                GestureDetector(
                    onTap: () => onChangeChapter?.call(false),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: Dimens.pt30, color: Colors.white)),
                SizedBox(width: Dimens.pt60),
                GestureDetector(
                    onTap: () => showShareAccountDialog(),
                    child: Image.asset(R.assetsImgIconChapterShare,
                        width: Dimens.pt45)),
                Spacer(),
                GestureDetector(
                    onTap: () => onShowChapterList?.call(),
                    child: Image.asset(R.assetsImgIconReaderChapter,
                        width: Dimens.pt40)),
                Spacer(),
                GestureDetector(
                    onTap: () => openSettingFunc?.call(),
                    child: Image.asset(R.assetsImgIconReaderSetting,
                        width: Dimens.pt45)),
                SizedBox(width: Dimens.pt60),
                GestureDetector(
                    onTap: () => onChangeChapter?.call(true),
                    child: Icon(Icons.arrow_forward_ios,
                        size: Dimens.pt30, color: Colors.white))
              ]))),
      // child: Container(
      //     height: trans,
      //     width: screen.screenWidth,
      //     padding: EdgeInsets.only(
      //         top: Dimens.pt40, left: Dimens.pt25, right: Dimens.pt25),
      //     color: bg,
      //     child: Column(children: [
      //       Row(children: [
      //         GestureDetector(
      //           onTap: () => onChangeChapter?.call(false),
      //           child: Text(isNovelModel ? "上一章" : "上一话",
      //               style:
      //                   TextStyle(fontSize: Dimens.pt28, color: textColor)),
      //         ),
      //         SizedBox(width: Dimens.pt20),
      //         Expanded(
      //             child: buildReaderSliderBar(
      //                 value: sliderValue ?? .0,
      //                 isNovelModel: isNovelModel,
      //                 currentBackgroundIndex: currentBackgroundIndex,
      //                 onSetup: (value) => onSliderValueChanged?.call(value))),
      //         SizedBox(width: Dimens.pt20),
      //         GestureDetector(
      //             onTap: () => onChangeChapter?.call(true),
      //             child: Text(isNovelModel ? "下一章" : "下一话",
      //                 style:
      //                     TextStyle(fontSize: Dimens.pt28, color: textColor)))
      //       ]),
      //       SizedBox(height: Dimens.pt54),
      //       Padding(
      //           padding: EdgeInsets.symmetric(
      //               horizontal: Dimens.pt80 - Dimens.pt25),
      //           child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 buildUtilItemView(R.assetsImgIconReaderChapter, "目录",
      //                     textColor: textColor,
      //                     onTap: () => showComicChapterDialog(
      //                         context: Get.context!,
      //                         coverImg: model.coverImg ?? "",
      //                         comicsPayType:
      //                             payType ?? PaymentType.vipPaymentType,
      //                         price: model.price,
      //                         isBuy: model.isBuy ?? false,
      //                         onTap: (Chapter? chapter) {
      //                           onReadNewChapter?.call(chapter);
      //                           Get.back();
      //                         },
      //                         readNum: readNum,
      //                         readChapterId: readChapterId,
      //                         type: isNovelModel
      //                             ? MediaType.novel
      //                             : MediaType.comic,
      //                         isSeries: model.isSerial ?? false,
      //                         chapterList: chapterList)),
      //                 StatefulBuilder(builder: (context, setState) {
      //                   return buildUtilItemView(
      //                       showDarkModel ?? false
      //                           ? R.assetsImgIconReaderDark
      //                           : R.assetsImgIconReaderLight,
      //                       (showDarkModel ?? false) ? "夜间" : "日间",
      //                       textColor: textColor,
      //                       onTap: () => setDarkModelFunc?.call());
      //                 }),
      //                 buildUtilItemView(R.assetsImgIconReaderSetting, "设置",
      //                     textColor: textColor,
      //                     onTap: () => openSettingFunc?.call())
      //               ]))
      //     ]))
    );
  }
}

Widget buildReaderSliderBar(
    {double value = .0,
    double total = 100,
    bool isNovelModel = false,
    int? currentBackgroundIndex,
    Function(double)? onSetup}) {
  ThemeManager theme = Get.find<ThemeManager>();
  Color bg = isNovelModel
      ? AppColors.novelTextColors[currentBackgroundIndex ?? 0]
      : theme.getColor(ThemeColor.bgGrey);
  Color slider = isNovelModel
      ? AppColors.novelSlider[currentBackgroundIndex ?? 0]
      : theme.getColor(ThemeColor.primary);

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
            });
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            // 处理拖动结束时的逻辑
            onSetup?.call(value);
          },
          child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Container(
                    height: Dimens.pt10,
                    decoration: BoxDecoration(
                        color: Color(0xFFD5D5D5),
                        borderRadius: BorderRadius.circular(Dimens.pt50))),
                Stack(alignment: Alignment.centerRight, children: [
                  FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                          height: Dimens.pt8,
                          decoration: BoxDecoration(
                              color: AppColors.mainRed,
                              borderRadius:
                                  BorderRadius.circular(Dimens.pt60)))),
                  Transform.translate(
                      offset: Offset(.2, 0.0),
                      child: Container(
                          width: Dimens.pt10,
                          height: Dimens.pt10,
                          decoration: BoxDecoration(
                              color: slider,
                              borderRadius:
                                  BorderRadius.circular(Dimens.pt10))))
                ])
              ]));
    });
  });
}

AnimatedPositioned buildReaderAppBar(
    {String? title,
    bool showBar = false,
    bool isStore = false,
    Function? onAddStore,
    Color? bg,
    Color? textColor}) {
  ThemeManager theme = Get.find<ThemeManager>();
  double trans = Dimens.pt110 + screen.paddingTop;
  return AnimatedPositioned(
      top: showBar ? 0 : -trans,
      duration: Duration(milliseconds: 200),
      child: Container(
          height: trans,
          width: screen.screenWidth,
          color: bg ?? theme.getColor(ThemeColor.bg),
          padding: EdgeInsets.only(bottom: Dimens.pt30),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                    onTap: () {
                      ThemeManager.to.switchTheme(0);
                      Get.back(result: isStore);
                    },
                    child: Container(
                        padding: EdgeInsets.all(Dimens.pt15),
                        margin: EdgeInsets.only(left: Dimens.pt0),
                        child: Image.asset(R.assetsImgNavBack,
                            width: Dimens.pt40, color: textColor))),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(Dimens.pt10),
                        child: Text(title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: Dimens.pt34,
                                color: textColor ??
                                    theme.getColor(ThemeColor.primary),
                                fontWeight: FontWeight.w600)))),
                GestureDetector(
                    onTap: () {
                      if (!isStore) {
                        onAddStore?.call();
                      }
                    },
                    child: Container(
                        padding: EdgeInsets.all(Dimens.pt20),
                        child: Image.asset(
                            isStore
                                ? R.assetsImgIconNovalCollected
                                : R.assetsImgIconNovalCollect,
                            width: Dimens.pt40)))
              ])));
}

Widget buildUtilItemView(String icon, String label,
    {Function? onTap, Color? textColor}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Column(children: [
        Image.asset(icon,
            width: Dimens.pt46,
            height: Dimens.pt40,
            color: textColor ?? theme.getColor(ThemeColor.primary)),
        SizedBox(height: Dimens.pt5),
        Text(label,
            style: TextStyle(
                fontSize: Dimens.pt22,
                color: textColor ?? theme.getColor(ThemeColor.primary)))
      ]));
}
