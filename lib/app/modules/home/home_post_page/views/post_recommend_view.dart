// 🐦 Flutter imports:
import 'dart:math';

import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import 'package:quick_cat_client/app/model/post_list_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/r.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/views/pull_refresh_view.dart';
import 'package:quick_cat_client/app/widget/post_item.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/common_util.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../../../../../utils/dimens.dart';
import '../../../../data/ads_type.dart';
import '../../../../model/home/config_model_model.dart';
import '../../../../widget/cover_banner.dart';

class PostRecommendView extends StatefulWidget {
  final int id;

  const PostRecommendView({required this.id, super.key});

  @override
  State<PostRecommendView> createState() => _PostRecommendViewState();
}

class _PostRecommendViewState extends State<PostRecommendView> {
  PullRefreshController pullRefreshController = PullRefreshController();
  List<PostBrief> postList = <PostBrief>[];
  Advertise? gameAds = Advertise();
  int sort = 0, pageNum = 1;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    postList = [];
    List<PostBrief> model = await _getNetData(pageNum: 1);
    if (model.isNotEmpty) {
      postList.assignAll(model);
    } else {
      pageNum = 1;
    }

    pullRefreshController.requestSuccess(
        isFirstPage: true, isEmpty: model.isEmpty);
    setState(() {});
  }

  void loadMoreData() async {
    var page = pageNum += 1;
    List<PostBrief> model = await _getNetData(pageNum: page);
    if (model.isNotEmpty) {
      pageNum = page;
      postList.addAll((model));

      pullRefreshController.requestSuccess(
          isFirstPage: false, hasMore: (model).length >= 10);
    } else {
      pullRefreshController.requestFail(isFirstPage: false);
    }
    setState(() {});
  }

  Future<List<PostBrief>> _getNetData({int? pageNum}) async {
    List<PostBrief> mediaList = [];
    if (widget.id > 0) {
      PostBrief? adPost;
      PostBriefResp? model = await ApiRes.getPostList(
          data: {"id": widget.id, "pageNum": pageNum, "sort": sort});
      mediaList = model?.list ?? [];
      adPost = await getAdsPostInfo(AdsType.melonListAds);
      if (adPost != null) {
        int insertIndex = Random().nextInt(mediaList.length + 1);
        mediaList.insert(insertIndex, adPost);
      }
    }
    return mediaList;
  }

  @override
  Widget build(BuildContext context) {
    return PullRefreshView(
        controller: pullRefreshController,
        onLoading: () => loadMoreData(),
        onRefresh: () => loadData(),
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
              //广告communitySwiperAds
              child: CoverBanner(
                  aspectRatio: 750 / 198,
                  adsType: AdsType.homeSwiperAds,
                  onItemClick: (Advertise model) {
                    AppPages.jumpRouter(path: model.href, id: model.id);
                  })),
          SliverToBoxAdapter(child: SizedBox(height: Dimens.pt25)),
          SliverToBoxAdapter(child: buildRecommendGameView()),
          SliverToBoxAdapter(child: SizedBox(height: Dimens.pt50)),
          SliverList(
              delegate: SliverChildBuilderDelegate((c, index) {
            return PostItem(postBrief: postList[index], categoryId: widget.id);
          }, childCount: postList.length))
        ]));
  }
}

Future<List<Advertise>?> getRecommendGames() async {
  return await LocalAdsStore().where(AdsType.homeGameIconAds) ?? [];
}

Widget buildRecommendGameView({bool? showHotGame}) {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  return Column(children: [
    if (showHotGame ?? true) ...[
      Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
          child: Row(children: [
            Image.asset(R.assetsImgIconHomeGame,
                width: Dimens.pt28, height: Dimens.pt28),
            SizedBox(width: Dimens.pt10),
            Text("游戏",
                style: TextStyle(
                    fontSize: Dimens.pt32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            Spacer(),
            GestureDetector(
                onTap: () => AppUtils.jumpToHome(index: 2),
                child: Row(children: [
                  Text("更多游戏",
                      style: TextStyle(
                          fontSize: Dimens.pt24,
                          color: const Color(0xFFA3A3A7))),
                  SizedBox(width: Dimens.pt5),
                  Image.asset(R.assetsImgIconArrowRight,
                      width: Dimens.pt20,
                      height: Dimens.pt20,
                      color: Colors.white)
                ]))
          ])),
      SizedBox(height: Dimens.pt25),
      FutureBuilder(
          future: getRecommendGames(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return SizedBox.shrink();
            }
            List<Advertise>? data = snapshot.data;
            return SizedBox(
                height: Dimens.pt210,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: Dimens.pt30),
                    itemBuilder: (c, i) {
                      return GestureDetector(
                          onTap: () {
                            AppPages.jumpRouter(path: data?[i].href);
                          },
                          child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                ImageLoader.withP(data?[i].cover ?? "",
                                        width: Dimens.pt180,
                                        height: Dimens.pt210,
                                        radius: Dimens.pt8)
                                    .load()
                              ]));
                    },
                    separatorBuilder: (c, i) => SizedBox(width: Dimens.pt10),
                    itemCount: data?.length ?? 0));
          }),
      SizedBox(height: Dimens.pt10)
    ],
    Container(
        width: screen.screenWidth,
        height: Dimens.pt84,
        color: Color(0xFF232323).withOpacity(.6),
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        margin: EdgeInsets.symmetric(
            horizontal: (showHotGame ?? true) ? Dimens.pt30 : 0),
        child: Row(children: [
          Image.asset(R.assetsImgTextHomeBalance, height: Dimens.pt46),
          SizedBox(width: Dimens.pt15),
          Obx(() => Text("¥${shareKeys.userBalance.value}",
              style: TextStyle(
                  fontSize: Dimens.pt38,
                  color: Color(0xFFFFDB9E),
                  fontWeight: FontWeight.w500))),
          SizedBox(width: Dimens.pt10),
          GestureDetector(
              onTap: () async {
                await shareKeys.getUserBalance();
                shareKeys.balanceRefreshTurns.value += 1;
              },
              child: Obx(() => AnimatedRotation(
                  turns: shareKeys.balanceRefreshTurns.value,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.refresh,
                      size: Dimens.pt35, color: const Color(0xFFADB5BD))))),
          Spacer(),
          GestureDetector(
            onTap: () async {
              await ApiRes.oneClickScore(onSuccess: () {
                showTypeToast(msg: "取回下分成功", toastType: ToastType.SUCCESS);
              }, onError: (msg) {
                showTypeToast(msg: "取回下分失败：$msg", toastType: ToastType.Error);
              });
              await shareKeys.getUserBalance();
            },
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimens.pt20, vertical: Dimens.pt8),
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFDB9E)),
                    borderRadius: BorderRadius.circular(Dimens.pt12)),
                child: Text("一键取回",
                    style: TextStyle(
                        fontSize: Dimens.pt26,
                        color: const Color(0xFFFFDB9E),
                        fontWeight: FontWeight.w500))),
          )
        ])),
    SizedBox(height: Dimens.pt30),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
          onTap: () => Get.toNamed(Routes.VIP_CENTER_PAGE),
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
                width: Dimens.pt225,
                height: Dimens.pt55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0xFF121212),
                    border: Border.all(color: const Color(0xFFFFDB9E)),
                    borderRadius: BorderRadius.circular(Dimens.pt12)),
                child: Text("充值",
                    style: TextStyle(
                        fontSize: Dimens.pt30,
                        color: const Color(0xFFFFDB9E)))),
            Positioned(
                right: -Dimens.pt20,
                top: -Dimens.pt15,
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimens.pt15, vertical: Dimens.pt5),
                    decoration: BoxDecoration(
                        color: AppColors.mainRed,
                        borderRadius: BorderRadius.circular(Dimens.pt8)),
                    child: Text("送VIP",
                        style: TextStyle(
                            fontSize: Dimens.pt20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500))))
          ])),
      SizedBox(width: Dimens.pt50),
      GestureDetector(
          onTap: () {
            UserInfo userInfo = Get.find<ShareKeys>().userInfo;
            if (userInfo.mobile == null || userInfo.mobile?.isEmpty == true) {
              showPlayerCommonDialog(Get.context!,
                  title: "温情提示",
                  content:
                      "当前为游客账号,为避免账号丢失,请绑定手\n机号码升级成正式账号！\n正式账号特权：\n1.立即获得3元现金\n2.可提现APP余额\n3.可通过手机登陆",
                  btnList: ["立即绑定"],
                  btnCall: [
                    () {
                      Get.back();
                      Get.toNamed(Routes.BIND_MOBILE_PAGE);
                    }
                  ],
                  btnActionIndex: 0);
            } else {
              Get.toNamed(Routes.WITHDRAW_TYPE_PAGE);
            }
          },
          child: Container(
              width: Dimens.pt225,
              height: Dimens.pt55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color(0xFF121212),
                  border: Border.all(color: const Color(0xFFFFDB9E)),
                  borderRadius: BorderRadius.circular(Dimens.pt12)),
              child: Text("提现",
                  style: TextStyle(
                      fontSize: Dimens.pt30, color: const Color(0xFFFFDB9E)))))
    ])
  ]);
}
