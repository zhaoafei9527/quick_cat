// 🌎 Project imports:
import '../../plugins_utils/HttpRequester/src/base_net_model.dart';

class DanmuMsgsBySecond extends BaseNetModel {
  @override
  DanmuMsgsBySecond fromJson(Map<String, dynamic> json) {
    return DanmuMsgsBySecond.fromJson(json);
  }

  List<DanmuMsg>? barrages;
  int? publishAt;

  DanmuMsgsBySecond({this.barrages, this.publishAt});

  DanmuMsgsBySecond.fromJson(Map<String, dynamic> json) {
    if (null != json['details']) {
      barrages = <DanmuMsg>[];
      json['details'].forEach((e) {
        barrages?.add(DanmuMsg.fromJson(e));
      });
    }
    publishAt = json['publishAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['publishAt'] = publishAt;
    data['details'] = barrages?.map((e) => e.toJson()).toList();
    return data;
  }
}

class DanmuMsg {
  String? content;
  int? type;
  int? userId;
  int? vipType;

  DanmuMsg({this.content, this.type, this.vipType, this.userId});

  DanmuMsg.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    type = json['type'];
    userId = json['userId'];
    vipType = json['vipType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['type'] = type;
    data['userId'] = userId;
    data['vipType'] = vipType;
    return data;
  }
}

class NewDanmuMsg {
  String? content;
  int? mediaId;
  int? publishAt;

  NewDanmuMsg({this.content, this.mediaId, this.publishAt});

  NewDanmuMsg.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    mediaId = json['mediaId'];
    publishAt = json['publishAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['mediaId'] = mediaId;
    data['publishAt'] = publishAt;
    return data;
  }
}
