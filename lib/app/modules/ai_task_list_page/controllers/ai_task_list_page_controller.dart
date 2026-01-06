import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/utils/text_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiTaskListPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  List<String> tabList = ["换脸", "脱衣", "生成"];
  int initIndex = 0;
  RxInt aiTaskSortIndex = 0.obs;
  List<AiTaskType> aiTaskTypeList = [
    AiTaskType.aiChangeFace,
    AiTaskType.aiOffClothes,
    AiTaskType.aiGenerateGirl
  ];
  List<String> sortList = ["全部", "已成功", "排队中", "生成中", "已失败"];

  List<AiTaskStatus?> aiTaskStatusList = [
    null,
    AiTaskStatus.aiTaskDone,
    AiTaskStatus.aiTaskWaiting,
    AiTaskStatus.aiTaskDoing,
    AiTaskStatus.aiTaskFailed
  ];

  @override
  void onInit() async {
    initIndex = TextUtil.getIntArgument("initIndex");
    tabController = TabController(
        length: tabList.length, vsync: this, initialIndex: initIndex);
    super.onInit();
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
