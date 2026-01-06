import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/plugins_utils/HttpRequester/src/base_net_model.dart';

// 顶级漫画详情类，包含 chapterList 和 comicsData
class DetailPageResponse extends BaseNetModel {
  @override
  DetailPageResponse fromJson(Map<String, dynamic> json) {
    return DetailPageResponse.fromJson(json);
  }

  final List<Chapter>? chapterList;
  final MediaInfo? comicsData;
  final MediaInfo? novelData;
  final List<MediaInfo>? mediaList;

  DetailPageResponse({
    this.chapterList,
    this.comicsData,
    this.novelData,
    this.mediaList,
  });

  factory DetailPageResponse.fromJson(Map<String, dynamic> json) {
    return DetailPageResponse(
      chapterList: json['chapterList'] != null
          ? (json['chapterList'] as List)
              .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      comicsData: json['comicsData'] != null
          ? MediaInfo.fromJson(json['comicsData'] as Map<String, dynamic>)
          : null,
      mediaList: json['mediaList'] != null
          ? (json['mediaList'] as List)
              .map((e) => MediaInfo.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      novelData: json['novelData'] != null
          ? MediaInfo.fromJson(json['novelData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterList': chapterList?.map((e) => e.toJson()).toList(),
      'comicsData': comicsData?.toJson(),
    };
  }
}

// Chapter 类
class Chapter {
  final int? chapterNum;
  final String? createdAt;
  final int? id;
  final bool? isFree;
  final bool? isNew;
  final int? pageNum;
  final String? title;
  final int? wordCount;

  Chapter(
      {this.chapterNum,
      this.createdAt,
      this.id,
      this.isFree,
      this.isNew,
      this.pageNum,
      this.title,
      this.wordCount});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterNum: json['chapterNum'] as int?,
      createdAt: json['createdAt'] as String?,
      id: json['id'] as int?,
      isFree: json['isFree'] as bool?,
      isNew: json['isNew'] as bool?,
      pageNum: json['pageNum'] as int?,
      title: json['title'] as String?,
      wordCount: json['wordCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterNum': chapterNum,
      'createdAt': createdAt,
      'id': id,
      'isFree': isFree,
      'isNew': isNew,
      'pageNum': pageNum,
      'title': title,
      'wordCount': wordCount,
    };
  }
}

// Role 类
class Role {
  final String? avatar;
  final int? comicsCvId;
  final String? name;
  final String? roleName;

  Role({
    this.avatar,
    this.comicsCvId,
    this.name,
    this.roleName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      avatar: json['avatar'] as String?,
      comicsCvId: json['comicsCvId'] as int?,
      name: json['name'] as String?,
      roleName: json['roleName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'comicsCvId': comicsCvId,
      'name': name,
      'roleName': roleName,
    };
  }
}

// PlayComicResponse 请求播放漫画的返回数据
class PlayComicResponse extends BaseNetModel {
  @override
  PlayComicResponse fromJson(Map<String, dynamic> json) {
    return PlayComicResponse.fromJson(json);
  }

  final int? code;
  final int? price;
  final bool? isBuy;
  final String? msg;
  final bool? playable;

  PlayComicResponse({
    this.code,
    this.isBuy,
    this.msg,
    this.price,
    this.playable,
  });

  factory PlayComicResponse.fromJson(Map<String, dynamic> json) {
    return PlayComicResponse(
      code: json['code'] as int?,
      price: json['price'] as int?,
      isBuy: json['isBuy'] as bool?,
      msg: json['msg'] as String?,
      playable: json['playable'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'price': price,
      'isBuy': isBuy,
      'msg': msg,
      'playable': playable,
    };
  }
}
