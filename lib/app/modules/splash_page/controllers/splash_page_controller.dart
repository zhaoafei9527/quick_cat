// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/conf/config.dart';
import 'package:quick_cat_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/HttpRequester.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/light_model.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../../../data/ads_type.dart';
import '../../../data/share_key.dart';
import '../../../model/home/config_model_model.dart';
import '../../../model/home/user_info_model.dart';
import '../../../routes/app_pages.dart';

class SplashPageController extends GetxController {
  late Timer _timer;

  // 广告相关
  String? adId;
  var adsUri = "".obs;
  var adsCover = "".obs;

  // 倒计时（单位：秒）
  var countdownTime = 5.obs;

  // 线路选择状态
  var chooseLine = true.obs;
  var chooseErr = false.obs;

  // 线路选择失败后重试
  var retryChoose = false;

  // 是否显示“今日不再展示广告”标记（备用）
  var checkTodayNoShow = false.obs;

  // 整体初始化状态，true 表示初始化成功
  var initOk = true;

  // 是否已经进入home
  var entered = false;

  // 其他全局变量
  RxString channel = "".obs;
  RxString deviceId = "".obs;
  var showId = false.obs;
  late String xUserAgent;

  @override
  void onInit() async {
    super.onInit();
    try {
      // 获取设备ID和用户代理
      deviceId.value = await AppUtils.getDeviceId();
      if (deviceId.value.isEmpty) {
        await showToast(msg: "检测不到设备ID，请联系管理");
        return;
      }
      xUserAgent = await NetWorkCreator.userAgent(deviceId.value);
      // 开始初始化流程
      await startInit();
    } catch (e, stack) {
      log.e("SplashPageController.onInit", "初始化异常: $e", stackTrace: stack);
    }
  }

  Future<void> startInit({bool retry = false}) async {
    chooseErr.value = false;
    chooseLine.value = true;
    final ShareKeys shareKeys = Get.find();
    // 1. 选择线路
    final String line = await _chooseLine(retry);
    if (line.isEmpty) {
      return;
    }
    shareKeys.baseUrl = line;
    await lightKV.setString(ShareKeys.keyForToken, "");
    NetOptions.instance
        .addHeaders({"Authorization": null, "X-User-Agent": xUserAgent})
        .setBaseUrl(line)
        .create();

    // 4. 游客登录
    await _loginGuest();
    if (chooseErr.value) return;

    // 2. 初始化广告图片（从本地缓存或随机广告中获取）
    await _initSplashAds();
    if (chooseErr.value) return;

    // 3. 获取APP配置，并初始化共享参数
    await _getConfigAndInit();
    if (chooseErr.value) return;

    // 5. 初始化网络（例如 dio），并检查APP版本更新
    await NetWorkCreator.init();
    chooseLine.value = false;
    chooseErr.value = false;
    initOk = true;
    // await shareKeys.checkAppVersion();

    // 6. 开始倒计时，并获取用户余额
    startCountdownTimer();

    // 获取H游戏列表 和用户余额相关
    // _getHGameList();
    await shareKeys.getUserBalance();
  }

  // Future<void> _getHGameList() async {
  //   HGameResult? result = await ApiRes.getHGameList();
  //   if (result == null) return;
  //   final ShareKeys shareKeys = Get.find<ShareKeys>();
  //   shareKeys.hGameList = result.list ?? [];
  // }

  /// 选择线路（API : ping/check）
  Future<String> _chooseLine(bool retry) async {
    final t1 = DateTime.now();
    log.i("_time_diff", "开始选择线路");
    final String line =
        await NetWorkCreator.startChooseBaseLine(useCatch: !retry);
    final t2 = DateTime.now();
    log.i(
        "_time_diff", "选择线路完成: $line 耗时：${t2.difference(t1).inMilliseconds}ms");
    if (line.isEmpty) {
      await FirebaseUtils.firebaseLogEvent(
          eventName: "chooseLineError",
          routePath: Routes.SPLASH_PAGE,
          eventArgs: {"devicesId": deviceId.value, "channel": channel.value});
      await _handleError("未检测到线路，请检查网络后重试");
    }
    return line;
  }

  /// 获取APP配置（API : ping/config）并初始化
  Future<void> _getConfigAndInit() async {
    final t1 = DateTime.now();
    log.i("_time_diff", "开始获取配置文件");
    String apiKey = await NetWorkCreator.sign(ApiRes.conf);
    final Options options = Options(headers: {"x-api-key": apiKey});

    var response = await get<ConfigModel, ConfigModel>(ApiRes.conf,
        options: options, decodeType: ConfigModel());
    await response.when(success: (ConfigModel? model) async {
      if (model == null) return;
      await _initShareKeys(model);
      // 存储本地广告数据
      await LocalAdsStore().setAdsList(model.advertise ?? []);
    }, failure: (String msg, int code) async {
      if (!retryChoose) {
        retryChoose = true;
        startInit(retry: true); // 缓存线路失败后，重新选择线路
      }
      await _handleError("获取配置失败：msg=$msg/code=$code");
    });
    final t2 = DateTime.now();
    log.i("_time_diff", "配置获取完成，耗时：${t2.difference(t1).inMilliseconds}ms");
  }

  /// 游客登录（API : login/guest）
  Future<void> _loginGuest() async {
    final t1 = DateTime.now();
    log.i("_time_diff", "开始登录游客用户");
    Map? channelInfo = await AppUtils.getAppChannelInfo();
    channel.value = channelInfo["dc"] ?? "";
    String affCode = json.encode(channelInfo);
    String apiKey = await NetWorkCreator.sign(ApiRes.login);
    log.e("device_arg", "${deviceId.value}, $affCode");
    final Options options = Options(headers: {"x-api-key": apiKey});
    var response = await post<UserInfo, UserInfo>(ApiRes.login,
        options: options,
        data: {"devId": deviceId.value, "x xaffCode": affCode},
        decodeType: UserInfo());
    await response.when(success: (UserInfo? model) async {
      if (model == null) {
        await _handleError("游客登录失败：返回空数据");
        return;
      }
      final ShareKeys shareKey = Get.find<ShareKeys>();
      shareKey.isNewUser = model.isNewUser ?? false;
      shareKey.token = model.token ?? "";
      await NetWorkCreator.setToken(model.token ?? "");
      await shareKey.initLogin(deviceId.value, model);

      // 上传用户信息到 Firebase Analytics
      await FirebaseUtils.analytics.setUserId(id: "${model.id}");
      log.i("splash_user_login", "登录成功：${model.nickName}:${model.id}");
    }, failure: (String msg, int code) async {
      await _handleError("登录失败：msg=$msg/code=$code");
    });
    final t2 = DateTime.now();
    log.i("_time_diff", "登录游客用户完成，耗时：${t2.difference(t1).inMilliseconds}ms");
  }

  /// 初始化共享配置参数
  Future<void> _initShareKeys(ConfigModel model) async {
    final ShareKeys shareKey = Get.find<ShareKeys>();
    await shareKey.init(model);
  }

  /// 初始化广告数据
  Future<void> _initSplashAds() async {
    Advertise? ad = await LocalAdsStore().randomWhere(AdsType.startupPageAds);
    if (ad != null) {
      adsCover.value = ad.cover ?? "";
      adsUri.value = ad.href ?? "";
      adId = ad.id;
    }
  }

  /// 获取或设置“今日不再显示广告”的时间（存储键值）
  Future<String> getTodayNoShowTime({String? setTime}) async {
    final String key = "_key_set_no_show_today_time_${AppConfig.DEBUG}";
    if (setTime == null) {
      return await lightKV.getString(key) ?? "";
    } else {
      await lightKV.setString(key, setTime);
      return setTime;
    }
  }

  /// 统一错误处理：设置状态、显示提示、记录日志
  Future<void> _handleError(String msg) async {
    initOk = false;
    chooseErr.value = true;
    chooseLine.value = false;
    await showToast(msg: msg);
    log.e("SplashPageController", msg);
  }

  /// 开始倒计时，倒计时结束后进入首页（如果初始化成功）
  void startCountdownTimer() {
    const Duration oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (countdownTime.value < 1) {
        timer.cancel();
        if (initOk && !entered) {
          entered = true;
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        countdownTime.value--;
      }
    });
  }
}
