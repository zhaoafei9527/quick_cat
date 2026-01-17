import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/model/post_list_model.dart';
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchHistoryPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  RxList<int> selectIds = <int>[].obs;
  RxBool editModel = false.obs;
  RxBool allSelect = false.obs;
  RxBool refreshTag = false.obs;
  List<String> tabList = ["吃瓜", "视频", "抖阴", "动漫", "小说",];
  List<MediaType> typeList = [
    MediaType.post,
    MediaType.videoLong,
    MediaType.videoShort,
    MediaType.cartoon,
    MediaType.novel,
  ];
  RxMap<MediaType, List<dynamic>> currentMedias =
      <MediaType, List<dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabList.length, vsync: this);
  }

  void deleteHistoryOfIds() async {
    MediaType type = typeList[tabController!.index];
    if (selectIds.isEmpty) {
      showTypeToast(msg: "请选择要删除的记录");
      return;
    }
    await WatchRecord.removeWatchRecord(selectIds, type);
    refreshTag.value = !refreshTag.value;
    selectIds.clear();
  }

  void mediaItemOnTapPost(PostBrief model) {
    if (editModel.value) {
      toggleSelect(model.base?.id ?? 0);
    } else {}
  }

  void mediaItemOnTap(MediaInfo model, MediaType type) {
    if (editModel.value) {
      toggleSelect(model.id ?? 0);
    } else {
      itemOnTap(model, type);
    }
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
    MediaType type = typeList[tabController!.index];
    if (type == MediaType.post) {
      if (allSelect.value) {
        selectIds
            .addAll((currentMedias[type] ?? []).map((e) => e.base.id ?? 0));
      }
    } else {
      if (allSelect.value) {
        selectIds.addAll((currentMedias[type] ?? []).map((e) => e.id ?? 0));
      }
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
