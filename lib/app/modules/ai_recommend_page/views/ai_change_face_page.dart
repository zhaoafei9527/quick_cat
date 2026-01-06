import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/ai_generate_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiChangeFacePage extends StatefulWidget {
  const AiChangeFacePage({super.key});

  @override
  State<AiChangeFacePage> createState() => _AiChangeFacePageState();
}

class _AiChangeFacePageState extends State<AiChangeFacePage>
    with SingleTickerProviderStateMixin {
  AiCateGoryInfo? aiCateGoryInfo;
  bool isLoading = true;
  List<ChangeFaceImages> changeFaceImages = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    onInitData();
  }

  Future<void> onInitData() async {
    if (aiCateGoryInfo == null) {
      setState(() => isLoading = true);
      int type = AiTaskType.aiChangeFace.index;
      AiCateGoryInfo? model = await ApiRes.getAiCategoryInfo(aiType: type);
      if (model != null) {
        setState(() {
          isLoading = false;
          aiCateGoryInfo = model;
          changeFaceImages = model.changList ?? [];
        });
      }
      _tabController ??=
          TabController(length: changeFaceImages.length, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? NestedScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (_, __) => [
                  headerSliverBuilder(),
                ],
            body: TabBarView(
                controller: _tabController,
                children: changeFaceImages.map((e) {
                  return GridView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, //横向数量
                          crossAxisSpacing: Dimens.pt12,
                          mainAxisSpacing: Dimens.pt12,
                          childAspectRatio: 345 / 504),
                      itemCount: e.AIImgs?.length ?? 0,
                      itemBuilder: (c, index) {
                        return GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.AI_CHANGE_FACE_PAGE,
                                  arguments: {
                                    "price": e.AIImgs?[index].price ?? 0,
                                    "desc": aiCateGoryInfo?.desc ?? "",
                                    "faceImageUrl": e.AIImgs?[index].img ?? "",
                                  });
                            },
                            child:
                                Stack(alignment: Alignment.topRight, children: [
                              ImageLoader.withP(e.AIImgs?[index].img ?? "",
                                      width: Dimens.pt345, height: Dimens.pt504)
                                  .load(),
                              Positioned(
                                right: Dimens.pt40,
                                child: buildPayTypeWidget(
                                    PaymentType.coinPaymentType,
                                    price: e.AIImgs?[index].price ?? 0,
                                    width: Dimens.pt58,
                                    height: Dimens.pt32),
                              )
                            ]));
                      });
                }).toList()))
        : getLoadingWidget();
  }

  Widget headerSliverBuilder() {
    return SliverToBoxAdapter(
        child: Column(children: [
      ImageLoader.withP(aiCateGoryInfo?.pic ?? "", width: screen.screenWidth)
          .load(),
      SizedBox(height: Dimens.pt40),
      buildGenerateButton("AI换脸记录", onTap: () {
        onInitData();
        Get.toNamed(Routes.AI_TASK_LIST_PAGE, arguments: {"initIndex": 0});
      }),
      SizedBox(height: Dimens.pt30),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
          child: buildCommonTabBar(
              controller: _tabController,
              insets: Dimens.pt38,
              tabs: changeFaceImages.map((e) => Text(e.title ?? "")).toList())),
      SizedBox(height: Dimens.pt30)
    ]));
  }
}

Widget buildGenerateButton(String name, {Function()? onTap}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: Dimens.pt40, vertical: Dimens.pt20),
          color: theme.getColor(ThemeColor.primary),
          child: Text(name,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.getColor(ThemeColor.bg),
                  fontSize: Dimens.pt26))));
}
