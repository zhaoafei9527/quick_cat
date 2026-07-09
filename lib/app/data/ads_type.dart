// 🎯 Dart imports:
import 'dart:convert';
import 'dart:math';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/address.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import 'package:quick_cat_client/conf/config.dart';
import 'package:quick_cat_client/plugins_utils/FirebaseUtils/firebase_data.dart';
import '../../utils/array_util.dart';
import '../../utils/light_model.dart';
import '../../utils/text_util.dart';
import '../model/home/config_model_model.dart';

enum AdsType {
  /// 未定义位置,
  undef,

  ///首页Icon广告 1
  homeGameIconAds,

  /// 首页轮播图广告 2
  homeSwiperAds,

  /// 长视频播放页轮播图广告 3
  longVideoSwiperAds,

  /// 短视频头像广告 4
  shortVideoAvatarAds,

  /// 短视频切换插入广告 5
  shortVideoPlayAds,

  /// 弹窗下方广告 6
  popUpsAds,

  /// 评论区广告 7
  commentsAds,

  /// 游戏页面轮播图广告 8
  gameSwiperAds,

  /// 社区页轮播图广告 9
  communitySwiperAds,

  /// 社区页热门主题广告 10
  communityPopularTopicsAds,

  /// 我的页轮播广告 11
  minSwiperAds,

  /// 长视频列表插入广告 12
  longVideoListAds,

  /// 短视频列表插入广告 13
  shortVideoListAds,

  /// 启动页广告 14
  startupPageAds,

  /// 长视频播放前广告 15
  beforePlayingAds,

  /// 长视频播放器暂停广告 16
  longVideoPauseAds,

  /// 长视频播放器暂停广告 17
  minePageGameAds,

  /// 首页弹窗广告 18
  homePopUpsAds,

  /// 首页进入弹窗广告 19
  homePopUpsAdsCome,

  /// 首页呼吸广告按钮 20
  homeBreathingAds,

  // 吃瓜列表广告 21
  melonListAds,
}

class LocalAdsStore {
  static LocalAdsStore? _instance;

  factory LocalAdsStore() {
    _instance ??= LocalAdsStore._();
    return _instance!;
  }

  LocalAdsStore._();

  /// 获取某一个广告数据的列表
  Future<List<Advertise>> where(AdsType? adsType) async {
    if (adsType == null) return [];

    List<Advertise> resultList = await LocalAdsStore().getAllAds();
    if (ArrayUtil.isEmpty(resultList)) return [];

    ShareKeys shareKeys = Get.find();
    bool isVip = shareKeys.isVip();
    try {
      resultList = await FirebaseData()
          .mergeRemoteAdsToLocal(resultList)
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // Firebase 远程广告不可用时保留本地广告，避免阻塞启动流程。
    }
    bool isNewUser = shareKeys.isNewUser;
    List<Advertise> newList = resultList.where((it) {
      if (it.position != adsType.index) return false;
      // // VIP 过滤逻辑
      if ((isVip && (it.vipShow == false))) {
        return false;
      }

      // 新用户广告过滤逻辑
      if (it.newUserAds == true && !isNewUser) {
        // 不是新用户时，过滤掉新用户广告
        return false;
      }

      return true;
    }).toList();
    return newList;
  }

  ///获取某一个广告数据
  Future<Advertise?> firstWhere(AdsType adsType) async {
    List<Advertise>? list = await where(adsType);
    if (ArrayUtil.isNotEmpty(list!)) {
      return list.first;
    }
    return null;
  }

  ///随机获取某一个广告数据
  Future<Advertise?> randomWhere(AdsType adsType) async {
    var list = await where(adsType);
    if (ArrayUtil.isNotEmpty(list!)) {
      var index = Random().nextInt(list.length);
      return list[index];
    }
    return null;
  }

  List<Advertise> _adsList = [];

  ///获取本地存储的TAG信息
  Future<List<Advertise>> getAllAds() async {
    if (ArrayUtil.isNotEmpty(_adsList)) return _adsList;
    // 非共享key
    String? localAdsStr =
        await lightKV.getString("_key_ads_list${AppConfig.DEBUG}");
    try {
      if (TextUtil.isNotEmpty(localAdsStr!)) {
        _adsList = [
          ...(jsonDecode(localAdsStr) as List ?? [])
              .map((o) => Advertise.fromJson(o))
        ];
      }
    } catch (_) {}
    return _adsList;
  }

  Future<bool> setAdsList(List<Advertise> ads) async {
    if (ArrayUtil.isEmpty(ads)) return false;
    try {
      _adsList = ads;

      var adsJson = ads.map((it) {
        if (!it.cover!.startsWith("http")) {
          // print("在这里加上余名${it.cover},${Address.imgCdn}");
          String imgCdn = Address.imgCdnV3 ?? Address.imgCdn ?? "";
          it.cover = path.join(imgCdn, it.cover);
        }
        return it.toJson();
      }).toList();
      String jsonStr = json.encode(adsJson);
      if (TextUtil.isEmpty(jsonStr)) return false;
      // 非共享key
      lightKV.setString("_key_ads_list${AppConfig.DEBUG}", jsonStr);
      return true;
    } catch (e) {
      return false;
    }
  }

  ///清除记录
  clean() {
    lightKV.setString("_key_ads_list${AppConfig.DEBUG}", "");
  }
}
