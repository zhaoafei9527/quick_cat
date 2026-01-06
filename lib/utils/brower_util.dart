// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:acgn_client/utils/toast_util.dart';

// ignore_for_file: deprecated_member_use

/// 浏览器跳转
openBrowser(String url,
    {String tip = "The browser cannot open the link"}) async {
  try {
    await launch(url, forceSafariVC: false, forceWebView: false);
    // if (!await canLaunch(url)) {
    //   await launch(url, forceSafariVC: false, forceWebView: false);
    // } else {
    //   await launch(url, forceSafariVC: false, forceWebView: false);
    //   showToast(msg: tip);
    // }
    return;
  } catch (e) {
    showToast(msg: tip);
    // l.e("browser", "openBrowser()...error:$e");
  }
  // showToast(msg: "error opening link");
}

/// 从浏览器打开微信
openWxFromBrowser() async {
  String url = "weixin://";
  openBrowser(url, tip: "Please install WeChat first");
}

/// 从浏览器解析URL参数

Map<String, String> parseUriParamsFromBrowser(String uri) {
  Uri parseUri = Uri.parse(uri);
  Map<String, String> params = {};
  List<String> uriList = parseUri.toString().split("?");
  if (uriList.length > 1) {
    String paramStr = uriList[uriList.length - 1];
    List<String> paramList = paramStr.split("&");

    for (var i = 0; i < paramList.length; i++) {
      String key = paramList[i].split("=")[0];
      String value = paramList[i].split("=")[1];
      params[key] = value;
    }
  }

  return params;
}
