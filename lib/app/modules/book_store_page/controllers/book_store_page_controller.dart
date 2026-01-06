import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookStorePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  List<String> cateTab = ["漫画", "小说"];
  List<String> sortTab = ["全部", "最近更新", "最新关注"];
  RxList<int> selectIds = <int>[].obs;
  late TabController cateTabController;
  RxInt sortIndex = 0.obs;
  RxBool editModel = false.obs;
  RxBool allSelect = false.obs;
  RxBool refreshTag = false.obs;
  RxMap<MediaType, List<MediaInfo>> currentMedias =
      <MediaType, List<MediaInfo>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    cateTabController = TabController(length: cateTab.length, vsync: this);
  }

  Future<void> deleteBookOfIds(MediaType type, List<int> ids) async {
    await ApiRes.delCollect(collectType: type, objectIds: ids);
  }

  void delBookIfIds() async {
    MediaType type =
        cateTabController.index == 0 ? MediaType.comic : MediaType.novel;
    await ApiRes.delCollect(collectType: type, objectIds: selectIds);
    refreshTag.value = !refreshTag.value;
    selectIds.clear();
  }

  void toggleSelect(int id) {
    if (selectIds.contains(id)) {
      selectIds.remove(id);
    } else {
      selectIds.add(id);
    }
    selectIds.refresh();
  }

  void toggleAllSelect() {
    allSelect.value = !allSelect.value;
    selectIds.clear();
    MediaType type =
        cateTabController.index == 0 ? MediaType.comic : MediaType.novel;
    if (allSelect.value) {
      selectIds.addAll((currentMedias[type] ?? []).map((e) => e.id ?? 0));
    }
    selectIds.refresh();
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
