import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/dialog/image_viewer.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/r.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../conf/api_res.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/screen.dart';
import '../../../model/ai_generate_model.dart';
import '../../../views/page_pull_view.dart';
import '../controllers/ai_task_list_page_controller.dart';

class AiTaskListPageView extends GetView<AiTaskListPageController> {
  const AiTaskListPageView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<AiTaskListPageController>(
        builder: (AiTaskListPageController logic) {
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("我的AI情色"),
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: Dimens.pt25),
            buildCommonTabBar(
                controller: logic.tabController,
                insets: Dimens.pt38,
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
                tabs: logic.tabList.map((e) => Text(e)).toList()),
            SizedBox(height: Dimens.pt30),
            Expanded(
                child: TabBarView(
                    controller: logic.tabController,
                    children: List.generate(logic.tabList.length, (index) {
                      return buildAiTaskListView(index);
                    }))),
          ]));
    });
  }

  Widget buildAiTaskListView(int index) {
    ThemeManager theme = Get.find<ThemeManager>();
    AiTaskListPageController logic = Get.find<AiTaskListPageController>();
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: Column(children: [
          // 状态排序筛选
          SizedBox(
              height: Dimens.pt50,
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () => logic.aiTaskSortIndex.value = index,
                        child: Text(logic.sortList[index],
                            style: TextStyle(
                                color: theme.getColor(
                                    logic.aiTaskSortIndex.value == index
                                        ? ThemeColor.primary
                                        : ThemeColor.textGrey),
                                fontSize: Dimens.pt26)));
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(width: Dimens.pt25),
                  itemCount: logic.sortList.length,
                  scrollDirection: Axis.horizontal)),

          SizedBox(height: Dimens.pt20),
          // AI任务列表
          Expanded(
              child: PagePullView<AiTaskRequestModel>(
                  key: Key("pullKey_$index${logic.aiTaskSortIndex.value}"),
                  dataGetter: (int pageNum, int size) async {
                    AiTaskListRespModel? model = await ApiRes.getAiTaskList(
                        pageNum: pageNum,
                        aiType: logic.aiTaskTypeList[index],
                        status: logic
                            .aiTaskStatusList[logic.aiTaskSortIndex.value]);
                    return model?.list ?? [];
                  },
                  emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
                  widgetBuilder: (BuildContext context, List<dynamic> list,
                      Widget? child) {
                    return ListView.separated(
                        itemBuilder: (context, index) {
                          List<AiTaskRequestModel> taskList =
                              list.cast<AiTaskRequestModel>();
                          return buildAiTaskItem(taskList[index], onTap: () {});
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: Dimens.pt30),
                        itemCount: list.length);
                  }))
        ]));
  }

  Widget buildAiTaskItem(AiTaskRequestModel? model, {Function()? onTap}) {
    ThemeManager theme = Get.find<ThemeManager>();
    AiTaskType aiType = model?.aiType ?? AiTaskType.aiOffClothes;
    AiTaskStatus taskStatus = model?.taskStatus ?? AiTaskStatus.aiTaskWaiting;
    String statusName = "排队中";
    Color statusColor = theme.getColor(ThemeColor.primary);

    if (taskStatus == AiTaskStatus.aiTaskWaiting) {
      statusName = "排队中";
      statusColor = theme.getColor(ThemeColor.primary);
    } else if (taskStatus == AiTaskStatus.aiTaskDoing) {
      statusName = "生成中";
      statusColor = theme.getColor(ThemeColor.primary);
    } else if (taskStatus == AiTaskStatus.aiTaskFailed) {
      statusName = "已失败";
      statusColor = theme.getColor(ThemeColor.red);
    } else if (taskStatus == AiTaskStatus.aiTaskDone) {
      statusName = "已成功";
      statusColor = theme.getColor(ThemeColor.textYellow);
    }

    return Container(
        width: screen.screenWidth,
        height: Dimens.pt426,
        color: theme.getColor(ThemeColor.bgGrey),
        padding: EdgeInsets.symmetric(
            horizontal: Dimens.pt18, vertical: Dimens.pt28),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (aiType == AiTaskType.aiChangeFace)
              buildImageContainer(model?.stencilPic ?? '', label: "模版"),
            if (aiType == AiTaskType.aiOffClothes ||
                aiType == AiTaskType.aiChangeFace)
              buildImageContainer(model?.image ?? '', label: "原图"),
            buildImageContainer(model?.aiImages?[0] ?? '', status: taskStatus)
          ]),
          SizedBox(height: Dimens.pt25),
          getHengLine(color: Color(0XFF1F1F1F), h: Dimens.pt1),
          SizedBox(height: Dimens.pt25),
          Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
                width: Dimens.pt138,
                height: Dimens.pt56,
                alignment: Alignment.center,
                color: theme.getColor(ThemeColor.textGrey),
                child: Text(statusName,
                    style:
                        TextStyle(color: statusColor, fontSize: Dimens.pt26))),
            if (taskStatus == AiTaskStatus.aiTaskDone) ...[
              SizedBox(width: Dimens.pt140),
              Container(
                  width: Dimens.pt112,
                  height: Dimens.pt56,
                  alignment: Alignment.center,
                  color: theme.getColor(ThemeColor.textYellow),
                  child: Text("下载",
                      style: TextStyle(
                          fontSize: Dimens.pt26,
                          color: theme.getColor(ThemeColor.bg))))
            ],
            Spacer(),
            Image.asset(R.assetsImgIconImageDelete,
                width: Dimens.pt40, height: Dimens.pt40)
          ]))
        ]));
  }
}

Widget buildImageContainer(String imagePath,
    {String? label, AiTaskStatus? status}) {
  ThemeManager theme = Get.find<ThemeManager>();
  String statusName = "";
  if (status == AiTaskStatus.aiTaskWaiting) {
    statusName = "排队中";
  } else if (status == AiTaskStatus.aiTaskDoing) {
    statusName = "生成中";
  } else if (status == AiTaskStatus.aiTaskFailed) {
    statusName = "已失败";
  }

  return GestureDetector(
    onTap: () => showImageViewerDialog(Get.context!,
        images: [imagePath], showNum: false),
    child: Stack(alignment: Alignment.bottomRight, children: [
      ImageLoader.withP(imagePath, width: Dimens.pt185, height: Dimens.pt270)
          .load(),
      if (label != null)
        Container(
            width: Dimens.pt84,
            height: Dimens.pt60,
            alignment: Alignment.center,
            color: theme.getColor(ThemeColor.bg).withOpacity(.5),
            child: Text(label,
                style: TextStyle(color: Colors.white, fontSize: Dimens.pt22))),
      if (statusName.isNotEmpty)
        Container(
            width: Dimens.pt185,
            height: Dimens.pt270,
            alignment: Alignment.center,
            color: theme.getColor(ThemeColor.bg).withOpacity(.5),
            child: Text(statusName,
                style: TextStyle(
                    color: theme.getColor(ThemeColor.textYellow),
                    fontSize: Dimens.pt22))),
    ]),
  );
}
