// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/list_comment.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/views/pull_refresh_view.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/array_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import '../../utils/screen.dart';
import '../dialog/common_dialog.dart';
import '../dialog/input_dialog.dart';
import '../widget/comment_item.dart';
import '../widget/common_widget.dart';

///评论的刷新控件,不含title
class CommentRefreshView extends StatefulWidget {
  /// 帖子id/视频id
  final int? postId;
  final int? comments;

  /// 帖子或者视频的作者id
  final int? authorId;
  final VoidCallback? onComment;
  final bool? showTitle;
  final CommentType? type;
  final bool topInput;
  final Widget Function(List<Widget> comments)? builder;
  final Function(int?)? onLoadCommentCount;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;

  const CommentRefreshView({
    super.key,
    this.postId,
    this.comments = 0,
    this.showTitle = true,
    this.onComment,
    this.authorId,
    this.onLoadCommentCount,
    this.topInput = false,
    this.type = CommentType.CT_Video,
    this.builder,
    this.onRefresh,
    this.onLoadMore,
  });

  @override
  CommentRefreshViewState createState() => CommentRefreshViewState();
}

class CommentRefreshViewState extends State<CommentRefreshView> {
  PullRefreshController pullController = PullRefreshController();
  TextEditingController textController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  /// 帖子评论列表
  List<CommentModel> list = [];

  /// 帖子评论列表的页码
  int pageNumber = 1;

  /// 页面条数
  int pageSize = 10;
  int commentCount = 0;

  /// 所有的评论和回复都是对selectItem的,如果为null则为评论post
  CommentModel? selectItem;

  @override
  void initState() {
    super.initState();
    commentCount = widget.comments!;
    refresh();
  }

  Future<Advertise?> getCommentGameAds() async {
    Advertise? gameAd = await LocalAdsStore().randomWhere(AdsType.commentsAds);
    return gameAd;
  }

  Future<Advertise?> getCommentAds() async {
    try {
      Advertise? ad = await LocalAdsStore().randomWhere(AdsType.commentsAds);
      return ad;
    } on PlatformException catch (e) {
      throw Exception(e.code);
    }
  }

  sendComment() {
    InputDialog.show(context, "", "").then((InputWidget? inputState) async {
      if ((inputState?.text ?? "").isNotEmpty && (inputState?.send ?? false)) {
        await ApiRes.addComment(
            objectId: widget.postId,
            text: inputState?.text,
            objectType: widget.type,
            onError: (err) async {
              await showPlayerCommonDialog(Get.context!,
                  title: "友情提示",
                  content: "评论功能仅会员用户可发送,请先获得会员！",
                  btnCall: [() => Get.toNamed(Routes.VIP_CENTER_PAGE)],
                  btnActionIndex: 0);
            },
            onSuccess: (CommentModel? model) {
              setState(() {
                list.insert(0, model ?? CommentModel());
                pullController.requestSuccess(
                  isFirstPage: false,
                  isEmpty: false,
                );
                commentCount = list.length;
                widget.onLoadCommentCount?.call(commentCount);
              });
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          if (mounted) {
            setState(() => selectItem = null);
          }
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          FutureBuilder<Advertise?>(
              future: getCommentAds(),
              builder: (context, snapshot) {
                Widget child = SizedBox();
                if (snapshot.hasData && snapshot.data != null) {
                  child = Column(children: [
                    SizedBox(height: Dimens.pt25),
                    GestureDetector(
                        onTap: () =>
                            AppPages.jumpRouter(path: snapshot.data?.href),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("大家都在讨论  ",
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      color: Colors.white)),
                              Text(snapshot.data?.title ?? "",
                                  style: TextStyle(
                                      fontSize: Dimens.pt22,
                                      color: AppColors.primaryColor)),
                            ])),
                    SizedBox(height: Dimens.pt25)
                  ]);
                }
                return child;
              }),
          if (widget.topInput) _buildInputContainer(),
          Flexible(
              fit: FlexFit.loose,
              child: PullRefreshView(
                  controller: pullController,
                  onLoading: loadMore,
                  emptyView: getEmptyWidget(),
                  onRefresh: refresh,
                  child: _comments())),
          SizedBox(height: Dimens.pt35),
          if (!widget.topInput) ...[
            _buildInputContainer(),
            SizedBox(
              height: screen.paddingBottom,
            )
          ],
        ]));
  }

  Widget _buildInputContainer() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => sendComment(),
        child: Container(
            width: screen.screenWidth,
            height: Dimens.pt68,
            // margin: EdgeInsets.only(bottom: Dimens.pt25),
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
            decoration: BoxDecoration(
                color: const Color(0xFF262637),
                borderRadius: BorderRadius.circular(Dimens.pt8)),
            child: Row(children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimens.pt30, vertical: Dimens.pt8),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF5F5F8B),
                              width: Dimens.pt1),
                          borderRadius: BorderRadius.circular(Dimens.pt45)),
                      child: Text("只有VIP才可以发表评论哦!",
                          style: TextStyle(
                              fontSize: Dimens.pt22,
                              color: const Color(0xFF787979))))),
              SizedBox(width: Dimens.pt30),
              Container(
                  width: Dimens.pt80,
                  height: Dimens.pt45,
                  decoration: BoxDecoration(
                      color: Color(0xFF4A4A6D),
                      borderRadius: BorderRadius.circular(Dimens.pt8)),
                  child: Center(
                      child: Text("发送",
                          style: TextStyle(
                              fontSize: Dimens.pt24, color: Colors.white))))
              // Image.asset(R.assetsImgIconSend,
              //     width: Dimens.pt68,
              //     color:
              //         Get.find<ThemeManager>().getColor(ThemeColor.textGrey)),
            ])));
  }

  Widget _comments() {
    return ListView.separated(
        shrinkWrap: true,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) =>
            _topLevelComment(list[index]),
        separatorBuilder: (c, index) => SizedBox(height: Dimens.pt25),
        itemCount: (list.length));
  }

  Widget _topLevelComment(CommentModel model) {
    return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: Dimens.pt12, vertical: Dimens.pt5),
        child: CommentItemView(
            type: widget.type,
            model: model,
            authorId: widget.authorId,
            onItemClick: (commentItem) {
              if ((commentItem.isAds ?? false) &&
                  (commentItem.adsUrl ?? "").isNotEmpty) {
                AppPages.jumpRouter(path: commentItem.adsUrl!);
              }
              setState(() {
                selectItem = commentItem;
              });
              focusNode.requestFocus();
            }));
  }

  /// 刷新评论
  void refresh() async {
    pullController.requesting();
    var model = await _getNetData(0, 1);
    if (null != model) {
      pullController.requestSuccess(
        isFirstPage: true,
        isEmpty: ArrayUtil.isEmpty(model.list ?? []) && widget.builder == null,
      );

      if (mounted) {
        setState(() {
          pageNumber = 1;
          list = model.list ?? [];
          commentCount = list.length;
          widget.onLoadCommentCount?.call(commentCount);
        });
      }
    } else {
      pullController.requestFail(isFirstPage: true);
    }
    widget.onRefresh?.call();
  }

  /// 获取数据刷新页面
  void loadMore() async {
    int page = pageNumber + 1;
    ListComment? model = await _getNetData(0, page);
    if (model != null) {
      pullController.requestSuccess(
          isFirstPage: false, hasMore: ArrayUtil.isNotEmpty(model.list ?? []));
      if (mounted) {
        setState(() {
          pageNumber = page;
          list.addAll(model.list ?? []);
          commentCount = list.length;
        });
      }
    } else {
      pullController.requestFail(isFirstPage: false);
    }
    widget.onLoadMore?.call();
  }

  /// 获取数据
  /// [parentsId] parentsId != 0 则为二级评论列表
  Future<ListComment?> _getNetData(int parentsId, int pageNumber) async {
    ListComment? model;
    try {
      model = await ApiRes.getCommentsList(widget.postId,
          parentsId: parentsId, objectType: widget.type, pageNum: pageNumber);
    } catch (e) {
      log.e("comment_refresh_get", "get commentList error :$e");
    }
    return model;
  }
}
