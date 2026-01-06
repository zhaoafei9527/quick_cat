import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

/// 粘贴版信息
class CutInfo {
  // pc是邀请码promoteCode
  String? pc;

  /// dc是渠道 distinctCode
  String? dc;

  static CutInfo fromMap(Map<String, dynamic> map) {
    CutInfo cutInfo = CutInfo();
    cutInfo.pc = map['pc'];
    cutInfo.dc = map['dc'];
    return cutInfo;
  }

  Map toJson() => {"pc": pc, "dc": dc};
}

class UploadImageRep extends BaseNetModel {
  @override
  UploadImageRep fromJson(Map<String, dynamic> json) {
    return UploadImageRep.fromJson(json);
  }

  String? path;
  String? name;

  UploadImageRep({this.path, this.name});

  UploadImageRep.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['name'] = name;
    return data;
  }
}
