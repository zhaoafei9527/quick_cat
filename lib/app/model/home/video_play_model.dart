// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

class MediaPlayModel extends BaseNetModel {
  @override
  MediaPlayModel fromJson(Map<String, dynamic> json) {
    return MediaPlayModel.fromJson(json);
  }

  int? code;
  String? comment;
  MediaInfo? mediaInfo; // 媒体信息
  int? movieTickets;
  String? msg;
  bool? playable;
  int? watchCount;
  int? totalWatchCount;
  int? leftCount;
  List<MediaInfo>? mediaList = <MediaInfo>[]; // 相关媒体列表
  List<MediaInfo>? comicsList = <MediaInfo>[]; // 相关漫画列表
  MediaInfo? collect = MediaInfo(); // 推荐合集

  MediaPlayModel(
      {this.code,
      this.comment,
      this.mediaInfo,
      this.movieTickets,
      this.msg,
      this.playable,
      this.totalWatchCount,
      this.leftCount,
      this.mediaList,
      this.comicsList,
      this.collect,
      this.watchCount});

  MediaPlayModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    comment = json['comment'];
    msg = json['msg'];
    movieTickets = json['movieTickets'];
    playable = json['playable'];
    watchCount = json['watchCount'];
    totalWatchCount = json['totalWatchCount'];
    leftCount = json['leftCount'];

    if (json['mediaList'] != null) {
      json['mediaList'].forEach((v) {
        mediaList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['comicsList'] != null) {
      json['comicsList'].forEach((v) {
        comicsList?.add(MediaInfo.fromJson(v));
      });
    }
    mediaInfo = json['mediaInfo'] != null
        ? MediaInfo?.fromJson(json['mediaInfo'])
        : null;
    collect =
        json['collect'] != null ? MediaInfo?.fromJson(json['collect']) : null;
  }
}

class SecondsPlayInfoModel {
  Duration? duration;
  bool? isBoom;
  String? name;
  String? desc;

  SecondsPlayInfoModel({this.duration, this.name, this.isBoom, this.desc});

  SecondsPlayInfoModel.fromJson(Map<String, dynamic> json) {
    duration = Duration(seconds: json['duration'] ?? 0);
    name = json['name'];
    isBoom = json['isBoom'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['duration'] = duration;
    data['name'] = name;
    data['isBoom'] = isBoom;
    data['desc'] = desc;
    return data;
  }
}

/// 视频缓存信息类
class VideoCacheInfo {
  final int mediaId;
  final String title;
  final String? coverImg;
  final DateTime cacheTime;
  final int cacheSizeBytes;
  final int segmentCount;
  final int totalCount;
  final String originalUrl;
  final MediaType? mediaType;

  VideoCacheInfo({
    required this.mediaId,
    required this.title,
    this.coverImg,
    this.mediaType,
    required this.totalCount,
    required this.cacheTime,
    required this.cacheSizeBytes,
    required this.segmentCount,
    required this.originalUrl,
  });

  Map<String, dynamic> toJson() => {
    'mediaId': mediaId,
    'title': title,
    'coverImg': coverImg,
    'cacheTime': cacheTime.toIso8601String(),
    'cacheSizeBytes': cacheSizeBytes,
    'segmentCount': segmentCount,
    "totalCount": totalCount,
    'originalUrl': originalUrl,
  };

  factory VideoCacheInfo.fromJson(Map<String, dynamic> json) => VideoCacheInfo(
    mediaId: json['mediaId'] as int,
    title: json['title'] as String,
    coverImg: json['coverImg'] as String?,
    cacheTime: DateTime.parse(json['cacheTime'] as String),
    cacheSizeBytes: json['cacheSizeBytes'] as int,
    totalCount:  json['totalCount'] as int,
    segmentCount: json['segmentCount'] as int,
    originalUrl: json['originalUrl'] as String,
  );
}
