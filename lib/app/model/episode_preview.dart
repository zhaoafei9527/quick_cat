import 'package:quick_cat_client/app/model/comic_chapter.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

class EpisodePreviewModel extends BaseNetModel {
  @override
  EpisodePreviewModel fromJson(Map<String, dynamic> json) {
    return EpisodePreviewModel.fromJson(json);
  }

  List<EpisodeItem>? list;
  int? nowPreviewId;

  EpisodePreviewModel({
    this.list,
    this.nowPreviewId,
  });

  EpisodePreviewModel.fromJson(Map<String, dynamic> json) {
    list = (json['list'] as List)
        .map((item) => EpisodeItem.fromJson(item))
        .toList();
    nowPreviewId = json['nowPreviewId'];
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list?.map((item) => item.toJson()).toList(),
      'nowPreviewId': nowPreviewId,
    };
  }
}

class EpisodeItem {
  final String? desc;
  final int? id;
  final List<int>? ids;
  final int? month;
  final int? num;
  final String? title;
  final int? year;
  final String? coverImg;

  EpisodeItem(
      {this.desc,
      this.id,
      this.ids,
      this.month,
      this.num,
      this.title,
      this.year,
      this.coverImg});

  factory EpisodeItem.fromJson(Map<String, dynamic> json) {
    return EpisodeItem(
      desc: json['desc'],
      id: json['id'],
      coverImg: json['coverImg'],
      ids: List<int>.from(json['ids'] ?? []),
      month: json['month'],
      num: json['num'],
      title: json['title'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desc': desc,
      'id': id,
      'ids': ids,
      'month': month,
      'coverImg': coverImg,
      'num': num,
      'title': title,
      'year': year,
    };
  }
}

class PreviewDetails extends BaseNetModel {
  @override
  PreviewDetails fromJson(Map<String, dynamic> json) {
    return PreviewDetails.fromJson(json);
  }

  List<ListElement>? list;
  EpisodeItem? nextPreview;
  EpisodeItem? nowPreview;
  EpisodeItem? previousPreview;

  PreviewDetails({
    this.list,
    this.nextPreview,
    this.nowPreview,
    this.previousPreview,
  });

  PreviewDetails.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <ListElement>[];
      json['list'].forEach((v) {
        list?.add(ListElement.fromJson(v));
      });
    }
    if (json['nextPreview'] != null) {
      nextPreview = EpisodeItem.fromJson(json['nextPreview']);
    }
    if (json['nowPreview'] != null) {
      nowPreview = EpisodeItem.fromJson(json['nowPreview']);
    }
    if (json['previousPreview'] != null) {
      previousPreview = EpisodeItem.fromJson(json['previousPreview']);
    }
  }

  Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(list!.map((x) => x.toJson())),
        "nextPreview": nextPreview?.toJson(),
        "nowPreview": nowPreview?.toJson(),
        "previousPreview": previousPreview?.toJson(),
      };
}

class ListElement {
  String? desc;
  MediaInfo? episodeMedia;
  int? episodeMediaId;
  int? id;
  String? coverImg;
  List<ChapterPicItem>? images;
  int? mediaId;
  MediaInfo? mediaInfo;
  int? month;
  String? publishedAt;
  int? status;
  String? title;
  int? year;

  ListElement({
    this.desc,
    this.episodeMedia,
    this.episodeMediaId,
    this.id,
    this.images,
    this.mediaId,
    this.mediaInfo,
    this.month,
    this.publishedAt,
    this.status,
    this.title,
    this.year,
    this.coverImg,
  });

  ListElement.fromJson(Map<String, dynamic> json) {
    desc = json["desc"];
    if (json['episodeMedia'] != null) {
      episodeMedia = MediaInfo.fromJson(json['episodeMedia']);
    }
    episodeMediaId = json["episodeMediaId"];
    id = json["id"];
    images = List<ChapterPicItem>.from(
        json["images"].map((x) => ChapterPicItem.fromJson(x)));
    mediaId = json["mediaId"];
    if (json['mediaInfo'] != null) {
      mediaInfo = MediaInfo.fromJson(json['mediaInfo']);
    }
    month = json["month"];
    publishedAt = json["publishedAt"];
    status = json["status"];
    title = json["title"];
    year = json["year"];
    coverImg = json["coverImg"];
  }

  Map<String, dynamic> toJson() => {
        "desc": desc,
        "episodeMedia": episodeMedia?.toJson(),
        "episodeMediaId": episodeMediaId,
        "id": id,
        "images": List<dynamic>.from((images ?? []).map((x) => x.toJson())),
        "mediaId": mediaId,
        "mediaInfo": mediaInfo?.toJson(),
        "month": month,
        "publishedAt": publishedAt,
        "status": status,
        "title": title,
        "year": year,
      };
}

class CoverData {
  int? high;
  int? width;

  CoverData({
    this.high,
    this.width,
  });

  CoverData.fromJson(Map<String, dynamic> json) {
    high = json["high"];
    width = json["width"];
  }

  Map<String, dynamic> toJson() => {
        "high": high,
        "width": width,
      };
}

class YearList extends BaseNetModel {
  @override
  YearList fromJson(Map<String, dynamic> json) {
    return YearList.fromJson(json);
  }

  List<int>? years;

  YearList({
    this.years,
  });

  YearList.fromJson(Map<String, dynamic> json) {
    years = List<int>.from(json["years"] ?? []);
  }

  Map<String, dynamic> toJson() => {"years": List<dynamic>.from(years ?? [])};
}
