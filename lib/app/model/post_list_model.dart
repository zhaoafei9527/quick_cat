// 🌎 Project imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';

class PostBriefResp extends BaseNetModel {
  @override
  PostBriefResp fromJson(Map<String, dynamic> json) {
    return PostBriefResp.fromJson(json);
  }

  List<PostBrief>? list;
  List<PostTopicInfo>? topicList;

  PostBriefResp({this.list, this.topicList});

  PostBriefResp.fromJson(Map<String, dynamic> json) {
    if (null != json['list']) {
      list = <PostBrief>[];
      json['list'].forEach((e) {
        list?.add(PostBrief.fromJson(e));
      });
    }
    if (null != json['topicList']) {
      topicList = <PostTopicInfo>[];
      json['topicList'].forEach((e) {
        topicList?.add(PostTopicInfo.fromJson(e));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list?.map((e) => e.toJson()).toList();
    data['topicList'] = topicList?.map((e) => e.toJson()).toList();
    return data;
  }
}

class PostTopicInfo {
  int? id;
  String? adsId;
  String? name;
  String? cover;
  int? count;
  String? adsPath;

  PostTopicInfo({this.id,
    this.adsId,
    this.name, this.count, this.adsPath,this.cover});

  PostTopicInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    cover = json['cover'];
    count = json['count'];
    adsId = json['adsId'];
    adsPath = json['adsPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['count'] = count;
    data['cover'] = cover;
    data['adsId'] = adsId;
    data['adsPath'] = adsPath;

    return data;
  }
}

class PostBrief extends BaseNetModel {
  @override
  PostBrief fromJson(Map<String, dynamic> json) {
    return PostBrief.fromJson(json);
  }

  PostBase? base;
  PostNode? node;

  // for ui
  bool isSelected = false;

  PostBrief({this.base, this.node});

  PostBrief.fromJson(Map<String, dynamic> json) {
    if (null != json['base']) {
      base = PostBase.fromJson(json["base"]);
    }
    if (null != json['node']) {
      node = PostNode.fromJson(json["node"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['base'] = base?.toJson();
    data['node'] = node?.toJson();
    return data;
  }
}

class PostBase {
  int? comments;
  String? contact;
  String? createdAt;
  String? title;
  int? height;
  int? id;
  bool? isAuth;
  bool? isBought;
  bool? isCare;
  bool? isVip;
  bool? isLike;
  int? likes;
  int? price;
  String? remark;
  PublicationStatus? status;
  String? type;
  String? userAvatar;
  int? userId;
  int? topicId;
  String? topicName;
  String? userName;
  String? videoCover;
  String? videoText;
  String? videoUrl;
  String? watchId;
  int? watches;
  int? width;
  int? videoCoverHeight;
  int? videoCoverWidth;
  bool? isSeller;
  int? tradeStatus; //0. 等待交易 1.交易中 2.交易完成
  bool? rechargeStatus;
  int? minRecharge;
  int? mediaID;
  bool? isCollect;
  int? collects;
  EmojiInfoModel? realEmoji;
  EmojiInfoModel? isEmojis;

  PostBase(
      {this.id,
      this.comments,
      this.contact,
      this.createdAt,
      this.height,
      this.isAuth,
      this.isBought,
      this.isCare,
      this.isLike,
      this.likes,
      this.price,
      this.remark,
      this.status,
      this.type,
      this.topicId,
      this.userAvatar,
      this.userId,
      this.userName,
      this.videoCover,
      this.videoText,
      this.videoUrl,
      this.watchId,
      this.watches,
      this.width,
      this.isVip,
      this.title,
      this.videoCoverWidth,
      this.videoCoverHeight,
      this.isSeller,
      this.topicName,
      this.tradeStatus,
      this.rechargeStatus,
      this.realEmoji,
      this.isEmojis,
      this.mediaID,
      this.isCollect,
      this.minRecharge});

  PostBase.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isCollect = json['isCollect'];
    collects = json['collects'];
    comments = json['comments'];
    contact = json['contact'];
    createdAt = json['createdAt'];
    height = json['height'];
    isAuth = json['isAuth'];
    isBought = json['isBought'];
    isCare = json['isCare'];
    isLike = json['isLike'];
    isVip = json['isVip'];
    likes = json['likes'];
    price = json['price'];
    topicId = json['topicId'];
    topicName = json['topicName'];
    remark = json['remark'];
    type = json['type'];
    userAvatar = json['userAvatar'];
    userId = json['userId'];
    userName = json['userName'];
    videoCover = json['videoCover'];
    videoText = json['videoText'];
    videoUrl = json['videoUrl'];
    watchId = json['watchId'];
    watches = json['watches'];
    width = json['width'];
    mediaID = json['mediaID'];
    title = json['title'];
    videoCoverHeight = json['videoCoverHeight'];
    videoCoverWidth = json['videoCoverWidth'];
    realEmoji = json['realEmoji'] != null
        ? EmojiInfoModel.fromJson(json['realEmoji'])
        : null;
    isEmojis = json['isEmojis'] != null
        ? EmojiInfoModel.fromJson(json['isEmojis'])
        : null;
    status = PublicationStatus.values[json['status'] ?? 0];
    isSeller = json['isSeller'];
    tradeStatus = json['tradeStatus'];
    rechargeStatus = json['rechargeStatus'];
    minRecharge = json['minRecharge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isCollect'] = isCollect;
    data['comments'] = comments;
    data['contact'] = contact;
    data['createdAt'] = createdAt;
    data['height'] = height;
    data['isAuth'] = isAuth;
    data['isBought'] = isBought;
    data['isCare'] = isCare;
    data['isLike'] = isLike;
    data['isVip'] = isVip;
    data['likes'] = likes;
    data['price'] = price;
    data['remark'] = remark;
    data['type'] = type;
    data['userAvatar'] = userAvatar;
    data['userId'] = userId;
    data['userName'] = userName;
    data['videoCover'] = videoCover;
    data['videoText'] = videoText;
    data['videoUrl'] = videoUrl;
    data['watchId'] = watchId;
    data['width'] = width;
    data['watches'] = watches;
    data['title'] = title;
    data['mediaID'] = mediaID;
    data['status'] = status?.index;
    data['videoCoverHeight'] = videoCoverHeight;
    data['videoCoverWidth'] = videoCoverWidth;
    data['isSeller'] = isSeller;
    data['tradeStatus'] = tradeStatus;
    data['rechargeStatus'] = rechargeStatus;
    data['minRecharge'] = minRecharge;
    if (realEmoji != null) {
      data['realEmoji'] = realEmoji?.toJson();
    }
    if (isEmojis != null) {
      data['isEmojis'] = isEmojis?.toJson();
    }
    return data;
  }
}

class EmojiInfoModel {
  int? like;
  int? tearsJoy;
  int? fury;
  int? flushedFace;
  int? joker;
  bool? isLike;
  bool? isTearsJoy;
  bool? isFury;
  bool? isFlushedFace;
  bool? isJoker;

  EmojiInfoModel({
    this.like,
    this.tearsJoy,
    this.flushedFace,
    this.fury,
    this.joker,
    this.isLike,
    this.isTearsJoy,
    this.isFury,
    this.isFlushedFace,
    this.isJoker,
  });

  EmojiInfoModel.fromJson(Map<String, dynamic> json) {
    like = json['like'];
    tearsJoy = json['tearsJoy'];
    fury = json['fury'];
    flushedFace = json['flushedFace'];
    joker = json['joker'];

    isLike = json['isLike'];
    isTearsJoy = json['isTearsJoy'];
    isFury = json['isFury'];
    isFlushedFace = json['isFlushedFace'];
    isJoker = json['isJoker'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['like'] = like;
    data['tearsJoy'] = tearsJoy;
    data['fury'] = fury;
    data['flushedFace'] = flushedFace;
    data['joker'] = joker;

    data['isLike'] = isLike;
    data['isTearsJoy'] = isTearsJoy;
    data['isFury'] = isFury;
    data['isFlushedFace'] = isFlushedFace;
    data['isJoker'] = isJoker;
    return data;
  }
}

class PostNode {
  List<String>? imgs;
  String? text;

  PostNode({this.imgs, this.text});

  PostNode.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    imgs = json['imgs']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['imgs'] = imgs;
    return data;
  }
}

class PublishInfo {
  String? avatar;
  int? id;
  String? name;

  PublishInfo({this.avatar, this.id, this.name});

  PublishInfo.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class PostDetailsResp extends BaseNetModel {
  @override
  PostDetailsResp fromJson(Map<String, dynamic> json) {
    return PostDetailsResp.fromJson(json);
  }

  PostBase? base;
  String? jumpPicture;
  String? jumpTitle;
  List<PostNode>? nodes;
  String? pictureLink;
  String? titleLink;

  PostDetailsResp(
      {this.base,
      this.jumpPicture,
      this.jumpTitle,
      this.nodes,
      this.pictureLink,
      this.titleLink});

  PostDetailsResp.fromJson(Map<String, dynamic> json) {
    if (null != json['base']) {
      base = PostBase.fromJson(json["base"]);
    }
    if (null != json['nodes']) {
      nodes = <PostNode>[];
      json['nodes'].forEach((e) {
        nodes?.add(PostNode.fromJson(e));
      });
    }
    jumpPicture = json['jumpPicture'];
    jumpTitle = json['jumpTitle'];
    pictureLink = json['pictureLink'];
    titleLink = json['titleLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['base'] = base?.toJson();
    data['nodes'] = nodes?.map((e) => e.toJson()).toList();
    data['jumpPicture'] = jumpPicture;
    data['jumpTitle'] = jumpTitle;
    data['pictureLink'] = pictureLink;
    data['titleLink'] = titleLink;
    return data;
  }
}

class UploadPostReq {
  String? text;
  String? title;
  int? price;
  List<String>? imgs;
  String? video;
  String? cover;
  String? taskID;
  int? categoryId;
  String? contact;
  bool? isSeller; //true 卖方 false 买方
  UploadPostReq(
      {this.cover,
      this.imgs,
      this.price,
      this.taskID,
      this.text,
      this.video,
      this.categoryId,
      this.title,
      this.contact,
      this.isSeller});

  UploadPostReq.fromJson(Map<String, dynamic> json) {
    imgs = json['imgs']?.cast<String>();
    text = json['text'];
    price = json['price'];
    video = json['video'];
    cover = json['cover'];
    taskID = json['taskID'];
    title = json['title'];
    categoryId = json['categoryId'];
    contact = json['contact'];
    isSeller = json['isSeller'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imgs'] = imgs;
    data['text'] = text;
    data['price'] = price;
    data['video'] = video;
    data['cover'] = cover;
    data['taskID'] = taskID;
    data['title'] = title;
    data['categoryId'] = categoryId;
    data['contact'] = contact;
    data['isSeller'] = isSeller;
    return data;
  }
}

class PostPayResp {
  int? code;
  String? msg;

  PostPayResp({this.code, this.msg});

  PostPayResp.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['msg'] = msg;
    return data;
  }
}

class PostCommentListReq {
  int? objectId;
  CommentType? objectType;
  int? pageNum;
  int? pageSize;
  int? parentsId;

  PostCommentListReq(
      {this.objectId,
      this.objectType,
      this.pageNum,
      this.pageSize,
      this.parentsId});

  PostCommentListReq.fromJson(Map<String, dynamic> json) {
    objectType = CommentType.values[json['objectType'] ?? 0];
    objectId = json['objectId'];
    pageNum = json['pageNum'];
    pageSize = json['pageSize'];
    parentsId = json['parentsId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['objectType'] = objectType?.index;
    data['objectId'] = objectId;
    data['pageNum'] = pageNum;
    data['pageSize'] = pageSize;
    data['parentsId'] = parentsId;
    return data;
  }
}

class AddPostCommentReq {
  int? objectId;
  CommentType? objectType;
  int? parentsId;
  int? replyId;
  String? text;

  AddPostCommentReq(
      {this.objectId,
      this.objectType,
      this.parentsId,
      this.replyId,
      this.text});

  AddPostCommentReq.fromJson(Map<String, dynamic> json) {
    objectType = CommentType.values[json['objectType'] ?? 0];
    objectId = json['objectId'];
    replyId = json['replyId'];
    text = json['text'];
    parentsId = json['parentsId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['objectType'] = objectType?.index;
    data['objectId'] = objectId;
    data['replyId'] = replyId;
    data['text'] = text;
    data['parentsId'] = parentsId;
    return data;
  }
}

enum PublicationStatus {
  Waiting, // 待上架
  Verified, // 上架
  Cancelled, //取消上架
  WaitingVerify, //待审核
  Declined, // 拒绝
}
