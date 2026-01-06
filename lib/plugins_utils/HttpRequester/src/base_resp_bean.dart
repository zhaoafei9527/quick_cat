/// 基础网络请求结构
/// 本来是业务层包装的一层东西，但是这个项目好像没用，用状态码代替了业务码
class BaseRespBean<T> {
  int? code;
  T? data;

  /// 后台提示
  String? tip;
  String? action;

  /// 是否加密
  bool? hash;

  /// 一般是code不为200的后端错误信息
  String? msg;

  /// 服务器时间，一切vip时间计算以服务器时间为准
  String? time;

  // String get avalibleMsg => TextUtil.isNotEmpty(tip) ? tip : msg;

  BaseRespBean(this.code,
      {this.data, this.msg, this.tip, this.hash = false, this.time});

  BaseRespBean.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'];
    tip = json['tip'];
    action = json['action'];
    msg = json['msg'];
    time = json['time'];
    hash = json['hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = this.code;
    data['data'] = this.data;
    data['tip'] = this.tip;
    data['action'] = this.action;
    data['msg'] = this.msg;
    data['time'] = this.time;
    data['hash'] = this.hash;
    return data;
  }
}


class BaseResp {

  int? code;
  String? msg;
  String? tip;
  String? action;
  String? time;
  bool? hash;

  BaseResp({this.code, this.msg, this.tip, this.action, this.time, this.hash});

  BaseResp.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    tip = json['tip'];
    action = json['action'];
    time = json['time'];
    hash = json['hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['msg'] = msg;
    data['tip'] = tip;
    data['action'] = action;
    data['time'] = time;
    data['hash'] = hash;
    return data;
  }
}