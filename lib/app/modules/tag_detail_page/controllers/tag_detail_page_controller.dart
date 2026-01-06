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
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/conf/api_res.dart';

class TagDetailPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? sortTabController;
  List<String> tabList = ["最新更新", "最高人气"];
  int tagId = 0;
  String title = "";
  bool isAuthor = false; // 是否作者专题
  String author = ""; //作者名称
  bool backResultMark = false; // 是否返回播放器标志
  MediaType mediaType = MediaType.comic; // 默认漫画专题
  CoverType coverType = CoverType.coverVertical; // 默认竖版封面

  @override
  void onInit() async {
    super.onInit();
    try {
      tagId = TextUtil.getIntArgument("id");
      mediaType = MediaType.values[TextUtil.getIntArgument("mediaType")];
      backResultMark = Get.arguments?['backResultMark'] ?? false;
      if (mediaType == MediaType.comic || mediaType == MediaType.novel) {
        tabList.add("最多收藏");
      } else {
        tabList.add("最多评论");
      }
      title = Get.arguments?['title'] ?? "";
      isAuthor = Get.arguments?['isAuthor'] ?? false;
      if (isAuthor) {
        author = Get.arguments?['author'] ?? "";
        title = author;
      }
      coverType = CoverType.values[TextUtil.getIntArgument("coverType")];
      sortTabController = TabController(length: tabList.length, vsync: this);
    } catch (e) {
      Get.log("$e");
    }
  }

  Future<List<MediaInfo>?> dataGetter(int pageNum,int sortIndex) async {
    if (isAuthor) {
      MediaList? medias = await ApiRes.getComicsOfAuthorName(
          author: author, pageNum: pageNum);
      return medias?.list ?? [];
    } else {
      List<MediaInfo> media = await dataGetterFunction(
          pageNum: pageNum, sortType: sortIndex);
      return media;
    }
  }

  // 根据分类获取专题详情
  Future<List<MediaInfo>> dataGetterFunction(
      {int? pageNum, int? sortType}) async {
    List<MediaInfo> mediaList = [];

    String apiPath = "";
    if (mediaType == MediaType.comic) {
      apiPath = "comicsTag/listById";
    } else if (mediaType == MediaType.novel) {
      apiPath = "novelTag/listByTag";
    } else {
      apiPath = "media/tag/details";
    }

    MediaList? model = await ApiRes.getTopicDetailList(
        id: tagId,
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
