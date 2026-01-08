// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import '../../utils/array_util.dart';
import '../dialog/common_dialog.dart';
import '../dialog/input_dialog.dart';
import '../model/list_comment.dart';
import '../routes/app_pages.dart';

/// 评论item
class CommentItemView extends StatefulWidget {
  final CommentModel? model;
  final CommentType? type;

  /// 文章/视频所属用户id
  final int? authorId;

  /// item点击，也包括上面的title评论点击
  final ValueChanged<CommentModel>? onItemClick;

  const CommentItemView({
    super.key,
    this.type,
    this.onItemClick,
    this.model,
    this.authorId,
  });

  @override
  _CommentItemViewState createState() => _CommentItemViewState();
}

class _CommentItemViewState extends State<CommentItemView> {
  /// 子级评论列表页码
  int pageNum = 0;

  /// 页面size
  int pageSize = 3;

  /// 子列表是否显示 更多 按钮
  bool hasMore = false;

  // 是否有收起按钮 评论数大于1
  bool haveSub = false;

  /// 是否展开子项
  bool showSub = true;

  /// isFirst
  bool isFirst = true;

  List<CommentModel> subList = [];

  @override
  void initState() {
    super.initState();
    if ((widget.model?.id ?? 0) > 0) {
      getFirstComment();
    }
  }

  getFirstComment() async {
    List<CommentModel>? list = await _getData(1);
    if (mounted) {
      setState(() {
        isFirst = true;
        if ((list ?? []).isNotEmpty) {
          subList.add(list![0]);
          haveSub = true;
        }
        if ((list ?? []).length < pageSize) {
          hasMore = false;
        } else {
          hasMore = true;
        }
      });
    }
  }

  /// 点击展开更多
  void _clickMore() async {
    var page = pageNum + 1;

    List<CommentModel>? list = await _getData(page);
    if (mounted) {
      setState(() {
        if (ArrayUtil.isNotEmpty(list ?? [])) {
          if (isFirst) subList = [];
          pageNum = page;
          subList.addAll(list ?? []);
          if ((list ?? []).length < pageSize) {
            hasMore = false;
          } else {
            hasMore = true;
          }
          isFirst = false;
        }
      });
    }
  }

  /// 获取数据
  Future<List<CommentModel>?> _getData(int pageNum) async {
    int? postId = widget.model?.objectId;
    ListComment? model;
    try {
      model = await ApiRes.getCommentsList(postId,
          objectType: widget.model?.objectType,
          parentsId: widget.model?.id,
          pageSize: pageSize,
          pageNum: pageNum);
    } catch (e) {
      log.e("comment_item_get", "get commentList error :$e");
    }
    return model?.list;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        if (widget.model?.isAds ?? false)
          {AppPages.jumpRouter(path: widget.model?.adsUrl ?? "")}
      },
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ImageLoader.withP(widget.model?.userAvatar,
                width: Dimens.pt66,
                height: Dimens.pt66,
                errorIconSize: Dimens.pt26,
                errorFontSize: Dimens.pt14,
                radius:
                    (widget.model?.isAds ?? false) ? Dimens.pt8 : Dimens.pt45)
            .load(),
        SizedBox(width: Dimens.pt20),
        Flexible(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildUserNameView(widget.model, isMain: true),
          SizedBox(height: Dimens.pt20),
          _buildCommentText(widget.model?.text ?? "",
              isAds: widget.model?.isAds ?? false),
          SizedBox(height: Dimens.pt5),
          if (!(widget.model?.isAds ?? false)) ...[
            _buildCommentUtils(widget.model, isMain: true),
            SizedBox(height: Dimens.pt15),
            ...List.generate(subList.length, (index) {
              CommentModel? sub = subList[index];
              if (!showSub && index != 0) return const SizedBox();
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageLoader.withP(sub.userAvatar,
                            width: Dimens.pt38,
                            height: Dimens.pt38,
                            radius: Dimens.pt45)
                        .load(),
                    SizedBox(width: Dimens.pt10),
                    Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _buildUserNameView(sub, isMain: false),
                          _buildCommentText(sub.text ?? ""),
                          SizedBox(height: Dimens.pt5),
                          _buildCommentUtils(sub, isMain: false),
                          SizedBox(height: Dimens.pt25),
                        ]))
                  ]);
            }),
            _buildLastUtils(),
            getHengLine(color: Color(0xFFE5E5E5).withOpacity(.3), h: Dimens.pt1)
          ],
        ]))
      ]),
    );
  }

  Widget _buildLastUtils() {
    ThemeManager theme = Get.find<ThemeManager>();
    return Row(children: [
      if (hasMore) ...[
        getHengLine(w: Dimens.pt60, color: Colors.white.withOpacity(.1)),
        SizedBox(width: Dimens.pt10),
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _clickMore(),
            child: Row(children: [
              Text("展开更多",
                  style: TextStyle(
                      fontSize: Dimens.pt22,
                      color: theme.getColor(ThemeColor.textYellow))),
              SizedBox(width: Dimens.pt5),
              Image.asset(R.assetsImgIconDown,
                  width: Dimens.pt31,
                  color: theme.getColor(ThemeColor.textYellow))
            ])),
      ],
      SizedBox(width: Dimens.pt40),
      if (haveSub && subList.length > 1)
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => showSub = !showSub),
            child: Row(children: [
              Text("收起",
                  style: TextStyle(
                      fontSize: Dimens.pt22,
                      color: theme.getColor(ThemeColor.textYellow))),
              SizedBox(width: Dimens.pt5),
              Image.asset(showSub ? R.assetsImgIconDown : R.assetsImgIconUp,
                  width: Dimens.pt31,
                  color: theme.getColor(ThemeColor.textYellow))
            ]))
    ]);
  }

  onSendComment({int? parentsId, int? replyId}) {
    InputDialog.show(context, "", "").then((InputWidget? inputState) async {
      if ((inputState?.text ?? "").isNotEmpty && (inputState?.send ?? false)) {
        await ApiRes.addComment(
            objectId: widget.model?.objectId,
            text: inputState?.text,
            parentsId: parentsId,
            replyId: replyId,
            objectType: widget.model?.objectType,
            onError: (err) async {
              await showPlayerCommonDialog(Get.context!,
                  title: "友情提示",
                  content: "评论功能仅会员用户可发送,请先获得会员！",
                  btnCall: [() => Get.toNamed(Routes.VIP_CENTER_PAGE)],
                  btnActionIndex: 0);
            },
            onSuccess: (CommentModel? model) {
              setState(() {
                subList.insert(0, model!);
              });
            });
      }
    });
  }

  Row _buildCommentUtils(CommentModel? model, {bool? isMain}) {
    ThemeManager theme = Get.find<ThemeManager>();
    int likes = model?.likes ?? 0;
    bool isLike = model?.isLike ?? false;
    return Row(children: [
      Text(TimeUtil.showDateBefore(model?.createdAt ?? ""),
          style: TextStyle(fontSize: Dimens.pt24, color: Color(0xFF999999))),
      const Spacer(),
      if (isMain ?? false)
        GestureDetector(
            onTap: () =>
                onSendComment(parentsId: model?.id, replyId: model?.userId),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                child: Text("回复",
                    style: TextStyle(
                        fontSize: Dimens.pt24, color: Color(0xFF999999))))),
      SizedBox(width: Dimens.pt20),
      StatefulBuilder(builder: (context, setState) {
        return GestureDetector(
            onTap: () async {
              isLike = !isLike;
              await ApiRes.addCollect(
                  collectType: MediaType.comment,
                  type: ActionType.Like,
                  objectId: model?.id ?? 0,
                  flag: isLike,
                  onSuccess: () {},
                  onError: (e) {});
              setState(() {
                likes = isLike ? likes + 1 : likes - 1;
              });
            },
            child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(children: [
                  Image.asset(
                      isLike
                          ? R.assetsImgIconComCollected
                          : R.assetsImgIconComCollect,
                      width: Dimens.pt30),
                  SizedBox(width: Dimens.pt10),
                  Text("$likes",
                      style: TextStyle(
                          fontSize: Dimens.pt24, color: Color(0xFF999999)))
                ])));
      })
    ]);
  }

  Text _buildCommentText(String text, {bool isAds = false}) {
    return Text(text,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: Dimens.pt26,
            color: isAds ? AppColors.primaryColor : Colors.white));
  }

  Row _buildUserNameView(CommentModel? model, {bool? isMain}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return Row(children: [
      Text(model?.userName ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: Dimens.pt28, color: Colors.white)),
      if (!(model?.isAds ?? false)) ...[
        SizedBox(width: Dimens.pt10),
        // Image.asset(tipVipActiveInsert["insert$vipType"] ?? "", width: 70),
        SizedBox(width: Dimens.pt6),
        if (!(isMain ?? false)) ...[
          Image.asset(R.assetsImgIconPlayerPause,
              width: Dimens.pt13, color: const Color(0xFF8A8785)),
          SizedBox(width: Dimens.pt8),
          Text(widget.model?.userName ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: Dimens.pt22,
                  color: (model?.isAds ?? false)
                      ? theme.getColor(ThemeColor.primary)
                      : AppColors.textColorWhite)),
          SizedBox(width: Dimens.pt10),
          // Image.asset(tipVipActiveInsert["insert$widgetVipType"] ?? "",
          //     width: 70)
        ]
      ] else ...[
        const Spacer(),
        Container(
            width: Dimens.pt50,
            height: Dimens.pt28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.shadowGrey,
                borderRadius: BorderRadius.circular(Dimens.pt5)),
            child: Text("广告",
                style: TextStyle(
                    fontSize: Dimens.pt18,
                    color: Colors.white.withOpacity(.6))))
      ]
    ]);
  }
}
