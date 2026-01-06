// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:math' hide log;

// 🐦 Flutter imports:
import 'package:quick_cat_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/conf/config.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/src/base_resp_bean.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/src/default_net_decoder.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/src/dio_client.dart';
import 'package:quick_cat_client/utils/array_util.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/platform_util.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../../app/data/pubspec.dart';
import '../../app/data/share_key.dart';
import '../../utils/app_util.dart';
import '../../utils/light_model.dart';
import '../../utils/text_util.dart';

class NetWorkCreator {
  // 初始化 默认请求路线，根据线路随机切换
  static String? baseUrl;

  // 初始化 超时时间
  int? timeout;

  static String? token;

  // 初始化 默认请求头
  Map<String, dynamic>? headers;

  static String keyForBaseUri = "_key_share_key_base_uri${AppConfig.DEBUG}";

  static DateTime? get serverTime => _serverTime;

  // 初始化 dio 请求
  static Future<void> init({String? baseLine, String? newToken}) async {
    String? token = newToken ?? await getToken();
    String? baseUrl = baseLine ?? await lightKV.getString(keyForBaseUri);
    String? deviceId = await AppUtils.getDeviceId();
    String? xUserAgent = await userAgent(deviceId);

    log.i("NetWorkCreator_init", "开始初始化$baseUrl token:$token");

    if ((baseUrl ?? "").isEmpty) {
      baseUrl = await startChooseBaseLine();
    }

    NetOptions.instance
        .addHeaders({"Authorization": token, "X-User-Agent": xUserAgent})
        .setBaseUrl(baseUrl!)
        // 全局解析器
        .setHttpDecoder(DefaultNetDecoder.getInstance())
        // dio_http_cache
        .addInterceptor(DioCacheManager(CacheConfig(
          baseUrl: baseUrl,
        )).interceptor)
        // 数据缓存策略
        .addInterceptor(DioCacheInterceptor(
            options: CacheOptions(
          store: MemCacheStore(),
          policy: CachePolicy.forceCache,
          hitCacheOnErrorExcept: [401, 403],
          maxStale: const Duration(days: 7),
          priority: CachePriority.normal,
          cipher: null,
          keyBuilder: CacheOptions.defaultCacheKeyBuilder,
          allowPostMethod: false,
        )))
        // 允许打印log，默认未 true
        .enableLogger(false)
        .setConnectTimeout(const Duration(milliseconds: 15000))
        .create();
  }

  /// 效用服务器ping接口。尝试线路是否可用
  /// [concurrency] 并发请求数量
  static Future<String?> _pingCheckLines(List<String> routes) async {
    // 创建一个打乱顺序的线路列表
    List<String> shuffledRoutes = List.from(routes);
    Completer<String?> completer = Completer<String?>();

    Future<void> tryNext(int index) async {
      if (index >= shuffledRoutes.length) {
        // 所有线路都尝试完毕，完成 Completer
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        return;
      }
      if (ArrayUtil.indexExists(shuffledRoutes, index)) {
        String currentRoute = shuffledRoutes[index];
        _tryPingCheckDisPatch(currentRoute, completer, index,
            onTryNext: (index) => tryNext(index));
      }
    }

    await tryNext(0);
    return completer.future;
  }

  /// 读取并解密C 内容，得到CDN线路列表
  static Future<List<String>> _parseLineC(String line) async {
    List<String> parseLines = [];
    try {
      var response = await DioClient.dio.get(line);
      if (response.statusCode == 200) {
        if (response.data is List) {
          List<String> base64List = List<String>.from(response.data);
          for (String base64Str in base64List) {
            // 移除开头和结尾的引号
            String reversedBase64 = base64Str.replaceAll(RegExp(r'^"|"$'), '');
            String originalBase64 = reversedBase64.split('').reversed.join('');
            originalBase64 = originalBase64.replaceAll("/", '');
            // 反转base64字符串后 匹配移除前面的 = ，并添加到末尾
            originalBase64 = originalBase64.replaceAll("=", '');
            int remainder = originalBase64.length % 4;
            originalBase64 = originalBase64 + ("=" * (4 - remainder));
            // 解密base64字符串 得到 URI
            List<int> decodedBytes = base64Decode(originalBase64);
            String decodedJson = utf8.decode(decodedBytes);
            parseLines.add(decodedJson);
          }
        }
      }
    } catch (e) {
      log.i("_parse_lineB", "线路解密失败");
    }

    return parseLines;
  }

  /// 整体选线逻辑 如果存在B 就一直检测B B不存在或者B都检测不通过就再去找A重新下发B. 都不存在解密C
  static Future<String> startChooseBaseLine({bool? useCatch}) async {
    List<ConnectivityResult> connectResult;
    connectResult = await Connectivity().checkConnectivity();
    String checkLastLine = "";

    /// 检测网络环境是否可以进行选线
    if (!(connectResult.contains(ConnectivityResult.none))) {
      /// 优先上次成功线路 接口失败重新选线不走这里
      // if (useCatch ?? false) {
      //   String? prevLine = await lightKV.getString(keyForBaseUri);
      //   if ((prevLine ?? "").isNotEmpty) {
      //     checkLastLine = prevLine!;
      //   }
      // }

      /// 获取 之前API下发的线路B
      // if (checkLastLine.isEmpty) {
      //   List<String>? fileLines =
      //       await lightKV.getStringList(AppConfig.KEY_SERVER_LINES);
      //   if ((fileLines ?? []).isNotEmpty && !Pubspec.debug) {
      //     log.i("_ping_check_B", "检测到B线路 B逻辑执行 $fileLines");
      //     // 从打乱的线路组中依次尝试出最终线路
      //     checkLastLine = await _pingCheckLines(fileLines) ?? "";
      //   }
      // }

      /// 线路B 为空/不存在 本地列表 A 线路并重新下发B线路
      if (checkLastLine.isEmpty) {
        log.i("_ping_check_A", "线路检测A逻辑执行$checkLastLine");
        List<String> serverLines = AppConfig.serverLines ?? [];
        checkLastLine = await _pingCheckLines(serverLines) ?? "";
      }

      /// A 、 B线路组尝试完毕后依然没有 开始尝试C
      if (checkLastLine.isEmpty) {
        List<String> buckUpLines = Pubspec.getBackupLine();
        log.i("_ping_check_C", "线路检测C逻辑执行$buckUpLines");

        /// 依次一条一条解析C 在检查Ping 成功就不再继续。否则一直检查
        for (int i = 0; i < buckUpLines.length; i++) {
          /// 解密line C 下发的文件内容 得到CDN线路池
          List<String> parseLinesC = await _parseLineC(buckUpLines[i]);
          checkLastLine = await _pingCheckLines(parseLinesC) ?? "";

          /// 成功检查到线路 直接跳过不再执行
          if (checkLastLine.isNotEmpty) break;
        }
      }

      /// 初始化DIO base uri
      NetOptions.instance
          .setBaseUrl(checkLastLine)
          .setHttpDecoder(DefaultNetDecoder.getInstance())
          .enableLogger(false)
          .create();
      lightKV.setString(keyForBaseUri, checkLastLine);
    } else {
      showToast(msg: "检查到网络环境故障，请打开WIFI或移动蜂窝后重试");
    }
    return checkLastLine;
  }

  /// 尝试对线路进行 ping check
  static Future<void> _tryPingCheckDisPatch(
      String currentRoute, Completer<String?> completer, int index,
      {Duration timeout = const Duration(seconds: 5),
      Function(int)? onTryNext}) async {
    String path = "/api/app/ping/check";
    String fullPath = currentRoute + path;
    try {
      var resp = await DioClient.dio
          .get(fullPath,
              options: Options(
                  followRedirects: false,
                  validateStatus: (status) => status != null && status < 500))
          .timeout(timeout);
      if (resp.statusCode == 200) {
        BaseRespBean? baseResp;
        if (resp.data is Map) {
          baseResp = BaseRespBean.fromJson(resp.data);
        } else if (resp.data is String) {
          baseResp = BaseRespBean.fromJson(json.decode(resp.data));
        }
        if (baseResp?.code == 200) {
          log.i('_ping_check_successful:', currentRoute);
          if (!completer.isCompleted) {
            completer.complete(currentRoute);
          }
          return;
        } else {
          log.w('_ping_check_failed with code:',
              "${baseResp?.code}: $currentRoute");
          await onTryNext?.call(index + 1);
        }
      } else {
        log.w('_ping_check_failed with code:',
            "${resp.statusCode}: $currentRoute");
        await FirebaseUtils.firebaseLogEvent(
            eventName: "ping_check_failed",
            routePath: Get.currentRoute,
            eventArgs: {"line": currentRoute});
        await onTryNext?.call(index + 1);
      }
    } on DioException catch (e) {
      log.e("DioException on ", "$currentRoute: ${e.message}");
      await onTryNext?.call(index + 1);
    } catch (error) {
      log.e("Unexpected error on", "$currentRoute: $e");
      await onTryNext?.call(index + 1);
    }
  }

  ///生成签名
  static Future<String> sign(String path) async {
    Map<String, dynamic> signObj = {};
    int timestamp = getFixedCurTime().toUtc().millisecondsSinceEpoch ~/ 1000;

    signObj['nonce'] = const Uuid().v4();
    signObj['path'] = path;
    signObj['timestamp'] = timestamp.toString();
    signObj['token'] = await getToken();
    signObj['userAgent'] = await userAgent();
    var key = utf8.encode(AppConfig.ANTI_REPLAY_ATTACK_KEY);
    var bytes = utf8.encode(jsonEncode(signObj).toString());
    var sha1Encrypt = Hmac(sha1, key);
    var digest = sha1Encrypt.convert(bytes);
    return Future.value(
        'timestamp=$timestamp;sign=${digest.toString()};nonce=${signObj['nonce']}');
  }

  /// 服务器时间
  static DateTime? _serverTime;

  /// 服务器时间和本地时间的差值
  static int _diffTimeInSeconds = 0;

  /// 设置服务器时间
  static setServerTime(String serverTimeS) {
    if (TextUtil.isNotEmpty(serverTimeS)) {
      _serverTime = DateTime.tryParse(serverTimeS)!;
      log.i("_setServerTime", "$_serverTime");
      _diffTimeInSeconds = DateTime.now().difference(_serverTime!).inSeconds;
    }
  }

  /// 获取修复后的本地时间,应该是和服务器时间是同步的
  static DateTime getFixedCurTime() {
    return DateTime.now().add(Duration(seconds: -_diffTimeInSeconds));
  }

  static Future<String> getToken() async {
    return (await lightKV.getString(ShareKeys.keyForToken)) ?? '';
  }

  static Future<bool> setToken(String token) async {
    // 该key不共享，不放全局变量
    return lightKV.setString(ShareKeys.keyForToken, token);
  }

  /// deviceId 不为空的话，表示切换一次设备；
  static Future<String> userAgent([String? deviceId]) async {
    String oldUa = (await lightKV.getString("_key_user_agent")) ?? '';
    if (TextUtil.isEmpty(deviceId ?? "") && TextUtil.isNotEmpty(oldUa)) {
      return oldUa;
    }
    String newUa = (await _genUserAgent(deviceId)) ?? '';
    if (TextUtil.isNotEmpty(newUa)) lightKV.setString("_key_user_agent", newUa);
    return newUa;
  }

  static Future<String> _genUserAgent([String? deviceId]) async {
    if (TextUtil.isEmpty(deviceId ?? "")) {
      deviceId = await AppUtils.getDeviceId();
    }

    String devType = await AppUtils.getDevType();
    String sysType = "h5";
    if (kIsWeb) {
      if (devType.contains('iPhone') || devType.contains('iPad')) {
        sysType = "ios";
      } else if (devType.contains('Android') || devType.contains('Linux')) {
        sysType = "h5_android";
      } else {
        sysType = "h5_pc";
      }
    } else if (PlatformUtils.isIOS) {
      sysType = "ios";
    } else if (PlatformUtils.isAndroid) {
      sysType = "android";
    }
    String ver = Pubspec.version;
    String buildID = await AppUtils.getFixedPkgName();
    String? localLanguage = await lightKV.getString(ShareKeys.keyLanguage);
    String lang = "cn";
    if ((localLanguage ?? "").isNotEmpty) {
      var arr = localLanguage!.split(",");
      if (arr.length > 2) lang = arr[2];
    }
    String ua = "DevID=${Uri.encodeComponent(deviceId ?? "")};"
        "DevType=${Uri.encodeComponent(devType)};"
        "SysType=${Uri.encodeComponent(sysType)};"
        "Ver=$ver;"
        "BuildID=${Uri.encodeComponent(buildID)};";
    return ua;
  }
}
