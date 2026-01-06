import 'dart:io';

import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/ai_generate_model.dart';
import 'package:quick_cat_client/app/model/cut_info.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/tasks/image_uploader_task.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ai_change_face_page.dart';

class AiOffClothesPage extends StatefulWidget {
  const AiOffClothesPage({super.key});

  @override
  State<AiOffClothesPage> createState() => _AiOffClothesPageState();
}

class _AiOffClothesPageState extends State<AiOffClothesPage> {
  String localPath = "";
  String imageUrl = "";
  bool uploadComplete = false;
  AiCateGoryInfo? aiCateGoryInfo;
  final ImageUploadTask _uploadTask = ImageUploadTask();

  @override
  void initState() {
    super.initState();
    onInitData();
  }

  @override
  void dispose() {
    onInitData();
    _uploadTask.dispose();
    super.dispose();
  }

  Future<void> onInitData() async {
    if (aiCateGoryInfo == null) {
      int type = AiTaskType.aiOffClothes.index;
      AiCateGoryInfo? model = await ApiRes.getAiCategoryInfo(aiType: type);
      if (model != null) {
        setState(() => aiCateGoryInfo = model);
      }
    }
  }

  void onUploadImage() async {
    uploadComplete = false;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    if (!((shareKeys.userInfo.vipType ?? 0) > 0)) {
      UploadImageRep? rep = await AppUtils.uploadSingleImage(
          onLocalPath: (String path) => setState(() => localPath = path));
      if (rep != null && rep.path != null) {
        setState(() {
          uploadComplete = true;
          imageUrl = rep.path!;
        });
      }
    } else {
      showPlayerCommonDialog(Get.context!,
          title: "友情提示",
          content: "该功能仅会员用户可使用,请先获得会员！",
          btnList: ["获得会员", "忍住不脱"],
          btnCall: [
            () => Get.toNamed(Routes.VIP_CENTER_PAGE),
            () => Get.back()
          ],
          btnActionIndex: 0);
    }
  }

  void startAddTask() async {
    AiTaskRequestModel args = AiTaskRequestModel(
      aiType: AiTaskType.aiOffClothes,
      image: imageUrl,
      price: aiCateGoryInfo?.price ?? 0,
      taskStatus: AiTaskStatus.aiTaskWaiting,
    );
    await ApiRes.addAiTaskToGenerate(aiTaskReq: args);
    setState(() {
      localPath = "";
      imageUrl = "";
      uploadComplete = false;
    });
    Get.back();
    showTypeToast(msg: "任务已添加到生成队列，请到脱衣记录中查看", toastType: ToastType.SUCCESS);
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ImageLoader.withP(aiCateGoryInfo?.pic ?? "",
              width: screen.screenWidth, height: Dimens.pt330)
          .load(),
      SizedBox(height: Dimens.pt40),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        buildGenerateButton("AI脱衣记录", onTap: () {
          Get.toNamed(Routes.AI_TASK_LIST_PAGE, arguments: {"initIndex": 1});
        })
      ]),
      SizedBox(height: Dimens.pt30),
      buildUploadButton("脱衣",
          localPath: localPath,
          uploadComplete: uploadComplete,
          onClearImage: () => setState(() => localPath = ""),
          onTap: onUploadImage),
      SizedBox(height: Dimens.pt30),
      buildStartGenerateButton(aiCateGoryInfo?.price,
          imageUrl: imageUrl, onTap: startAddTask, needImage: true),
      SizedBox(height: Dimens.pt40),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: Text(
              "注意事项：\n1.素材仅供AI使用，绝无外泄风险，请放心使用\n"
              "2.素材需尽量清晰\n3.本功能不支持多人图片\n"
              "4.上传图片需间隔60秒\n5.禁止使用未成年图片",
              style: TextStyle(
                  fontSize: Dimens.pt24,
                  color: theme.getColor(ThemeColor.textGrey)))),
      SizedBox(height: Dimens.pt40),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: Text("效果图展示",
              style: TextStyle(
                  fontSize: Dimens.pt38,
                  color: theme.getColor(ThemeColor.primary)))),
      SizedBox(height: Dimens.pt30),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child: ImageLoader.withP(
                  "hex/image/1c/29/64f/3d/bc21cf72ca59d8164f0dffb29f853dd4.png",
                  width: screen.screenWidth)
              .load())
    ]));
  }
}

Widget buildStartGenerateButton(int? price,
    {Function()? onTap,
    int? freeTime,
    double? padding,
    String? imageUrl,
    bool? needImage}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return GestureDetector(
      onTap: () => startGenerateImage(
          onTap: onTap,
          imageUrl: imageUrl,
          price: price,
          needImage: needImage ?? true),
      child: Container(
          width: screen.screenWidth,
          height: Dimens.pt80,
          margin: EdgeInsets.symmetric(horizontal: padding ?? Dimens.pt25),
          color: theme.getColor(ThemeColor.textYellow),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("立即生成",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.getColor(ThemeColor.bg),
                    fontSize: Dimens.pt26))
          ])));
}

Widget buildUploadButton(String name,
    {Function()? onTap,
    bool uploadComplete = true,
    String localPath = "",
    double? padding,
    Function? onClearImage}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return GestureDetector(
      onTap: onTap,
      child: Stack(alignment: Alignment.topRight, children: [
        Container(
            width: screen.screenWidth,
            height: Dimens.pt290,
            margin: EdgeInsets.symmetric(horizontal: padding ?? Dimens.pt25),
            color: theme.getColor(ThemeColor.bgGrey),
            child: localPath.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Image.asset(R.assetsImgIconDefualtImage,
                            width: Dimens.pt50, height: Dimens.pt50),
                        SizedBox(height: Dimens.pt10),
                        Text.rich(
                            TextSpan(text: "请选择您要", children: [
                              TextSpan(
                                  text: name,
                                  style: TextStyle(
                                      fontSize: Dimens.pt24,
                                      color: theme
                                          .getColor(ThemeColor.textYellow))),
                              TextSpan(text: "的素材"),
                            ]),
                            style: TextStyle(
                                fontSize: Dimens.pt22,
                                color: theme.getColor(ThemeColor.textGrey)))
                      ])
                : Center(
                    child: Image.file(File(localPath),
                        height: Dimens.pt290, fit: BoxFit.cover))),
        if (localPath.isNotEmpty && !uploadComplete)
          Positioned(
              bottom: 0,
              child: Container(
                  width: screen.screenWidth,
                  height: Dimens.pt290,
                  color: theme.getColor(ThemeColor.bg).withOpacity(.7))),
        if (localPath.isNotEmpty)
          GestureDetector(
              onTap: () => onClearImage?.call(),
              child: Padding(
                  padding: EdgeInsets.all(Dimens.pt10),
                  child: Image.asset(R.assetsImgIconImageDelete,
                      width: Dimens.pt40)))
      ]));
}

Future<void> startGenerateImage(
    {Function()? onTap,
    String? imageUrl,
    int? price,
    bool needImage = true}) async {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  double realPrice = (price ?? 0) / 100;
  double balance = double.tryParse(shareKeys.userBalance.value) ?? .0;

  if (needImage == true && (imageUrl == null || imageUrl.isEmpty)) {
    showTypeToast(msg: '请先上传需要生成的图片');
    return;
  }
  String buttonText = balance >= realPrice ? "确定解锁" : "前往充值";
  String context = balance >= realPrice
      ? "生成AI图片需要消耗$realPrice 金币，是否继续？"
      : "您的金币余额不足，无法生成AI图片，请前往充值！";
  showPlayerCommonDialog(Get.context!,
      title: "友情提示",
      content: context,
      btnList: [buttonText, "忍着不用"],
      btnCall: [onTap, () => Get.back()],
      btnActionIndex: 0);
}
