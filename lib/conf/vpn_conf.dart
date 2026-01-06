// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 🌎 Project imports:
import '../app/model/home/vpn_lines_model.dart';

// import 'package:flutter_v2ray/flutter_v2ray.dart';

class VpnConf {
  static String eventBusKey = "_key_for_line_info_id";

  static Map<String, dynamic> setVpnPlugin(
      {String? path, String? host, String? security, String? network}) {
    Map<String, dynamic> streamSettings = {};
    Map<String, dynamic> wsSettings = {};
    streamSettings["network"] = network ?? "ws";
    if ((network ?? "ws") == "ws") {
      wsSettings["path"] = path ?? "";
      wsSettings["headers"] = {"host": host ?? ""};
      streamSettings["wsSettings"] = wsSettings;
      streamSettings["security"] = security ?? "tls";
      streamSettings["tlsSettings"] = {"serverName": host ?? ""};
    }
    return streamSettings;
  }

  // static String getV2rayConfigPlugin(ProxyConfig? proxyConfig) {
  //   String config = "";
  //   String link = generateSsUrl(proxyConfig);
  //   if (link.isNotEmpty) {
  //     try {
  //       final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);
  //       config = v2rayURL.getFullConfiguration();
  //       Map<String, dynamic> jsonConfig = json.decode(config);
  //
  //       var servers = jsonConfig["outbounds"][0]["settings"]["servers"][0];
  //       servers["uot"] = true;
  //       servers["UoTVersion"] = 2;
  //       jsonConfig["outbounds"][0]["streamSettings"]["security"] = "none";
  //       // servers[0]["uot"] = true;
  //       // servers[0]["UoTVersion"] = 2;
  //
  //       if ((proxyConfig?.ss?.plugin ?? "").isNotEmpty) {
  //         jsonConfig["outbounds"][0]["streamSettings"] = VpnConf.setVpnPlugin(
  //             path: proxyConfig?.ss?.pluginOpts?.v2ray?.path ?? "",
  //             host: proxyConfig?.ss?.pluginOpts?.v2ray?.hostname ?? "",
  //             security: "tls",
  //             network: "ws");
  //       }
  //       config = json.encode(jsonConfig);
  //     } catch (error) {
  //       debugPrint("获取v2ray配置失败:$error");
  //     }
  //   }
  //
  //   return config;
  // }

  // 根据返回配置 获取 ss 连接配置
  static String generateSsUrl(ProxyConfig? ssConfig) {
    String ssUrl = "";
    try {
      String server = ssConfig?.ss?.server ?? "";
      int port = ssConfig?.ss?.port ?? 0;
      String cipher = ssConfig?.ss?.cipher ?? "";
      String password = ssConfig?.ss?.password ?? "";

      String userinfo = "$cipher:$password";
      String host = "$server:$port";
      ssUrl = "ss://${base64Url.encode(utf8.encode(userinfo))}@$host";
    } catch (error) {
      debugPrint("获取ss配置链接失败:$error");
    }

    return ssUrl;
  }

  static List<String> vpnPassSubnets = [
    "0.0.0.0/5",
    "8.0.0.0/7",
    "11.0.0.0/8",
    "12.0.0.0/6",
    "16.0.0.0/4",
    "64.0.0.0/2",
    "128.0.0.0/3",
    "160.0.0.0/5",
    "168.0.0.0/6",
    "172.0.0.0/12",
    "172.32.0.0/11",
    "173.0.0.0/8",
    "174.0.0.0/7",
    "192.0.0.0/9",
    "192.128.0.0/11",
    "192.160.0.0/13",
    "192.169.0.0/16",
    "192.170.0.0/15",
    "192.172.0.0/14",
    "192.176.0.0/12",
    "192.192.0.0/10",
    "193.0.0.0/8",
    "194.0.0.0/7",
    "196.0.0.0/6",
    "200.0.0.0/5",
    "240.0.0.0/4",
    "https://valqi.ydfyzaqd.com"
  ];
}
