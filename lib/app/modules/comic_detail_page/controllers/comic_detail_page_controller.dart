import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/data/watch_record.dart';
import 'package:acgn_client/app/model/comic_info_model.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/views/pull_refresh_view.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/utils/logger_utils.dart';
import 'package:acgn_client/utils/text_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ComicDetailPageController extends GetxController
    with GetTickerProviderStateMixin {
  final count = 0.obs;
  final comicId = 0.obs;
  late TabController tabController;
  final comicName = "".obs;
  RxBool initOk = false.obs;
  RxBool isCollect = false.obs;
  RxInt readNum = 0.obs; // 阅读的图片下标位置
  RxInt readChapterId = 0.obs; // 当前漫画章节的位置
  RxInt readChapterNum = 0.obs; // 当前漫画章节的位置
  Rx<MediaInfo?> comicsData = Rx<MediaInfo?>(null);
  RxList<Chapter?> chapterList = <Chapter>[].obs;
  RxList<MediaInfo> relatedVideo = <MediaInfo>[].obs;
  List<String> tabList = ["推荐", "评论"];
  PullRefreshController pullRefreshController = PullRefreshController();

  @override
  void onInit() async {
    super.onInit();
    comicId.value = TextUtil.getIntArgument("comicId");
    if (Get.arguments?['title'] != null) {
      comicName.value = Get.arguments?['title'] ?? "";
    }
    tabController = TabController(length: tabList.length, vsync: this);
    await getNetData();
    // 获取最近阅读信息
    getCurrentReadInfo();
  }

  Future<void> switchComicPage(int id) async {
    comicId.value = id;
    initOk.value = false;
    comicName.value =  "加载中...";
    await getNetData();
    // 获取最近阅读信息
    await getCurrentReadInfo();
    initOk.value = true;
  }

  Future<void> getNetData() async {
    DetailPageResponse? model = await ApiRes.getComicDetails(id: comicId.value);
    if (model != null) {
      isCollect.value = model.comicsData?.isCollect ?? false;
      comicsData.value = model.comicsData;
      comicName.value = model.comicsData?.title ?? "";
      chapterList.value = model.chapterList ?? [];
      relatedVideo.value = model.mediaList ?? [];
    }
    initOk.value = true;
  }

  Future<void> getCurrentReadInfo() async {
    // 获取上次阅读位置
    List<MediaInfo> medias = await WatchRecord.getWatchRecord(MediaType.comic);
    int index = medias.indexWhere((e) => e.id == comicId.value);
    if (index >= 0) {
      readChapterId.value = medias[index].readChapterId ?? readChapterId.value;
      readNum.value = medias[index].readNum ?? 0;
      int readIndex = chapterList.indexWhere(
        (e) => e?.id == readChapterId.value,
      );
      readChapterNum.value = chapterList[readIndex]?.chapterNum ?? 0;
    }
    log.i("_getCurrentReadInfo",
        "readChapterId==${readChapterId.value}, readNum==${readNum.value}");
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
    isCollect.value = await Get.toNamed(Routes.COMIC_READER_PAGE, arguments: {
      "chapterId": "$chapterId",
      "readNum": read,
      "chapterNum": readChapterNum.value,
      "comicInfo": comicsData.value,
    });
    Future.delayed(Durations.extralong2, () => getCurrentReadInfo());
    comicsData.value?.isCollect = isCollect.value;
  }

  Future<void> addCollectComic(MediaInfo? comicInfo) async {
    await ApiRes.addCollect(
        type: ActionType.Collect,
        collectType: MediaType.comic,
        objectId: comicInfo?.id,
        flag: !isCollect.value);
    isCollect.value = !isCollect.value;
  }

  @override
  void onReady() async {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    tabController.dispose();
  }

  void increment() => count.value++;
}
