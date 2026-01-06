// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/views/pull_refresh_view.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import '../../../../../utils/dimens.dart';
import '../../../../model/home/config_model_model.dart';
import '../../../../model/home/topic_list_model.dart';

class IndexRecommendController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  RxList<MediaCategory> categoryList = <MediaCategory>[].obs;

  int id = 0;
  var pageNum = 1.obs;
  var initTabIndex = 0.obs;
  RxBool initOk = false.obs;
  RxList<Advertise> adList = <Advertise>[].obs;
  var topicList = <TopicList>[].obs;
  RxBool isSingleModel = false.obs;
  RxBool scrollIsTop = true.obs;
  List<Advertise>? adsList;
  RxList<Advertise> gameAdList = <Advertise>[].obs;
  TabController? sortTabController;
  late ScrollController scrollController;
  RxList<MediaInfo> newUpdateList = <MediaInfo>[].obs;
  RxList<MediaInfo> mostWatchList = <MediaInfo>[].obs;
  RxList<MediaInfo> mostCommentList = <MediaInfo>[].obs;

  PullRefreshController pullRefreshController = PullRefreshController();

  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    categoryList.value = shareKeys.homeCategory;
    tabController = TabController(length: categoryList.length, vsync: this);

    // scrollController = ScrollController();
    // ShareKeys shareKeys = Get.find<ShareKeys>();
    // sortTabController =
    //     TabController(length: shareKeys.longMediaSortList.length, vsync: this);
    // adsList = await LocalAdsStore().where(AdsType.longVideoListAds) ?? [];
    // gameAdList.value =
    //     await LocalAdsStore().where(AdsType.homeGameIconAds) ?? [];

    // scrollController.addListener(() {
    //   // 检查滚动位置，适配滚动逻辑
    //
    //   if (scrollController.position.pixels >= Dimens.pt500) {
    //     scrollIsTop.value = false;
    //   }
    //   // if (scrollController.position.pixels <=
    //   //     scrollController.position.minScrollExtent) {
    //   //   // 滚动到顶部
    //   //   print("Header 已滚动到顶部");
    //   // }
    //   // scrollIsTop.value = false;
    //   // if (scrollController.position.pixels >=
    //   //     scrollController.position.maxScrollExtent) {
    //   //   // 滚动到底部
    //   //   print("Body 已滚动到底部");
    //   // }
    // });
  }

  @override
  void onReady() async {
    super.onReady();
    initOk.value = true;
    update();
  }

  Future<List<MediaInfo>> getTopicMediaData({pageNum, sort}) async {
    List<MediaInfo> list = [];
    var data = {"id": id, "pageNum": pageNum ?? 1, "sort": sort};
    MediaList? res = await ApiRes.getHomeCategoryMedia(data: data);
    if ((res?.mediaList ?? []).isNotEmpty) {
      if ((adsList ?? []).isNotEmpty) {
        int adsInt = Random().nextInt((adsList ?? []).length);
        MediaInfo adMedia = MediaInfo(
          isAds: true,
          adsId: adsList![adsInt].id,
          desc: adsList![adsInt].description,
          adsPath: adsList![adsInt].href,
          title: adsList![adsInt].title ?? "",
          videoUrl: adsList![adsInt].href,
          coverImg: adsList![adsInt].cover ?? "",
        );
        int mediaInt = Random().nextInt((res?.mediaList ?? []).length);
        (res?.mediaList ?? []).insert(mediaInt, adMedia);
      }
    }
    list = res?.mediaList ?? [];

    return list;
  }
}
