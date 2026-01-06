// 🌎 Project imports:
import 'package:acgn_client/plugins_utils/HttpRequester/http_requester.dart';

/// 红包模型
class ActivityModel extends BaseNetModel {
  @override
  ActivityModel fromJson(Map<String, dynamic> json) {
    return ActivityModel.fromJson(json);
  }

  List<ActivityModel>? list;
  String? name;
  String? title;
  String? describe;
  String? cover;
  String? coverDetail;
  String? jumpUrl;
  String? note;
  String? start;
  String? end;
  bool? isEnd; // 今天是否已经领取

  ActivityModel(
      {this.name,
      this.title,
      this.describe,
      this.cover,
      this.coverDetail,
      this.jumpUrl,
      this.start,
      this.list,
      this.end,
      this.isEnd,
      this.note});

  ActivityModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    if (json["list"] != null) {
      list = <ActivityModel>[];
      json['list'].forEach((e) {
        list?.add(ActivityModel.fromJson(e));
      });
    }
    title = json['title'];
    describe = json['describe'];
    cover = json['cover'];
    coverDetail = json['coverDetail'];
    jumpUrl = json['jumpUrl'];
    start = json['start'];
    end = json['end'];
    isEnd = json['isEnd'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['list'] = list?.map((e) => e.toJson()).toList();
    data['title'] = title;
    data['describe'] = describe;
    data['cover'] = cover;
    data['coverDetail'] = coverDetail;
    data['jumpUrl'] = jumpUrl;
    data['start'] = start;
    data['end'] = end;
    data['isEnd'] = isEnd;
    data['note'] = note;
    return data;
  }
}
