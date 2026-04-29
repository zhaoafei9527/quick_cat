//观看数万，亿展示

// 📦 Package imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/address.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/post_list_model.dart';

Future<MediaInfo?> getAdsMediaInfo(AdsType adsType) async {
  MediaInfo? adMedia;
  Advertise? ads = await LocalAdsStore().randomWhere(adsType);
  if (ads != null) {
    adMedia = MediaInfo(
      isAds: true,
      adsId: ads.id,
      desc: ads.description,
      adsPath: ads.href,
      title: ads.title ?? "",
      videoUrl: ads.href,
      coverImg: ads.cover ?? "",
    );
  }
  return adMedia;
}

Future<PostBrief?> getAdsPostInfo(AdsType adsType) async {
  PostBrief? adPost;
  Advertise? ads = await LocalAdsStore().randomWhere(adsType);
  if (ads != null) {
    adPost = PostBrief(
      isAds: true,
      adsId: ads.id,
      adsTitle: ads.title ?? "",
      adsCover: ads.cover,
      adsPath: ads.href,
    );
  }
  return adPost;
}

String getShowWatchNumberStr(num number, {int count = 0}) {
  number = number ?? 0;
  String numStr = "";
  if (number > 100000000) {
    var num0 = number / 100000000;

    numStr = "${num0.toStringAsFixed(count)}亿";
  } else if (number >= 10000) {
    var num = number / 10000;
    numStr = '${num.toStringAsFixed(count)}W';
  } else if (number >= 1000) {
    var num = number / 1000;
    numStr = '${num.toStringAsFixed(count)}K';
  } else {
    numStr = number.toStringAsFixed(0);
  }
  return numStr;
}

String getVideoRemotePath(String path) {
  String remotePath = "";
  if (path.startsWith("http") || path.startsWith("https")) {
    return path;
  }
  ShareKeys shareKeys = Get.find<ShareKeys>();
  // 拼接真实播放地址
  String domain =
      "${shareKeys.baseUrl}${Address.API_PREFIX}${Address.VIDEO_SUFFIX}";

  remotePath = "$domain/$path?token=${shareKeys.token}";

  return remotePath;
}
