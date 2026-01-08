import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/comic_chapter.dart';
import 'package:quick_cat_client/app/model/comic_info_model.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class ComicReaderPageController extends GetxController {
  final chapterId = 0.obs;
  int coinNum = 0;
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
  RxList<Chapter> chapterList = <Chapter>[].obs;
  Rx<MediaInfo?> comicsData = Rx<MediaInfo?>(null);
  RxList<ChapterPicItem> chapterPicList = <ChapterPicItem>[].obs;
  Timer? _timer;
  RxDouble sliderValue = 0.0.obs;
  RxDouble groundOpacity = 0.1.obs; // 背景透明度
  final ScrollController scrollController = ScrollController();
  bool _isManualScrolling = true; // 添加滚动状态标记 默认手动结束滚动
  bool _isAutoScrollingToPosition = false; // 添加自动滚动到指定位置的标志

  @override
  void onInit() {
    super.onInit();
    ThemeManager theme = Get.find<ThemeManager>();
    chapterId.value = TextUtil.getIntArgument("chapterId");
    coinNum = TextUtil.getIntArgument("coinNum");
    // 阅读的图片下标位置
    readNum.value = TextUtil.getIntArgument("readNum");
    // 当前漫画章节的位置
    chapterNum.value = TextUtil.getIntArgument("chapterNum");
    comicsData.value = Get.arguments?['comicInfo'];
    isCollect.value = comicsData.value?.isCollect ?? false;
    showDarkModel.value = theme.getCurrentTheme.index == ThemeModes.dark.index;

    startGetChapterData();
    // 更新当前系统时间
    _startTimer();
  }

  void _startTimer() {
    // 立即更新一次时间
    _updateTime();
    // 每秒更新一次时间
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    DateTime now = DateTime.now();
    currentTime.value = "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";
  }

  Future<void> startGetChapterData() async {
    initOk.value = false;
    PlayComicResponse? ready =
        await ApiRes.requestChapter(id: chapterId.value, type: MediaType.comic);
    coinNum = ready?.price ?? 0;
    bool playable = ready?.playable ?? false;
    bool isCoinMedia =
        comicsData.value?.comicsPayType == PaymentType.coinPaymentType;
    if (!playable && isCoinMedia) {
      canRead.value = false;
      initOk.value = true;
      playable = await _showCoinPayDialog();
    } else if (!playable && !isCoinMedia) {
      canRead.value = false;
      initOk.value = true;
      playable = await _showVipPayDialog();
    }

    if (playable) {
      ChapterDetails? model =
          await ApiRes.getChapter(id: chapterId.value, type: MediaType.comic);
      canRead.value = true;
      if (model != null) {
        Advertise? ads =
            await LocalAdsStore().randomWhere(AdsType.minSwiperAds);

        chapterPicList.assignAll([
          ChapterPicItem(
              comicsPic: ads?.cover ?? "",
              width: 680 ~/ 2,
              high: 195 ~/ 2,
              isAds: true,
              adsId:ads?.id,
              adsUrl: ads?.href),
          ...model.chapterPicItem ?? [],
        ]);
        chapterList.value = model.chapterInfos ?? [];
        if (chapterNum.value == 0 && chapterList.isNotEmpty) {
          chapterNum.value = chapterList[0].chapterNum ?? 1;
        }
        title.value = model.title ?? "";
      }
      Future.delayed(Durations.extralong2, () {
        // 自动滚动到相应的图片阅读位置
        scrollToReadPosition();
        initOk.value = true;
      });
    }
  }

  Future<bool> _showCoinPayDialog() async {
    bool callBuyBack = false;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    double userBalance = double.tryParse(shareKeys.userBalance.value) ?? .0;
    double price = coinNum / 100;
    callBuyBack = await showPlayerCommonDialog(Get.context!,
        title: "友情提示",
        content: "该漫画章节仅会员用户可观看,请先获得会员！",
        btnCall: [
          () async {
            if (userBalance >= price) {
              await ApiRes.buyComicOfId(
                  id: comicsData.value?.id ?? 0,
                  onSuccess: () => Get.back(result: true));
              showTypeToast(msg: "解锁成功！", toastType: ToastType.SUCCESS);
              shareKeys.getUserInfo(needUpdate: true);
            } else {
              showTypeToast(msg: "余额不足，请充值后再试！");
            }
          },
          () => Get.toNamed(Routes.VIP_CENTER_PAGE),
        ],
        btnActionIndex: 0);
    return callBuyBack;
  }

  Future<bool> _showVipPayDialog() async {
    bool callBuyBack = false;
    callBuyBack = await showPlayerCommonDialog(Get.context!,
            title: "友情提示",
            content: "该漫画章节仅会员用户可观看,请先获得会员！",
            btnCall: [
              () => Get.toNamed(Routes.VIP_CENTER_PAGE),
              () => Get.back(result: false)
            ],
            btnActionIndex: 0) ??
        false;

    return callBuyBack;
  }

  /// 计算指定readNum位置的高度并滚动到该位置
  void scrollToReadPosition() {
    if (chapterPicList.isEmpty ||
        readNum.value < 0 ||
        readNum.value >= chapterPicList.length) {
      return;
    }

    // 确保scrollController已经初始化
    if (!scrollController.hasClients) {
      // 如果scrollController还没有准备好，延迟执行
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollToReadPosition();
      });
      return;
    }

    // 设置自动滚动标志
    _isAutoScrollingToPosition = true;

    // 计算目标位置的高度
    double targetOffset = calculateReadPositionOffset(readNum.value);
    _isAutoScrollingToPosition = false;
    scrollController.jumpTo(targetOffset);
  }

  /// 计算指定readNum位置对应的滚动偏移量
  double calculateReadPositionOffset(int targetReadNum) {
    if (chapterPicList.isEmpty ||
        targetReadNum < 0 ||
        targetReadNum >= chapterPicList.length) {
      return 0.0;
    }

    double totalOffset = 0.0;

    // 计算目标位置之前所有图片的高度总和
    for (int i = 0; i < targetReadNum; i++) {
      if (i < chapterPicList.length) {
        double itemHeight = calculateItemHeight(chapterPicList[i]);
        totalOffset += itemHeight;
      }
    }

    return totalOffset;
  }

  /// 计算单个图片项的高度
  double calculateItemHeight(ChapterPicItem pic) {
    if (pic.width == null || pic.width == 0 || pic.high == null) {
      return 0.0;
    }

    // 使用屏幕宽度和图片的宽高比计算高度
    return screen.screenWidth * (pic.high! / pic.width!);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() async {
    _timer?.cancel();
    stopAutoScroll();
    // 存储阅读记录
    if (comicsData.value != null) {
      comicsData.value!.readNum = readNum.value;
      comicsData.value!.readChapterId = chapterId.value;
      await WatchRecord.addWatchRecord(comicsData.value!, MediaType.comic);
    }
    scrollController.dispose();
    super.onClose();
  }

  void setDarkModelFunc() {
    ThemeManager themeManager = Get.find<ThemeManager>();
    showDarkModel.value = !showDarkModel.value;
    if (showDarkModel.value) {
      groundOpacity.value = 0.3;
      themeManager.switchTheme(0);
    } else {
      groundOpacity.value = 0.1;
      themeManager.switchTheme(1);
    }
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

  Future<void> onReadNewChapter(Chapter? chapter) async {
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

  Future<void> addStore() async {
    await ApiRes.addCollect(
        type: ActionType.Collect,
        collectType: MediaType.comic,
        objectId: comicsData.value?.id ?? 0,
        flag: !isCollect.value);
    isCollect.value = !isCollect.value;
  }

  /// 设置是否为手动滚动
  void setManualScrolling(bool value) {
    _isManualScrolling = value;
  }

  /// 检查是否正在自动滚动到指定位置
  bool get isAutoScrollingToPosition => _isAutoScrollingToPosition;

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
}
