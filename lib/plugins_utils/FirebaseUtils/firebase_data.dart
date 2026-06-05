import 'dart:convert';


import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';

class FirebaseData {
  static final FirebaseData _instance = FirebaseData._internal();

  factory FirebaseData() => _instance;

  final FirebaseRemoteConfig _remoteConfig;

  FirebaseData._internal() : _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      // 设置 RemoteConfigSettings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 60), // 设置获取超时时间
        minimumFetchInterval: const Duration(seconds: 60 * 30), // 设置最小获取间隔
      ));

      await _remoteConfig.setDefaults(<String, dynamic>{
        'ads_overrides': '[]',
      });
      await _remoteConfig.fetchAndActivate();
    } catch (_) {}
  }



  /// 通用：获取字符串配置
  String getConfigValue(String key) {
    return _remoteConfig.getString(key);
  }

  /// 获取远程配置的广告列表
  Future<List<Advertise>> fetchRemoteAds() async {
    try {
      // await _remoteConfig.setMinimumFetchIntervalInSeconds(0); // 直接忽略缓存
      await _remoteConfig.fetchAndActivate(); // 激活从云端获取的参数

      final String raw = _remoteConfig.getString("ads_overrides");
      final dynamic decoded = json.decode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => Advertise.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// - 远程配置中存在某个 `id` 的广告时，覆盖本地该 id 的广告
  ///   （以远程列表为准，可以是 1 条或多条）
  /// - 远程中有新的 position，而本地没有，则直接追加到结果列表
  Future<List<Advertise>> mergeRemoteAdsToLocal(
      List<Advertise> localAds) async {
    final List<Advertise> remoteAds = await fetchRemoteAds();
    if (remoteAds.isEmpty) return localAds;

    // 按 id 聚合远程广告
    final Map<String, List<Advertise>> remoteById = {};
    for (final ad in remoteAds) {
      final String? pos = ad.id;
      if (pos == null) continue;
      remoteById.putIfAbsent(pos, () => []).add(ad);
    }

    final List<Advertise> result = [];
    final Set<String> handledIds = <String>{};

    // 用远程广告覆盖本地对应 id 的广告
    for (final local in localAds) {
      final String? pos = local.id;
      if (pos != null && remoteById.containsKey(pos)) {
        // 使用远程配置替换该广告位的全部广告
        result.addAll(remoteById[pos]!);
        handledIds.add(pos);
      } else {
        // 没有远程覆盖时，保留本地广告
        result.add(local);
      }
    }

    // 将仅存在于远程配置中的新 position 追加进来
    remoteById.forEach((pos, ads) {
      if (!handledIds.contains(pos)) {
        result.addAll(ads);
      }
    });

    return result;
  }

  /// 便捷方法：直接根据 AdsType 获取已经应用远程配置后的广告列表
  Future<List<Advertise>> getAdsByTypeWithRemote(
      AdsType adsType, List<Advertise> localAds) async {
    final merged = await mergeRemoteAdsToLocal(localAds);
    final int position = adsType.index;
    return merged.where((ad) => ad.position == position).toList();
  }
}
