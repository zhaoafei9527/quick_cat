import 'package:acgn_client/app/model/episode_preview.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpisodePreviewPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> drawerKey = GlobalKey();
  RxBool drawerStatus = false.obs;
  List<int> yearList = [];
  int nowPreviewId = 0;
  int nowYear = DateTime.now().year;
  RxInt newEpisodeId = 0.obs;
  RxInt currentIndex = 0.obs;
  RxBool loading = true.obs;
  TabController? tabController;
  RxList<EpisodeItem> episodeList = <EpisodeItem>[].obs;
  RxList<ListElement> previewList = <ListElement>[].obs;
  Rx<EpisodeItem> nextPreview = EpisodeItem().obs;
  Rx<EpisodeItem> nowPreview = EpisodeItem().obs;
  Rx<EpisodeItem> previousPreview = EpisodeItem().obs;

  @override
  void onInit() async {
    super.onInit();
    await getYearListNetData();
    tabController = TabController(
        length: yearList.length, vsync: this, initialIndex: currentIndex.value);
    tabController?.addListener(() async {
      currentIndex.value = tabController?.index??0;

      getPreviewListNetData(yearList[currentIndex.value]);
    });

    await getPreviewListNetData(nowYear);
    getPreviewDetailNetData(newEpisodeId.value);
  }

  Future<void> getYearListNetData() async {
    yearList = [];
    YearList? years = await ApiRes.getPreviewYearList();
    if (years != null) {
      yearList.addAll(years.years ?? []);
      nowYear = yearList.first;
    }
  }

  Future<void> getPreviewListNetData(int year) async {
    episodeList.value = [];
    EpisodePreviewModel? preview =
        await ApiRes.getEpisodePreviewData(year: year);
    if (preview != null) {
      nowPreviewId = preview.nowPreviewId ?? 0;
      episodeList.value = preview.list ?? [];
      newEpisodeId.value = preview.nowPreviewId ?? 0;
      if (newEpisodeId.value <= 0) {
        getPreviewDetailNetData(episodeList.first.id ?? 0);
      }
    }
  }

  Future<void> getPreviewDetailNetData(int id) async {
    loading.value = true;
    PreviewDetails? model = await ApiRes.getPreviewDetail(id: id);
    loading.value = false;
    if (model != null) {
      previewList.value = model.list ?? [];
      nowPreview.value = model.nowPreview ?? EpisodeItem();
      nextPreview.value = model.nextPreview ?? EpisodeItem();
      previousPreview.value = model.previousPreview ?? EpisodeItem();
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
