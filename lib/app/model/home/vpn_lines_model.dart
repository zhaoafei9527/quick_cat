// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class VpnLinesModel extends BaseNetModel {
  @override
  VpnLinesModel fromJson(Map<String, dynamic> json) {
    return VpnLinesModel.fromJson(json);
  }

  int? id;
  int? chargeType; // 收费类型 1 免费流量 2 收费 3 免费
  int? direction; // 节点方向 1. 出国线路 2 回国线路

  String? ip; // IP地址
  String? localeCode; // 国家类型
  int? online; // 在线人数

  String? name;
  String? desc;
  String? base64Url;
  bool? isCanUse;
  ProxyConfig? proxyConfig;
  int? proxyType;
  int? delay; // 延迟
  bool? checked; // 被选中
  String? proxyConfigText;

  VpnLinesModel(
      {this.id,
      this.chargeType,
      this.direction,
      this.ip,
      this.localeCode,
      this.online,
      this.name,
      this.desc,
      this.delay,
      this.checked = false,
      this.isCanUse = false,
      this.base64Url,
      this.proxyConfig,
      this.proxyConfigText,
      this.proxyType});

  VpnLinesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chargeType = json['chargeType'];
    ip = json['ip'];
    localeCode = json['localeCode'];
    isCanUse = json['isCanUse'];
    online = json['online'];
    name = json['name'];
    desc = json['desc'];
    delay = json['delay'];
    checked = json['checked'];
    base64Url = json['base64Url'];
    proxyConfigText = json['proxyConfigText'];
    proxyConfig = json['proxyConfig'] != null
        ? ProxyConfig?.fromJson(json['proxyConfig'])
        : null;
    proxyType = json['proxyType'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['chargeType'] = chargeType;
    data['ip'] = ip;
    data['localeCode'] = localeCode;
    data['isCanUse'] = isCanUse;
    data['online'] = online;
    data['name'] = name;
    data['desc'] = desc;
    data['checked'] = checked;
    data['base64Url'] = base64Url;
    data['proxyConfigText'] = proxyConfigText;

    if (proxyConfig != null) {
      data['proxyConfig'] = proxyConfig?.toJson();
    }
    data['proxyType'] = proxyType;
    return data;
  }
}

class NodeListModel extends BaseNetModel {
  @override
  NodeListModel fromJson(Map<String, dynamic> json) {
    return NodeListModel.fromJson(json);
  }

  List<VpnLinesModel>? all; // 所有节点列表
  List<VpnLinesModel>? freeList; // 免费节点列表
  List<VpnLinesModel>? goAbroadList; // 出国节点列表
  List<VpnLinesModel>? returnList; // 回国节点列表
  List<VpnLinesModel>? vipList; // VIP 节点列表

  NodeListModel(
      {this.all,
      this.freeList,
      this.goAbroadList,
      this.returnList,
      this.vipList});

  NodeListModel.fromJson(Map<String, dynamic> json) {
    if (json['all'] != null) {
      all = <VpnLinesModel>[];
      json['all'].forEach((v) {
        all?.add(VpnLinesModel.fromJson(v));
      });
    }
    if (json['freeList'] != null) {
      freeList = <VpnLinesModel>[];
      json['freeList'].forEach((v) {
        freeList?.add(VpnLinesModel.fromJson(v));
      });
    }

    if (json['goAbroadList'] != null) {
      goAbroadList = <VpnLinesModel>[];
      json['goAbroadList'].forEach((v) {
        goAbroadList?.add(VpnLinesModel.fromJson(v));
      });
    }

    if (json['returnList'] != null) {
      returnList = <VpnLinesModel>[];
      json['returnList'].forEach((v) {
        returnList?.add(VpnLinesModel.fromJson(v));
      });
    }
    if (json['vipList'] != null) {
      vipList = <VpnLinesModel>[];
      json['vipList'].forEach((v) {
        vipList?.add(VpnLinesModel.fromJson(v));
      });
    }
  }
}

class ProxyConfig {
  Ss? ss;
  String? type;
  Vmess? vmess;

  ProxyConfig({this.ss, this.type, this.vmess});

  ProxyConfig.fromJson(Map<String, dynamic> json) {
    ss = json['ss'] != null ? Ss?.fromJson(json['ss']) : null;
    type = json['type'];
    vmess = json['vmess'] != null ? Vmess?.fromJson(json['vmess']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (ss != null) {
      data['ss'] = ss?.toJson();
    }
    data['type'] = type;
    if (vmess != null) {
      data['vmess'] = vmess?.toJson();
    }
    return data;
  }
}

class Ss {
  String? cipher;
  String? password;
  String? plugin;
  PluginOpts? pluginOpts;
  int? port;
  String? server;
  bool? udp;

  Ss(
      {this.cipher,
      this.password,
      this.plugin,
      this.pluginOpts,
      this.port,
      this.server,
      this.udp});

  Ss.fromJson(Map<String, dynamic> json) {
    cipher = json['cipher'];
    password = json['password'];
    plugin = json['plugin'];
    pluginOpts = json['pluginOpts'] != null
        ? PluginOpts?.fromJson(json['pluginOpts'])
        : null;
    port = json['port'];
    server = json['server'];
    udp = json['udp'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cipher'] = cipher;
    data['password'] = password;
    data['plugin'] = plugin;
    if (pluginOpts != null) {
      data['pluginOpts'] = pluginOpts?.toJson();
    }
    data['port'] = port;
    data['server'] = server;
    data['udp'] = udp;
    return data;
  }
}

class PluginOpts {
  V2rayPlugin? v2ray;

  PluginOpts({this.v2ray});

  PluginOpts.fromJson(Map<String, dynamic> json) {
    v2ray = json['v2ray'] != null ? V2rayPlugin?.fromJson(json['v2ray']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (v2ray != null) {
      data['v2ray'] = v2ray?.toJson();
    }
    return data;
  }
}

class V2rayPlugin {
  String? hostname;
  String? mode;
  bool? tls;
  String? path;
  bool? fastOpen;
  int? mux;

  V2rayPlugin(
      {this.hostname, this.mode, this.tls, this.fastOpen, this.mux, this.path});

  V2rayPlugin.fromJson(Map<String, dynamic> json) {
    hostname = json['hostname'];
    mode = json['mode'];
    tls = json['tls'];
    fastOpen = json['fastOpen'];
    // mux = json['mux'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['hostname'] = hostname;
    data['mode'] = mode;
    data['tls'] = tls;
    data['fastOpen'] = fastOpen;
    // data['mux'] = mux;
    data['path'] = path;
    return data;
  }
}

class Vmess {
  int? alterId;
  String? cipher;
  String? network;
  int? port;
  String? server;
  bool? skipCertVerify;
  bool? tls;
  String? uUid;
  bool? upd;
  WsHeaders? wsHeaders;
  String? wsPath;

  Vmess(
      {this.alterId,
      this.cipher,
      this.network,
      this.port,
      this.server,
      this.skipCertVerify,
      this.tls,
      this.uUid,
      this.upd,
      this.wsHeaders,
      this.wsPath});

  Vmess.fromJson(Map<String, dynamic> json) {
    alterId = json['alterId'];
    cipher = json['cipher'];
    network = json['network'];
    port = json['port'];
    server = json['server'];
    skipCertVerify = json['skipCertVerify'];
    tls = json['tls'];
    uUid = json['uUid'];
    upd = json['upd'];
    wsHeaders = json['wsHeaders'] != null
        ? WsHeaders?.fromJson(json['wsHeaders'])
        : null;
    wsPath = json['wsPath'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['alterId'] = alterId;
    data['cipher'] = cipher;
    data['network'] = network;
    data['port'] = port;
    data['server'] = server;
    data['skipCertVerify'] = skipCertVerify;
    data['tls'] = tls;
    data['uUid'] = uUid;
    data['upd'] = upd;
    if (wsHeaders != null) {
      data['wsHeaders'] = wsHeaders?.toJson();
    }
    data['wsPath'] = wsPath;
    return data;
  }
}

class WsHeaders {
  String? additionalProp1;
  String? additionalProp2;
  String? additionalProp3;

  WsHeaders({this.additionalProp1, this.additionalProp2, this.additionalProp3});

  WsHeaders.fromJson(Map<String, dynamic> json) {
    additionalProp1 = json['additionalProp1'];
    additionalProp2 = json['additionalProp2'];
    additionalProp3 = json['additionalProp3'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['additionalProp1'] = additionalProp1;
    data['additionalProp2'] = additionalProp2;
    data['additionalProp3'] = additionalProp3;
    return data;
  }
}
