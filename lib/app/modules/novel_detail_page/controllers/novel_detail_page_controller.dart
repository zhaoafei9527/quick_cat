import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/model/comic_info_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/views/pull_refresh_view.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NovelDetailPageController extends GetxController
    with GetTickerProviderStateMixin {
  final count = 0.obs;
  final novelId = 0.obs;
  late TabController tabController;
  final novelName = "".obs;
  RxBool initOk = false.obs;
  RxBool isCollect = false.obs;
  RxBool isReverseOrder = false.obs; // 章节列表是否倒序
  RxInt readChapterId = 0.obs; // 当前小说章节的位置
  RxInt readNum = 0.obs; // 阅读的图片下标位置
  RxInt readChapterNum = 0.obs; // 当前小说章节的位置
  RxInt readChapterIndex = 0.obs; // 当前小说章节的索引位置
  Rx<MediaInfo?> novelData = Rx<MediaInfo?>(null);
  RxList<Chapter?> chapterList = <Chapter>[].obs;
  RxInt freeChapterCount = 0.obs;
  RxList<MediaInfo> recommendList = <MediaInfo>[].obs;
  List<String> tabList = ["推荐", "评论"];
  PullRefreshController pullRefreshController = PullRefreshController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onInit() async {
    super.onInit();
    novelId.value = TextUtil.getIntArgument("novelId");
    if (Get.arguments?['title'] != null) {
      novelName.value = Get.arguments?['title'] ?? "";
    }
    tabController = TabController(length: tabList.length, vsync: this);
    await getNetData();
    // 获取最近阅读信息
    getCurrentReadInfo();
  }

  Future<void> switchNovelPage(int id) async {
    novelId.value = id;
    initOk.value = false;
    novelName.value =  "加载中...";
    await getNetData();
    // 获取最近阅读信息
    await getCurrentReadInfo();
    initOk.value = true;
  }

  Future<void> getNetData() async {
    DetailPageResponse? model = await ApiRes.getNovelDetails(id: novelId.value);
    if (model != null) {
      isCollect.value = model.novelData?.isCollect ?? false;
      novelData.value = model.novelData;
      novelName.value = model.novelData?.title ?? "";
      chapterList.value = model.chapterList ?? [];
      freeChapterCount.value = chapterList
          .where((element) => element?.isFree == true)
          .toList()
          .length;
    }
    initOk.value = true;
  }

  void reverseChapterOrder() {
    isReverseOrder.value = !isReverseOrder.value;
    chapterList.value = chapterList.reversed.toList();
  }

  Future<void> startReadComicAndRecord({int? startChapterId}) async {
    // 没有阅读记录默认第一章节
    if (readChapterId.value == 0) {
      readChapterId.value =
          chapterList.isNotEmpty ? chapterList[0]?.id ?? 0 : 0;
    }
    int chapterId = readChapterId.value;
    int read = readNum.value;
    if (startChapterId != null) {
      chapterId = startChapterId;
      read = 0;
    }
    isCollect.value = await Get.toNamed(Routes.NOVEL_READER_PAGE, arguments: {
      "chapterId": "$chapterId",
      "readNum": read,
      "chapterNum": readChapterNum.value,
      "novelData": novelData.value
    });
    Future.delayed(Durations.extralong2, () => getCurrentReadInfo());
    novelData.value?.isCollect = isCollect.value;
  }

  Future<void> addCollectComic(MediaInfo? comicInfo) async {
    await ApiRes.addCollect(
        type: ActionType.Collect,
        collectType: MediaType.novel,
        objectId: comicInfo?.id,
        flag: !isCollect.value);
    isCollect.value = !isCollect.value;
  }

  Future<void> getCurrentReadInfo() async {
    // 获取上次阅读位置
    List<MediaInfo> medias = await WatchRecord.getWatchRecord(MediaType.novel);
    int index = medias.indexWhere((e) => e.id == novelId.value);
    if (index >= 0) {
      readChapterId.value = medias[index].readChapterId ?? readChapterId.value;
      readNum.value = medias[index].readNum ?? 0;
      int readIndex = chapterList.indexWhere(
        (e) => e?.id == readChapterId.value,
      );
      readChapterIndex.value = readIndex;
      readChapterNum.value = chapterList[readIndex]?.chapterNum ?? 0;
    }
    log.i("_getCurrentReadInfo",
        "readChapterId==${readChapterId.value}, readNum==${readNum.value}");
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
