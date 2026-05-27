// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/dialog/image_viewer.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/views/comment_refresh_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import '../../../../plugins_utils/VideoPlayer/fijk_player.dart';
import '../../../../utils/screen.dart';
import '../../../model/post_list_model.dart';
import '../controllers/post_detail_page_controller.dart';

class PostDetailPageView extends GetView<PostDetailPageController> {
  const PostDetailPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<PostDetailPageController>(
        builder: (PostDetailPageController logic) {
      FIJKPlayerManager manager = FIJKPlayerManager();
      PostBase? base = logic.post.value.base;
      return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _handlePageBack(manager, base, logic);
          },
          child: Scaffold(
              backgroundColor: Color(0xFF0B0C13),
              appBar: getCommonAppBar(base?.topicName ?? "",
                  onBack: () => _handlePageBack(manager, base, logic)),
              body: Stack(children: [
                Offstage(
                    offstage: logic.imageViewer.value,
                    child: _buildPostDetails()),
                Offstage(
                    offstage: !logic.imageViewer.value,
                    child: _buildImageViewer()),
              ])));
    });
  }

  Future<void> _handlePageBack(
    FIJKPlayerManager manager,
    PostBase? base,
    PostDetailPageController logic,
  ) async {
    await manager.disposePlayer();
    WatchRecord.addWatchRecord(
        PostBrief(base: base, node: logic.post.value.nodes?[0]),
        MediaType.post);
    Get.back();
  }

  Widget _buildImageViewer() {
    return Container();
  }

  Widget _buildPostDetails() {
    PostDetailPageController logic = Get.find();
    bool initOk = logic.initOk.value;
    return initOk
        ? Container(
            margin: EdgeInsets.only(bottom: Dimens.pt70),
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(child: _buildHeadView(logic)),

              _buildPostDetail(logic),

              SliverToBoxAdapter(child: _buildPostVideoView(logic)),
              SliverToBoxAdapter(child: SizedBox(height: Dimens.pt25)),
              // SliverToBoxAdapter(child: buildPostEmojiView(base)),
              SliverToBoxAdapter(child: _buildPostFootView(logic)),
            ]))
        : getLoadingView();
  }

  Widget _buildPostFootView(PostDetailPageController? logic) {
    PostBase? base = logic?.post.value.base;
    bool isCollect = base?.isCollect ?? false;
    int collects = base?.collects ?? 0;
    ThemeManager theme = Get.find<ThemeManager>();
    return Column(children: [
      Row(children: [
        Text("浏览量 ${base?.watches ?? 0}",
            style: TextStyle(fontSize: Dimens.pt24, color: Colors.white)),

        Spacer(),

        // SizedBox(width: Dimens.pt45),
        buildVideoNumber(
            icon: R.assetsImgIconVideoComment, text: "${base?.comments ?? 0}"),

        SizedBox(width: Dimens.pt45),
        StatefulBuilder(builder: (context, setState) {
          return buildVideoNumber(
              icon: isCollect
                  ? R.assetsImgIconPostCollected
                  : R.assetsImgIconPostCollect,
              color: isCollect ? null : AppColors.textColorWhite,
              onTap: () async {
                bool collect = !isCollect;
                setState(() {
                  isCollect = collect;
                  collects = collect ? collects + 1 : collects - 1;
                });
                base?.isCollect = collect;
                base?.collects = collects;
                int objectId = base?.id ?? 0;
                MediaType collectType = MediaType.post;
                await ApiRes.addCollect(
                    collectType: collectType,
                    objectId: objectId,
                    flag: collect);
              },
              text: "$collects");
        })
      ]),
      ...[
        if (logic?.post.value.titleLink != null &&
            logic?.post.value.titleLink != "")
          Column(children: [
            SizedBox(height: Dimens.pt60),
            GestureDetector(
                onTap: () =>
                    AppPages.jumpRouter(path: logic?.post.value.titleLink),
                child: Container(
                    width: Dimens.pt208,
                    height: Dimens.pt58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimens.pt12),
                        border: Border.all(color: AppColors.primaryColor)),
                    child: Text("立即前往",
                        style: TextStyle(
                            fontSize: Dimens.pt26,
                            color: theme.getColor(ThemeColor.primary))))),
          ]),
        SizedBox(height: Dimens.pt60)
      ],
      getHengLine(color: Color(0xFF3AF26E).withOpacity(0.4)),
      SizedBox(
          height: screen.screenHeight / 1.8,
          child: CommentRefreshView(
              postId: base?.id ?? 0,
              type: CommentType.CT_Post,
              topInput: false,
              comments: base?.comments))
    ]);
  }

  Widget _buildPostDetail(PostDetailPageController logic) {
    List<PostNode>? nodes = logic.post.value.nodes;
    PostBase? base = logic.post.value.base;
    return SliverList(
        delegate: SliverChildBuilderDelegate((c, index) {
      List<String>? images = nodes?[index].imgs;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(nodes?[index].text ?? "",
            style: TextStyle(fontSize: Dimens.pt24, color: Colors.white)),
        SizedBox(height: Dimens.pt25),
        ...List.generate(images?.length ?? 0, (key) {
          return GestureDetector(
            onTap: () async {
              await showImageViewerDialog(Get.context!, images: images);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                  overlays: SystemUiOverlay.values);
            },
            child: Container(
                margin: EdgeInsets.only(bottom: Dimens.pt25),
                child: ImageLoader.withP(images?[key] ?? "",
                        radius: Dimens.pt12,
                        // height: Dimens.pt600,
                        width: screen.screenWidth)
                    .load()),
          );
        })
      ]);
    }, childCount: nodes?.length ?? 0));
  }

  Widget _buildPostVideoView(PostDetailPageController logic) {
    PostBase? base = logic.post.value.base;
    String videoUri = base?.videoUrl ?? "";
    String videoCover = base?.videoCover ?? "";
    if (videoUri.isEmpty || videoCover.isEmpty) return const SizedBox();
    return SizedBox(
      child: Column(children: [
        SizedBox(height: Dimens.pt25),

        FIJKVideoPlayer(
            key: ValueKey(videoUri),
            url: videoUri,
            autoPlay: false,
            canPlay: logic.post.value.canPlay ?? true,
            simpleModel: true,
            cover: videoCover),

        // SizedBox(height: Dimens.pt25),
        Text(base?.videoText ?? "视频文案视频文案",
            style: TextStyle(
                fontSize: Dimens.pt24, color: const Color(0xFFFDF6F2)))
      ]),
    );
  }

  Widget _buildHeadView(PostDetailPageController? logic) {
    PostBase? base = logic?.post.value.base;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(base?.title ?? "",
          style: TextStyle(color: Colors.white, fontSize: Dimens.pt28)),
      SizedBox(height: Dimens.pt18),
      Text(
          "${TimeUtil.buildChineseYYMMDD(base?.createdAt ?? '')} ·"
          " ${base?.topicName ?? '吃瓜'} ·"
          " ${base?.watches ?? 0}浏览",
          style: TextStyle(fontSize: Dimens.pt22, color: AppColors.textGrey)),
      SizedBox(height: Dimens.pt20)
    ]);
  }

  Widget buildVideoNumber(
      {String? icon,
      String? text,
      double? width,
      VoidCallback? onTap,
      Color? color}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
        onTap: () => onTap?.call(),
        child: Row(children: [
          Image.asset(icon ?? R.assetsImgIconVideoCollect,
              width: width ?? Dimens.pt28, color: color),
          SizedBox(width: Dimens.pt8),
          Text(text ?? "",
              style: TextStyle(fontSize: Dimens.pt24, color: Colors.white))
        ]));
  }
}
