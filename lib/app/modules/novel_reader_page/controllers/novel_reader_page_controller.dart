import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/comic_chapter.dart';
import 'package:quick_cat_client/app/model/comic_info_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NovelReaderPageController extends GetxController {
  final chapterId = 0.obs;
  RxBool canRead = true.obs;
  RxBool initOk = false.obs;
  RxBool scrolling = false.obs; // 是否正在滚动
  RxBool showAutoPlay = false.obs; // 是否显示自动播放
  RxBool showUtilityBar = true.obs; // 是否显示工具栏
  RxBool showDarkModel = true.obs; // 是否显示夜间模式
  RxBool showSettingBar = false.obs; // 是否显示设置界面
  RxString title = "".obs;
  RxBool isCollect = false.obs; // 是否收藏
  RxInt readNum = 0.obs; // 阅读的图片下标位置
  RxInt chapterNum = 1.obs; // 当前漫画章节的位置
  RxString currentTime = "".obs;
  RxBool isReverseOrder = false.obs; // 是否反转章节顺序
  RxList<Chapter> chapterList = <Chapter>[].obs;
  Rx<MediaInfo?> novelData = Rx<MediaInfo?>(null);
  RxString chapterContent = "".obs;
  RxDouble sliderValue = 0.0.obs;
  RxDouble groundOpacity = 0.1.obs; // 背景透明度
  RxInt currentBackgroundIndex = 1.obs; // 当前背景下标
  RxDouble currentFontSize = (Dimens.pt32).obs; // 当前字体大小
  final ScrollController scrollController = ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isManualScrolling = true; // 添加滚动状态标记 默认手动结束滚动

  @override
  void onInit() {
    super.onInit();
    ThemeManager theme = Get.find<ThemeManager>();
    chapterId.value = TextUtil.getIntArgument("chapterId");
    // 阅读的图片下标位置
    readNum.value = TextUtil.getIntArgument("readNum");
    // 当前漫画章节的位置
    chapterNum.value = TextUtil.getIntArgument("chapterNum");
    novelData.value = Get.arguments?['novelData'];
    isCollect.value = novelData.value?.isCollect ?? false;
    showDarkModel.value = theme.getCurrentTheme.index == ThemeModes.dark.index;
    startGetChapterData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> addStore() async {
    await ApiRes.addCollect(
        type: ActionType.Collect,
        collectType: MediaType.novel,
        objectId: novelData.value?.id ?? 0,
        flag: !isCollect.value);
    isCollect.value = !isCollect.value;
  }

  Future<void> startGetChapterData() async {
    initOk.value = false;
    PlayComicResponse? ready =
        await ApiRes.requestChapter(id: chapterId.value, type: MediaType.novel);
    if (ready?.playable ?? false) {
      ChapterDetails? model =
          await ApiRes.getChapter(id: chapterId.value, type: MediaType.novel);
      if (model != null) {
        chapterContent.value = model.content ?? "";
        chapterList.value = model.chapterInfos ?? [];
        if (chapterNum.value == 0 && chapterList.isNotEmpty) {
          chapterNum.value = chapterList[0].chapterNum ?? 1;
        }
        title.value = model.title ?? "";
        initOk.value = true;
      }
    } else {
      canRead.value = false;
      initOk.value = true;
      var result = await showPlayerCommonDialog(Get.context!,
          title: "友情提示",
          content: "对不起，您当前还不是会员开通会员才能继续观看小说章节",
          btnCall: [
            () => Get.toNamed(Routes.VIP_CENTER_PAGE),
            () => showShareAccountDialog()
          ],
          btnActionIndex: 0);
      if (!(result ?? false)) Get.back();
    }
  }

  void setDarkModelFunc() {
    ThemeManager themeManager = Get.find<ThemeManager>();
    showDarkModel.value = !showDarkModel.value;
    if (showDarkModel.value) {
      themeManager.switchTheme(0);
      currentBackgroundIndex.value = 4;
    } else {
      themeManager.switchTheme(1);
      currentBackgroundIndex.value = 0;
    }
  }

  void reverseChapterOrder() {
    isReverseOrder.value = !isReverseOrder.value;
    chapterList.value = chapterList.reversed.toList();
  }

  void closeUtilsPanel() {
    showSettingBar.value = false;
    showUtilityBar.value = !showUtilityBar.value;
  }

  void openSettingFunc() {
    // showUtilityBar.value = false;
    showSettingBar.value = true;
  }

  void sendComment() {}

  void onGroundOpacityChanged(double value) {
    groundOpacity.value = value;
  }

  Future<void> onReadNewChapter(Chapter? chapter) async {
    scaffoldKey.currentState?.closeDrawer();
    chapterNum.value = chapter?.chapterNum ?? 0;
    chapterId.value = chapter?.id ?? 0;
    int current = chapterList.indexWhere((e) => e.id == chapterId.value);
    readNum.value = 0; // 重置阅读位置
    sliderValue.value = current / (chapterList.length - 1);
    await startGetChapterData();
  }

  void onChangeChapter({bool? isNext}) async {
    int current =
        chapterList.indexWhere((e) => e.chapterNum == chapterNum.value);
    if (current == -1) return;
    if (isNext ?? false) {
      if (current < chapterList.length - 1) {
        chapterNum.value = chapterList[current + 1].chapterNum ?? 0;
        chapterId.value = chapterList[current + 1].id ?? 0;
        readNum.value = 0; // 重置阅读位置
      }
    } else {
      if (current > 0) {
        chapterNum.value = chapterList[current - 1].chapterNum ?? 0;
        chapterId.value = chapterList[current - 1].id ?? 0;
        readNum.value = 0; // 重置阅读位置
      }
    }
    sliderValue.value = current / (chapterList.length - 1);
    await startGetChapterData();
  }

  void onSliderValueChanged(double value) {
    sliderValue.value = value;
    // 计算当前章节的索引
    int currentIndex = (value * (chapterList.length - 1)).round();
    if (currentIndex < 0 || currentIndex >= chapterList.length) return;
    // 更新章节号和章节ID
    chapterNum.value = chapterList[currentIndex].chapterNum ?? 0;
    chapterId.value = chapterList[currentIndex].id ?? 0;
    // 更新阅读位置
    readNum.value = 0; // 重置阅读位置
    // 开始获取章节数据
    startGetChapterData();
  }

  /// 设置是否为手动滚动
  void setManualScrolling(bool value) {
    _isManualScrolling = value;
  }

  void startAutoScroll() {
    if (!_isManualScrolling && !showAutoPlay.value) return;
    // 获取当前滚动位置和最大滚动范围
    double currentOffset = scrollController.offset;
    double maxExtent = scrollController.position.maxScrollExtent;

    // 如果已经滚动到底部，则停止
    if (currentOffset >= maxExtent) {
      stopAutoScroll();
      return;
    }

    // 根据剩余距离计算滚动时间（保持相同的滚动速度）
    int scrollDuration = ((maxExtent / 10) / 10).toInt();
    // 确保在下一帧执行动画
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          maxExtent,
          duration: Duration(seconds: scrollDuration),
          curve: Curves.linear,
        );
      }
    });
  }

  void stopAutoScroll() {
    // 停止当前滚动动画
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.offset);
    }
  }

  // 监听自动播放状态变化
  void onAutoPlayChanged(bool value) {
    showAutoPlay.value = value;
    if (!value) {
      setManualScrolling(true);
      stopAutoScroll();
    } else {
      setManualScrolling(false);
      startAutoScroll();
    }
  }

  @override
  void onClose() {
    super.onClose();
    if (novelData.value != null) {
      // 保存阅读记录
      novelData.value!.readNum = readNum.value;
      novelData.value!.readChapterId = chapterId.value;
      WatchRecord.addWatchRecord(novelData.value!, MediaType.novel);
    }
  }
}
