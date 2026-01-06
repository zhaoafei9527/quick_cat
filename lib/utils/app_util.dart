// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';
import 'dart:ui' as ui;

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/services_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

// 🌎 Project imports:
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/cut_info.dart';
import 'package:quick_cat_client/utils/array_util.dart';
import 'package:quick_cat_client/utils/brower_util.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/platform_util.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../app/data/share_key.dart';
import '../app/modules/home/controllers/home_controller.dart';
import '../conf/config.dart';
import 'light_model.dart';

class AppUtils {
  ///获取设备id

  static Future<String> getDeviceId() async {
    // 确保 Flutter 引擎已经初始化
    if (!(WidgetsBinding.instance.rootElement != null)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    String? uniqueID;
    try {
      if (GetPlatform.isWeb) {
        /// 先从Phone 中获取 uuid
        const uuid = Uuid();
        uniqueID = html.window.localStorage["uuid"] ?? uuid.v4();
      } else {
        if (GetPlatform.isIOS) {
          const secureStorage = FlutterSecureStorage();
          try {
            // 尝试从 Keychain 或 Keystore 获取存储的设备唯一 ID
            uniqueID = await secureStorage.read(key: 'device_unique_id');
            if (uniqueID == null) {
              // 如果没有存储的 ID，则生成一个新的 UUID
              const uuid = Uuid();
              uniqueID = uuid.v4(); // 生成一个唯一的 UUID
              await secureStorage.write(
                  key: 'device_unique_id',
                  value: uniqueID); // 将 UUID 存储到 Keychain 或 Keystore
            }
          } catch (e) {
            log.e("getDeviceId", "iOS平台获取设备ID失败: $e");
            const uuid = Uuid();
            uniqueID = uuid.v4();
          }
        } else if (GetPlatform.isAndroid) {
          try {
            const platform = MethodChannel("com.insert/device");
            uniqueID = await platform.invokeMethod("getDeviceId");
            ClipboardData? clipboardData =
                await Clipboard.getData(Clipboard.kTextPlain);
            // 判读剪切板是否包含UUID信息。 有的话使用剪切板UUID
            if (TextUtil.isNotEmpty(clipboardData?.text ?? "")) {
              RegExp regExp = RegExp(r'uuid=([^&"]+)');
              Iterable<RegExpMatch> matches =
                  regExp.allMatches(clipboardData?.text ?? "");
              for (var match in matches) {
                if (match.group(1) != null) {
                  uniqueID = match.group(1);
                  await platform
                      .invokeMethod("setDeviceId", {"uuid": uniqueID});
                }
              }
            }
          } catch (e) {
            log.e("getDeviceId", "Android平台获取设备ID失败: $e");
            uniqueID = "";
          }
        }
      }
    } catch (e) {
      log.e("getDeviceId", "获取设备ID失败: $e");
      uniqueID = "";
    }

    return uniqueID ?? "";
  }

  /// 获取设备信息
  static Future<String> getDevType() async {
    String devType = "";
    try {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (PlatformUtils.isAndroid) {
        var androidInfo = await deviceInfoPlugin.androidInfo;
        devType =
            "${androidInfo.brand}/${androidInfo.device}:${androidInfo.version.sdkInt}";
      } else if (PlatformUtils.isIOS) {
        var iosInfo = await deviceInfoPlugin.iosInfo;
        devType = "${iosInfo.systemName}:${iosInfo.systemVersion}";
      } else if (PlatformUtils.isWeb) {
        var webInfo = await deviceInfoPlugin.webBrowserInfo;

        devType = "${webInfo.browserName}:${webInfo.appVersion}";
      }
    } catch (e) {
      debugPrint("devType_getDevType()...error:$e");
    }
    return devType;
  }

  /// 获取修正后的pkgName
  static Future<String> getFixedPkgName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (kIsWeb) {
      return "web.train.driver.com";
    } else if (PlatformUtils.isAndroid) {
      return packageInfo.packageName;
    } else if (PlatformUtils.isIOS) {
      return "ios.${packageInfo.packageName}";
    } else {
      return "train.driver.com";
    }
  }

  static _setDeiceId(deviceId) {
    lightKV.setString("_key_share_key_uuid${AppConfig.DEBUG}", deviceId);
  }

  static Future<Locale> getLocalLanguage() async {
    Locale locale = const Locale("zh", "CN");
    // 读取本地语言配置
    String? language = await lightKV.getString(ShareKeys.keyLanguage);
    if ((language ?? "").isNotEmpty) {
      List<String> arr = language!.split(",");
      if (arr.isNotEmpty) {
        locale = Locale(arr[0], arr[1]);
      }
    }
    return locale;
  }

  static jumpToHome({int? index}) {
    Get.back();
    if (Get.currentRoute != "/home") {
      jumpToHome(index: index ?? 0);
    } else {
      Get.find<HomeController>().changeTabIndex(index ?? 0);
    }
  }

  static Future<void> captureAndDownloadImage(GlobalKey key) async {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    if (kIsWeb) {
      // Web平台的处理逻辑
      String base64String = base64Encode(pngBytes);
      final downloadBtn = html.document.getElementById("downloadImage");
      downloadBtn?.setAttribute("onclick", "downloadImage('$base64String')");
      downloadBtn?.click();
      showToast(msg: "图片已经保存到相册");
      Future.delayed(
          Duration(seconds: 2), () => downloadBtn?.setAttribute("onclick", ""));

      // final blob = html.Blob([pngBytes]);
      // final url = html.Url.createObjectUrlFromBlob(blob);
      // final anchor = html.AnchorElement(href: url)
      //   ..setAttribute("download", "账号凭证.png")
      //   ..click();
      // html.Url.revokeObjectUrl(url);
    } else {
      // 非Web平台的处理逻辑
      final directory = await path_provider.getTemporaryDirectory();
      final imagePath = '${directory.path}/分享.png';
      final file = File(imagePath);
      await file.writeAsBytes(pngBytes);
      // 保存图片到相册
      final result = await FlutterImageGallerySaver.saveFile(imagePath);
      showToast(msg: "图片已经保存到相册");
      // print('Image saved to Gallery: $result');
    }
  }

  static Future<Map> getAppChannelInfo() async {
    CutInfo cutInfo = CutInfo();

    try {
      if (kIsWeb) {
        String channelInfo = html.window.localStorage["channelInfo"] ?? "";
        if ((channelInfo).isNotEmpty) {
          List<String> cutInfoList = channelInfo.split("&");
          if (cutInfoList.isNotEmpty) {
            List<String> dcInfo = cutInfoList[0].split("=");
            if (dcInfo.isNotEmpty && ArrayUtil.indexExists(dcInfo, 1)) {
              cutInfo.dc = dcInfo[1];
            }
            if (ArrayUtil.indexExists(cutInfoList, 1)) {
              cutInfo.pc = cutInfoList[1];
            }
          }
        }

        /// 获取不到再从浏览器URL中获取
        if (cutInfo.dc == null) {
          Map params = parseUriParamsFromBrowser(Uri.base.toString());
          if (params["dc"] != null) cutInfo.dc = params["dc"];
          if (params["pc"] != null) cutInfo.dc = params["pc"];
        }
      } else {
        /// 获取渠道信息
        String channel = await getChannel();
        if (channel != "unknown") {
          cutInfo.dc = channel;
        }
        // 定义粘贴板信息 pc="" 用户邀请 dc="" 渠道商户 ?pc=&dc=
        ClipboardData? clipboardData =
            await Clipboard.getData(Clipboard.kTextPlain);
        if (TextUtil.isNotEmpty(clipboardData?.text ?? "")) {
          if ((clipboardData?.text ?? "").contains("dc") ||
              (clipboardData?.text ?? "").contains("pc")) {
            RegExp regExp = RegExp(r'pc=([^&"]+)|dc=([^&"]+)');
            Iterable<RegExpMatch> matches =
                regExp.allMatches(clipboardData?.text ?? "");

            for (var match in matches) {
              if (match.group(1) != null) {
                cutInfo.pc = match.group(1);
              }
              if (match.group(2) != null && (cutInfo.dc ?? '').isEmpty) {
                cutInfo.dc = match.group(2);
              }
            }
          }
        }
      }
      log.i("_get_app_channel_info", "dc=${cutInfo.dc},pc=${cutInfo.pc}");
    } catch (e) {
      log.i("_get_app_channel_info", "$e");
    }

    return cutInfo.toJson();
  }

  /// 一直检查权限如果用户没有同意
  static Future checkPermissionAlways() async {
    if (kIsWeb || !GetPlatform.isAndroid) return;
    // while (true) {
    var status = await Permission.storage.request();

    if (status.isGranted) return;
    // 展示无权限，去设置的对话框
    var val = await showPlayerCommonDialog(Get.context!,
        content: "为了避免您的账户丢失，请开启APP访问权限。",
        btnList: ["继续使用", "去开启"],
        showBalance: false,
        btnActionIndex: 1,
        btnCall: [
          () => Get.back(result: false),
          () => Get.back(result: true),
        ]);

    if (val ?? false) {
      // 跳转到应用配置界面
      openAppSettings();
    } else if (val ?? true) {
      return;
    }
    // await Future.delayed(Duration(seconds: 2));
    // }
  }

  ///获取渠道
  static Future<String> getChannel() async {
    String channel = "";
    if (Platform.isAndroid) {
      const platform = MethodChannel("com.insert/device");
      try {
        channel = await platform.invokeMethod("getChannel");
      } on PlatformException {
        channel = "unknown";
      }
    }
    return channel;
  }

  static Future<void> goToCustomServicePage() async {
    showLoadingDialog();
    ServicesModel? model = await ApiRes.getCustomServers();
    Get.back();
    String? queryString =
        (model?.sign!.split('?').length)! > 1 ? model?.sign?.split('?')[1] : '';
    ShareKeys shareKeys = Get.find<ShareKeys>();
    Get.toNamed(Routes.ACTIVITY_WEB_PAGE, arguments: {
      "title": "在线客服",
      "uri":
          "${shareKeys.baseUrl}/zoudoboh-h5service/?theme=theme1&$queryString"
    });
  }

  static Future<UploadImageRep?> uploadSingleImage(
      {Function(String)? onLocalPath, Function(double)? onProgress}) async {
    try {
      // 1. 选择图片
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        showTypeToast(msg: "未选择图片");
        return null;
      }
      onLocalPath?.call(pickedFile.path);
      final formData = dio.FormData.fromMap({
        "upload": await dio.MultipartFile.fromFile(pickedFile.path,
            filename: pickedFile.name),
      });

      UploadImageRep? rep = await ApiRes.uploadImg(
        formData: formData,
        onSendProgress: (c, t) => onProgress?.call(c / t),
      );
      if (rep != null) {
        showTypeToast(msg: "上传成功", toastType: ToastType.SUCCESS);
      } else {
        showTypeToast(msg: "上传失败");
      }
      return rep;
    } catch (e) {
      log.e("_upload_image_err", "uploadSingleImage error: $e");
      showTypeToast(msg: "图片上传异常");
      return null;
    }
  }
}
