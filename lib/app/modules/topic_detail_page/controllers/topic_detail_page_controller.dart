// 🐦 Flutter imports:
import 'dart:math';

import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/utils/common_util.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/conf/api_res.dart';
import '../../../model/home/topic_list_model.dart';

class TopicDetailPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? sortTabController;
  List<String> tabList = ["最新上架", "最多观看", "最多喜欢"];
  int topicId = 0;
  bool showRank = false;
  String title = "";
  MediaType mediaType = MediaType.comic; // 默认漫画专题
  CoverType coverType = CoverType.coverVertical; // 默认竖版封面

  @override
  void onInit() {
    super.onInit();
    try {
      topicId = TextUtil.getIntArgument("topicId");
      showRank = Get.arguments["showRank"] ?? false;
      mediaType = MediaType.values[TextUtil.getIntArgument("mediaType")];
      // if (mediaType == MediaType.comic || mediaType == MediaType.novel) {
      //   tabList.add("最多收藏");
      // } else {
      //   tabList.add("最多评论");
      // }
      title = Get.arguments?['title'] ?? "";
      coverType = CoverType.values[TextUtil.getIntArgument("coverType")];
      sortTabController = TabController(length: tabList.length, vsync: this);
    } catch (e) {
      Get.log("$e");
    }
  }

  // 根据分类获取专题详情
  Future<List<MediaInfo>> dataGetterFunction(
      {int? pageNum, int? sortType}) async {
    List<MediaInfo> mediaList = [];
    String apiPath = "";
    if (mediaType == MediaType.comic) {
      apiPath = "comicsTopic/list";
    } else if (mediaType == MediaType.novel) {
      apiPath = "novelTopic/list";
    } else {
      apiPath = "mediatopic/getTopicById";
    }

    MediaList? model = await ApiRes.getTopicDetailList(
        id: topicId,
        pageNum: pageNum ?? 1,
        sort: sortType ?? 1,
        mediaType: mediaType,
        apiPath: apiPath);
    if (model != null) {
      MediaInfo? adMedia;
      if (mediaType == MediaType.comic || mediaType == MediaType.novel) {
        mediaList = model.list ?? [];
      } else {
        mediaList = model.mediaList ?? [];
      }
      // 获取不同尺寸广告
      if (mediaType == MediaType.videoLong || mediaType == MediaType.darkWeb) {
        adMedia = await getAdsMediaInfo(AdsType.longVideoListAds);
      } else {
        adMedia = await getAdsMediaInfo(AdsType.shortVideoListAds);
      }
      if (adMedia != null) {
        mediaList.insert(mediaList.length, adMedia);
      }
    }

    return mediaList;
  }
}
