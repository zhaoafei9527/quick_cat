// 🎯 Dart imports:
import 'dart:convert';
import 'dart:math' hide log;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

// 🌎 Project imports:
import 'package:acgn_client/app/dialog/common_dialog.dart';
import 'package:acgn_client/app/dialog/update_dialog.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/conf/config.dart';
import 'package:acgn_client/utils/heart_beat.dart';
import 'package:acgn_client/utils/light_model.dart';
import 'package:acgn_client/utils/logger_utils.dart';
import 'package:acgn_client/utils/toast_util.dart';
import '../../conf/api_res.dart';
import '../../plugins_utils/HttpRequester/HttpRequester.dart';
import '../model/home/config_model_model.dart';
import '../model/home/user_info_model.dart';
import '../model/user_balance_model.dart';
import '../notifier/bus_events.dart';
import 'address.dart';
import 'enum.dart';

class ShareKeys extends GetxController {
  // ----------------- 常量 Key ------------------
  static const String keyForConf = "_key_share_key_config${AppConfig.DEBUG}";
  static const String keyForUuid = "_key_share_key_uuid${AppConfig.DEBUG}";
  static const String keyForToken = "_key_share_key_token${AppConfig.DEBUG}";
  static const String keyForUserInfo =
      "_key_share_key_user_info${AppConfig.DEBUG}";
  static const String keyLanguage = "_key_local_language${AppConfig.DEBUG}";
  static const String keyForVersion =
      "_key_set_version_update${AppConfig.DEBUG}";
  static const String gameHistoryKey =
      "_key_set_game_history${AppConfig.DEBUG}";
  static const String playerBoomStatus =
      "_key_set_player_boom${AppConfig.DEBUG}";

  // ---------------- 全局配置参数 ----------------
  late ConfigModel model;
  late UserInfo userInfo = UserInfo();
  Rx<UserInfo> rxUserInfo = UserInfo().obs;

  VersionBean? version;
  RunningLight? runningLight;

  /// m3u8 视频解密密钥内容
  dynamic m3u8SecretContent;

  /// cdn加密key
  String? cdnKey;

  /// 请求TOKEN
  String token = "";

  /// uuid
  String deviceId = "";

  /// baseUrl
  String baseUrl = "";

  /// 公告信息，全局变量;
  Announcement? announceInfo;

  /// 首页tabs
  List<MediaCategory> homeCategory = [];
  List<MediaCategory> cartoonCategory = [];
  List<MediaCategory> novelCategory = [];
  List<MediaCategory> mediaCategory = [];
  List<MediaCategory> dMediaCategory = [];
  List<MediaCategory> mediaTagType = [];

  /// 金刚区按钮部分配置
  Map<MediaType, List<gridItemModel>>? gridItemMap;

  /// 社区tabs
  List<MediaCategory> postCategory = [];

  /// 短视频排序
  List<String> shortMediaSortList = [];

  /// 长视频排序
  List<String> longMediaSortList = [];

  // HGame列表
  List<MediaCategory> hGameTypeList = [];

  /// 视频当前tab位置
  var tabIndex = 0.obs;

  // 播放线路
  int lineIndex = 0;

  // 震动模式
  bool canOpen = false;

  // 是否已经先试过账号凭证
  bool showAccounted = false;

  bool isNewUser = false;

  // 系统消息是否已读
  RxBool systemRead = false.obs;
  RxBool customRead = false.obs;
  Heartbeat? heartbeat;

  @override
  void onInit() async {
    shortMediaSortList = ["最新更新", "最多观看"];
    longMediaSortList = [...shortMediaSortList, "最多评论"];
    if (kIsWeb) {
      heartbeat = Heartbeat();
      heartbeat!.start(time: 30, beatFunc: webWorkerCheckVersion);
    } else {
      // heartbeat = Heartbeat();
      // heartbeat!.start(
      //     time:  30,
      //     beatFunc: () async {
      //       print("心跳检测");
      //       // randomNotifier();
      //       // final String line =
      //       //     await NetWorkCreator.startChooseBaseLine(useCatch: false);
      //       // if (line.isEmpty) return;
      //       // NetOptions.instance.setBaseUrl(line);
      //     });
    }
    canOpen = await lightKV.getBool(playerBoomStatus) ?? false;
    super.onInit();
  }

  /// ------------------ 配置初始化 ---------------------

  /// 根据配置初始化全局变量，并保存相关数据到本地缓存
  init(ConfigModel config) {
    model = config;
    initAddressConf(config);
    version = config.version;
    runningLight = config.runningLight;
    announceInfo = config.announcement;
    homeCategory = config.comicsCategory ?? [];
    cartoonCategory = config.cartoonCategory ?? [];
    novelCategory = config.novelCategory ?? [];
    mediaCategory = config.mediaCategory ?? [];
    dMediaCategory = config.dMediaCategory ?? [];
    postCategory = config.postCategory ?? [];
    gridItemMap = config.gridItemMap ?? {};
    mediaTagType = config.mediaTagType ?? [];
    hGameTypeList = config.hGameTypeList ?? [];
    lightKV.setString(keyForVersion, json.encode(config.version));
    lightKV.setString(keyForConf, json.encode(config.toJson()));
    log.i("shareKey_init", "ShareKeys 初始化完成");
  }

  /// 获取配置（先从本地缓存中读取）
  Future<ConfigModel> getConf() async {
    try {
      String? confStr = await lightKV.getString(keyForConf);
      if (confStr == null || confStr.isEmpty) {
        throw Exception("未找到配置缓存");
      }
      Map<String, dynamic> confMap = json.decode(confStr);
      ConfigModel conf = ConfigModel.fromJson(confMap);
      initAddressConf(conf);
      cdnKey = conf.cdnKey;
      announceInfo = conf.announcement;
      return conf;
    } catch (e) {
      log.e("getConf", "读取配置失败：$e");
      return ConfigModel();
    }
  }

  /// 根据配置初始化地址（存储到 Address 全局变量）
  void initAddressConf(ConfigModel conf) {
    conf.domain?.forEach((it) {
      it.urls ??= [];
      if (it.urls!.isEmpty) return;
      switch (it.type) {
        case "API":
          lightKV.setStringList(AppConfig.KEY_SERVER_LINES, it.urls!);
          break;
        case "VID":
          Address.videoCdn = it.urls![Random().nextInt(it.urls!.length)];
          break;
        case "IMAGE":
          Address.imgCdn = it.urls![Random().nextInt(it.urls!.length)];
          break;
        case "LAND":
          Address.officeUrl = it.urls![Random().nextInt(it.urls!.length)];
          break;
        case "APPCENTER":
          Address.appCenter = it.urls![Random().nextInt(it.urls!.length)];
          break;
        case "POTATO":
          Address.patato = it.urls![Random().nextInt(it.urls!.length)];
          break;
        case "MAIL":
          Address.mail = it.urls![Random().nextInt(it.urls!.length)];
          break;
        case "TWITTER":
          Address.twitter = it.urls![Random().nextInt(it.urls!.length)];
          break;
        case "INSTAGRAM":
          Address.instagram = it.urls![Random().nextInt(it.urls!.length)];
          break;
        case "LUOLIMSG":
          Address.luoliMsg = it.urls![Random().nextInt(it.urls!.length)];
          break;
        default:
          break;
      }
    });
  }

  /// ------------------ 用户相关 ---------------------

  /// 初始化登录信息（游客登录成功后调用）
  Future<void> initLogin(String deviceId, UserInfo model) async {
    userInfo = model;
    await lightKV.setString(keyForUuid, deviceId);
    await lightKV.setString(keyForToken, model.token ?? "");
    await lightKV.setString(keyForUserInfo, json.encode(model.toJson()));
  }

  /// 判断是否 VIP 用户
  bool isVip() {
    return (userInfo.vipType ?? 0) >= 1;
  }

  /// 获取最新的用户信息（可选择是否通过接口更新）
  Future<UserInfo> getUserInfo({bool needUpdate = false}) async {
    try {
      String? userStr = await lightKV.getString(keyForUserInfo);
      if (userStr != null && userStr.isNotEmpty) {
        Map<String, dynamic> userMap = json.decode(userStr);
        userInfo = UserInfo.fromJson(userMap);
      }
    } catch (e) {
      log.e("getUserInfo", "解析用户信息失败：$e");
    }
    if (needUpdate) {
      userInfo = await ApiRes.getUpdateUserInfo() ?? UserInfo();
    }
    return userInfo;
  }

  /// 更新用户信息并通知相关界面更新
  Future<UserInfo> setUserInfo(UserInfo? model) async {
    userInfo = model ?? UserInfo();
    if ((model?.token ?? "").isNotEmpty) {
      token = model!.token!;
      await NetWorkCreator.init(newToken: model.token!);
      await lightKV.setString(keyForToken, model.token!);
    }
    await lightKV.setString(keyForUserInfo, json.encode(model?.toJson()));
    eventBus.emit(
        BusType(EventsBusKey.subUpdateUserInfo, arguments: {"updated": true}));
    return userInfo;
  }

  Future<String?> getToken() async {
    token = await lightKV.getString(keyForToken) ?? "";
    return token;
  }

  Future<String?> getUuId() async {
    deviceId = await lightKV.getString(keyForUuid) ?? "";
    return deviceId;
  }

  Future<String?> getBaseUrl() async {
    baseUrl = await lightKV.getString(NetWorkCreator.keyForBaseUri) ?? "";
    return baseUrl;
  }

  /// ------------------ 用户余额 ---------------------

  /// 获取并更新用户余额数据
  Future<void> getUserBalance() async {
    try {
      UserBalanceModel? model = await ApiRes.getUserBalance();
      if (model != null && model.code == 0) {
        userBalance.value =
            _formatBalanceString(model.data?.balance?.toString());
        userTransferable.value = model.data?.transferable ?? "0.0";
      } else {
        showTypeToast(msg: "操作过于频繁，稍后再试");
      }
    } catch (e) {
      log.e("getUserBalance", "获取用户余额异常：$e");
    }
  }

  /// ------------------ 其他 ---------------------

  /// 设置播放震动状态（例如某些交互效果）
  void setPlayerBoomStatus(bool? status) {
    canOpen = status ?? false;
    lightKV.setBool(playerBoomStatus, canOpen);
  }

  /// ------------------ 版本检查 ---------------------

  /// 检查 APP 版本更新（仅非 Web 环境下弹窗更新）
  Future<void> checkAppVersion() async {
    try {
      if (version != null && (version?.hasNewVersion ?? false) && !kIsWeb) {
        await showUpdateVersionDialog(Get.context!, version: version);
      }
    } catch (error) {
      showToast(msg: "版本检查出错");
      log.e("checkAppVersion", "版本检查异常：$error");
    }
  }

  /// ------------------ 心跳检测 ---------------------
  /// （仅 Web 环境下使用，通过心跳检测检查版本更新）
  Future<void> webWorkerCheckVersion() async {
    try {
      ConfigModel? config = await ApiRes.getAppConfig();
      if (kIsWeb && (config?.version?.hasNewVersion ?? false)) {
        heartbeat?.stop(); // 停止心跳避免重复弹窗
        showPlayerCommonDialog(
          Get.context!,
          title: "友情提示",
          content: "检测到APP版本更新，请点击立即更新获取更好的体验～",
          btnList: ["稍后更新", "立即更新"],
          btnCall: [
            () {
              Get.back();
              heartbeat!.start(time: 30, beatFunc: webWorkerCheckVersion);
            },
            () async {
              Get.back();
              html.window.location.href = Routes.SPLASH_PAGE;
            }
          ],
          btnActionIndex: 1,
        );
      }
    } catch (e) {
      log.e("webWorkerCheckVersion", "版本检测异常：$e");
    }
  }

  /// ------------------ 用户余额相关 Rx 变量 ---------------------
  RxString userBalance = "0.00".obs;
  RxString userTransferable = "0.0".obs;
  RxDouble balanceRefreshTurns = 0.0.obs;

  /// 统一格式化余额字符串，保证显示两位小数
  String _formatBalanceString(String? value) {
    final parsed = double.tryParse(value ?? "") ?? 0.0;
    return parsed.toStringAsFixed(2);
  }
}
