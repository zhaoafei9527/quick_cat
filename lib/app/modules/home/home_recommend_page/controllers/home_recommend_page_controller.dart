
// 📦 Package imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/model/home/config_model_model.dart';
import '../../../../data/enum.dart';

class HomeRecommendPageController extends GetxController
    with GetTickerProviderStateMixin {
  RxInt currentTabIndex = 0.obs;
  RxInt rankModel = 0.obs; // 默认热门排行
  TabController? tabController; // 首页主分类
  late TabController aiTabController; // AI二级分类
  // List<String> cateTopList = ["智能推送", "换脸", "脱衣", "生成"];
  List<MediaCategory> cateTopList = [];
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
    ShareKeys shareKeys = Get.find<ShareKeys>();
    cateTopList = shareKeys.hGameTypeList;
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
