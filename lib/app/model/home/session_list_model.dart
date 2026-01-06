// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class SessionList extends BaseNetModel {
  @override
  SessionList fromJson(Map<String, dynamic> json) {
    return SessionList.fromJson(json);
  }

  List<DevicesInfo>? list;

  SessionList({this.list});

  SessionList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <DevicesInfo>[];
      json['list'].forEach((v) {
        list?.add(DevicesInfo.fromJson(v));
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

class DevicesInfo {
  String? id;
  bool? isCurrent;
  String? name;

  DevicesInfo({this.id, this.isCurrent, this.name});

  DevicesInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isCurrent = json['isCurrent'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['isCurrent'] = isCurrent;
    data['name'] = name;
    return data;
  }
}
