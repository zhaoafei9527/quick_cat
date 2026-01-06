// 🌎 Project imports:
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import '../../../plugins_utils/HttpRequester/http_requester.dart';

class HotSearchList extends BaseNetModel {
  @override
  HotSearchList fromJson(Map<String, dynamic> json) {
    return HotSearchList.fromJson(json);
  }

  List<MediaInfo>? list;

  HotSearchList({this.list});

  HotSearchList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <MediaInfo>[];
      json['list'].forEach((v) {
        list!.add(MediaInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
