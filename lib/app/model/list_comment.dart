// 🌎 Project imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';

/// 评论列表
class ListComment extends BaseNetModel {
  @override
  ListComment fromJson(Map<String, dynamic> json) {
    return ListComment.fromJson(json);
  }

  List<CommentModel>? list;

  ListComment({this.list});

  ListComment.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <CommentModel>[];
      json['list'].forEach((v) {
        list?.add(CommentModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommentModel extends BaseNetModel {
  @override
  CommentModel fromJson(Map<String, dynamic> json) {
    return CommentModel.fromJson(json);
  }

  // 评论id
  int? id;

  // 评论所属的视频帖子id
  int? objectId;
  CommentType? objectType;

  // 评论所属的用户id
  int? userId;
  String? userName;
  String? userAvatar;
  int? vipType;
  int? level;

  // 上一级评论的id
  int? parentsId;

  // 被回复人的id
  int? replyId;
  String? replyUserName;
  String? text;
  int? commentCount;
  String? createdAt;
  String? scoreLvName;
  String? icon;
  String? badge;
  String? medalImg;
  bool? isLike;
  int? likes;
  List<CommentModel>? subList = [];

  /// 是否是一级评论
  bool get isMain => (parentsId ?? 0) == 0;

  String? adsUrl;

  /// 是否是广告
  bool? isAds = false;

  CommentModel(
      {this.id,
      this.objectId,
      this.objectType,
      this.userId,
      this.userName,
      this.userAvatar,
      this.vipType,
      this.level,
      this.isLike,
      this.likes,
      this.parentsId,
      this.replyId,
      this.replyUserName,
      this.text,
      this.commentCount,
      this.createdAt,
      this.medalImg,
      this.scoreLvName,
      this.icon,
      this.isAds,
      this.adsUrl,
      this.badge});

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    objectId = json['objectId'];
    objectType = CommentType.values[json['objectType']];
    userId = json['userId'];
    userName = json['userName'];
    userAvatar = json['userAvatar'];
    vipType = json['vipType'];
    level = json['level'];
    isLike = json['isLike'];
    likes = json['likes'];
    parentsId = json['parentsId'];
    replyId = json['replyId'];
    replyUserName = json['replyUserName'];
    text = json['text'];
    commentCount = json['commentCount'];
    createdAt = json['createdAt'];
    medalImg = json['medalImg'];
    scoreLvName = json['scoreLvName'];
    icon = json['icon'];
    badge = json['badge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['objectId'] = objectId;
    data['icon'] = icon;
    data['badge'] = badge;
    data['objectType'] = objectType?.index;
    data['userId'] = userId;
    data['userName'] = userName;
    data['userAvatar'] = userAvatar;
    data['vipType'] = vipType;
    data['level'] = level;
    data['parentsId'] = parentsId;
    data['replyId'] = replyId;
    data['replyUserName'] = replyUserName;
    data['text'] = text;
    data['commentCount'] = commentCount;
    data['createdAt'] = createdAt;
    data['medalImg'] = medalImg;
    data['scoreLvName'] = scoreLvName;
    return data;
  }
}
