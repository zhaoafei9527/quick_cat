// 🌎 Project imports:
import 'package:acgn_client/conf/config.dart';
import '../../utils/light_model.dart';
import '../../utils/text_util.dart';

///地址数据
class Address {
  static const API_PREFIX = "/api/app";

  static const H5_SUFFIX = "/h5/app";

  ///视频播放地址后缀
  static const VIDEO_SUFFIX = "/media/m3u8";

  /// 基本的path
  static String? baseHost;

  /// 基本的path
  static String? baseApiPath;

  ///h5地址
  static String? h5Url;

  ///cdn地址，后台返回
  static String? videoCdn;

  static String? _imgCdn = "";

  ///图片加载地址
  static String? get imgCdn {
    if (TextUtil.isEmpty(_imgCdn ?? "")) {
      () async {
        _imgCdn =
            (await lightKV.getString("_key_last_img_cdn_${AppConfig.DEBUG}"))??"";
      }();
    }
    return _imgCdn;
  }

  static set imgCdn(String? c) {
    _imgCdn = c;
    lightKV.setString("_key_last_img_cdn_${AppConfig.DEBUG}", c!);
  }

  ///官网地址
  static String? officeUrl;

  ///应用中心
  static String? appCenter;

  ///官方社区
  static String? patato;

  ///官方邮箱
  static String? mail;

  ///官方联系方式
  static String? twitter;

  ///官方联系方式
  static String? instagram;

  static String? luoliMsg;

  ///通过支付宝API解析银行卡号发卡行和银行卡类别、获取银行LOGO
  static const ALI_CCD_API =
      "https://ccdcapi.alipay.com/validateAndCacheCardInfo.json?_input_charset=utf-8&cardBinCheck=true&cardNo=";
}
