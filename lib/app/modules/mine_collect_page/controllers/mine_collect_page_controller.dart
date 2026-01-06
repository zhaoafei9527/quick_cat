// 🐦 Flutter imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/widget/comic_topic_builder.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

class MineCollectPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  RxList<int> selectIds = <int>[].obs;
  RxBool editModel = false.obs;
  RxBool allSelect = false.obs;
  RxBool refreshTag = false.obs;
  List<String> tabList = ["动漫", "长视频", "短视频", "帖子"];
  List<MediaType> typeList = [
    MediaType.cartoon,
    MediaType.videoLong,
    MediaType.videoShort,
    MediaType.post
  ];
  RxMap<MediaType, List<MediaInfo>> currentMedias =
      <MediaType, List<MediaInfo>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabList.length, vsync: this);
  }

  void deleteCollectOfIds() async {
    MediaType type = typeList[tabController!.index];
    await ApiRes.delCollect(collectType: type, objectIds: selectIds);
    refreshTag.value = !refreshTag.value;
    selectIds.clear();
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
    if (allSelect.value) {
      selectIds.addAll((currentMedias[type] ?? []).map((e) => e.id ?? 0));
    }
    selectIds.refresh();
  }
}
