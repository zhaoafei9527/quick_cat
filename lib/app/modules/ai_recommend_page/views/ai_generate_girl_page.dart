import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/ai_generate_model.dart';
import 'package:quick_cat_client/app/model/cut_info.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ai_change_face_page.dart';

class AiGenerateGirlPage extends StatefulWidget {
  const AiGenerateGirlPage({super.key});

  @override
  State<AiGenerateGirlPage> createState() => _AiGenerateGirlPageState();
}

class _AiGenerateGirlPageState extends State<AiGenerateGirlPage> {
  String localPath = "";
  String imageUrl = "";
  int pageNum = 1;
  bool uploadComplete = false;
  AiCateGoryInfo? aiCateGoryInfo;
  List<AiCateGoryInfo>? tagGroupList;
  TextEditingController textController = TextEditingController();
  Map<int, String> tagMapList = {};

  @override
  void initState() {
    super.initState();
    onInitData();
    getTagListNetData();
  }

  Future<void> onInitData() async {
    if (aiCateGoryInfo == null) {
      int type = AiTaskType.aiGenerateGirl.index;
      AiCateGoryInfo? model = await ApiRes.getAiCategoryInfo(aiType: type);
      if (model != null) {
        setState(() => aiCateGoryInfo = model);
      }
    }
  }

  Future<void> getTagListNetData() async {
    AiTagStringList? model = await ApiRes.getAiTagList(pageNum: pageNum);
    if (model != null) {
      setState(() {
        tagGroupList = model.list;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ImageLoader.withP(aiCateGoryInfo?.pic ?? "",
              width: screen.screenWidth, height: Dimens.pt330)
          .load(),
      SizedBox(height: Dimens.pt30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        buildGenerateButton("AI生成记录", onTap: () {
          // Get.toNamed(Routes.AI_CHANGE_FACE_RECORD);
        })
      ]),
      SizedBox(height: Dimens.pt40),
      buildLabelText("热门作品展示"),
      SizedBox(height: Dimens.pt17),
      SizedBox(
          height: Dimens.pt480,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: Dimens.pt25),
              itemBuilder: (context, index) => ImageLoader.withP(
                      aiCateGoryInfo?.effectImgs?[index] ?? "",
                      width: Dimens.pt330,
                      height: Dimens.pt480)
                  .load(),
              separatorBuilder: (context, index) => SizedBox(width: Dimens.pt8),
              itemCount: (aiCateGoryInfo?.effectImgs ?? []).length)),
      SizedBox(height: Dimens.pt30),
      buildLabelText("作品描述"),
      SizedBox(height: Dimens.pt25),
      buildTextInputView(textController),
      ...List.generate(
          tagGroupList?.length ?? 0,
          (index) => buildTagGroupView(tagGroupList?[index], index,
              onGroupChange: (bool show) => setState(() {
                    tagGroupList?[index].showGroup = show;
                  }),
              chooseList: tagMapList,
              onTap: (int index, AiTagList tag) {
                setState(() {
                  tagMapList[index] = tag.tagStr ?? "";
                });
              }))
    ]));
  }
}

Widget buildTextInputView(TextEditingController textController) {
  ThemeManager theme = Get.find<ThemeManager>();
  return Container(
    width: screen.screenWidth,
    height: Dimens.pt200,
    color: theme.getColor(ThemeColor.bgGrey),
    margin: EdgeInsets.symmetric(horizontal: Dimens.pt25),
    padding: EdgeInsets.all(Dimens.pt20),
    child: buildTextInput(textController,
        keyboardType: TextInputType.text,
        maxLength: 400,
        height: Dimens.pt200,
        contentPadding: EdgeInsets.zero,
        fontSize: Dimens.pt22,
        maxLines: 10,
        hintColor: theme.getColor(ThemeColor.textGrey),
        hintText: "描述您想要生成的作品，越详细越好！"),
  );
}

Widget buildLabelText(String text,
    {Color? color, double? fontSize, double? padding, FontWeight? fontWeight}) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? Dimens.pt25),
      child: Text(text,
          style: TextStyle(
              color: color ?? Colors.white,
              fontSize: fontSize ?? Dimens.pt38,
              fontWeight: fontWeight ?? FontWeight.normal)));
}

Widget buildTagGroupView(AiCateGoryInfo? groupInfo, int index,
    {Function(int, AiTagList)? onTap,
    Function(bool)? onGroupChange,
    Map<int, String> chooseList = const {}}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return Column(children: [
    Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: Row(children: [
          Text(groupInfo?.title ?? "",
              style: TextStyle(
                  color: theme.getColor(ThemeColor.primary),
                  fontSize: Dimens.pt38,
                  height: 1.5)),
          Spacer(),
          IconButton(
              onPressed: () =>
                  onGroupChange?.call(!(groupInfo?.showGroup ?? false)),
              icon: Icon(
                  (groupInfo?.showGroup ?? false)
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: theme.getColor(ThemeColor.primary)))
        ])),
    (groupInfo?.showGroup ?? false)
        ? Wrap(
            spacing: Dimens.pt12,
            runSpacing: Dimens.pt25,
            children: (groupInfo?.tagList ?? []).map((tag) {
              bool choose = chooseList.keys.contains(index) &&
                  chooseList[index] == tag.tagStr;
              return GestureDetector(
                  onTap: () => onTap?.call(index, tag),
                  child: Container(
                      width: Dimens.pt166,
                      height: Dimens.pt62,
                      alignment: Alignment.center,
                      color: theme.getColor(
                          choose ? ThemeColor.textYellow : ThemeColor.bgGrey),
                      child: Text(tag.tagStr ?? "",
                          style: TextStyle(
                              color: theme.getColor(
                                  choose ? ThemeColor.bg : ThemeColor.textGrey),
                              fontSize: Dimens.pt24))));
            }).toList())
        : SizedBox()
  ]);
}
