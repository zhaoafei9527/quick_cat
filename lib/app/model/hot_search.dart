// 🌎 Project imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';
import 'home/topic_list_model.dart';

class HotSearchModel extends BaseNetModel {
  @override
  HotSearchModel fromJson(Map<String, dynamic> json) {
    return HotSearchModel.fromJson(json);
  }

  List<MediaInfo>? avMediaList;
  List<MediaInfo>? shortMediaList;
  List<HotSearchResultModel>? list;
  Map<MediaType, List<String>>? tagTypeMap = {
    MediaType.comic: [],
    MediaType.cartoon: [],
    MediaType.novel: [],
    MediaType.videoLong: [],
    MediaType.videoShort: []
  };

  HotSearchModel(
      {this.avMediaList, this.shortMediaList, this.tagTypeMap, this.list});

  HotSearchModel.fromJson(Map<String, dynamic> json) {
    if (json["content"] != null) {
      tagTypeMap = <MediaType, List<String>>{};
      json["content"].forEach((String key, value) {
        List<String> list = [];
        for (var item in value) {
          list.add(item);
        }
        tagTypeMap![MediaType.values[int.tryParse(key) ?? 1]] = list;
      });
    }

    if (json['avMediaList'] != null) {
      avMediaList = <MediaInfo>[];
      json['avMediaList'].forEach((v) {
        avMediaList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['shortMediaList'] != null) {
      shortMediaList = <MediaInfo>[];
      json['shortMediaList'].forEach((v) {
        shortMediaList?.add(MediaInfo.fromJson(v));
      });
    }
    if (json['list'] != null) {
      list = <HotSearchResultModel>[];
      json['list'].forEach((v) {
        list?.add(HotSearchResultModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (shortMediaList != null) {
      data['shortMediaList'] = shortMediaList?.map((v) => v.toJson()).toList();
    }
    if (avMediaList != null) {
      data['avMediaList'] = avMediaList?.map((v) => v.toJson()).toList();
    }
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HotSearchResultModel {
  String? content;
  bool? isHot;

  HotSearchResultModel({this.content});

  HotSearchResultModel.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    isHot = json['isHot'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['isHot'] = isHot;
    return data;
  }
}
