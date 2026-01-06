import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/enum.dart';
import '../../../model/home/config_model_model.dart';

class AiRecommendPageController extends GetxController     with GetTickerProviderStateMixin {
  RxInt currentTabIndex = 0.obs;
  TabController? tabController; // 首页主分类
  late TabController aiTabController; // AI二级分类
  // List<String> cateTopList = ["智能推送", "换脸", "脱衣", "生成"];
  List<String> cateTopList = ["智能推送"];
  List<String> aiListStr = ["漫画", "动漫", "小说", "长视频", "短视频"];
  List<MediaCategory> aiTabList = [];
  List<MediaType> aiListType = [
    MediaType.comic,
    MediaType.cartoon,
    MediaType.novel,
    MediaType.videoLong,
    MediaType.videoShort,
  ];

  @override
  void onInit() async {
    super.onInit();
    for (int i = 0; i < aiListStr.length; i++) {
      aiTabList.add(MediaCategory(
          name: aiListStr[i],
          type: aiListType[i].index,
          showType: CategoryShowType.aiShowType));
    }

    tabController = TabController(length: cateTopList.length, vsync: this);
    tabController?.addListener(() {
      currentTabIndex.value = tabController!.index;
    });
    aiTabController = TabController(length: aiTabList.length, vsync: this);
  }

  void changeTabIndex(int index) {
    currentTabIndex.value = index;
    tabController?.animateTo(index);
  }

  @override
  void onClose() {
    // player.dispose();
    super.onClose();
  }
}
