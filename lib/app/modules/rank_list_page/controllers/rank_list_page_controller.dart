import 'package:acgn_client/app/data/enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankListPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  List<MapEntry<MediaType, String>> cateList = [];
  RxInt sortIndex = 0.obs;
  List<String> sortList = ["日榜", "周榜", "月榜"];
  late TabController tabController;

  @override
  void onInit() {
    cateList = [
      MapEntry(MediaType.comic, "漫画榜"),
      MapEntry(MediaType.cartoon, "动漫榜"),
      MapEntry(MediaType.novel, "小说榜"),
      MapEntry(MediaType.videoLong, "长视频榜"),
      MapEntry(MediaType.videoShort, "短视频榜"),
    ];
    super.onInit();
    tabController = TabController(length: cateList.length, vsync: this);
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
