// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import '../../../../conf/api_res.dart';
import '../../../routes/app_pages.dart';

class ScanQrCodeController extends GetxController {
  final qrKey = GlobalKey(debugLabel: 'QR');
  Rxn<Barcode> barcode = Rxn<Barcode>();
  QRViewController? qrViewController;
  RxString qrCodeContent = ''.obs;
  Rx<UserInfo> userInfo = UserInfo().obs;

  var urlValue = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo.value = shareKeys.userInfo;

    // 在这里执行初始化操作
    // getQrcode();
  }

  @override
  void onClose() {
    super.onClose();
    qrViewController?.dispose();
    qrViewController = null;
  }

  void onQRViewCreated(QRViewController controller) {
    qrViewController = controller;
    qrViewController?.scannedDataStream.listen((scanData) => name(scanData));
  }

  void name(scanData) async {
    try {
      barcode.value = scanData;
      if (scanData.code != null) {
        qrCodeContent.value = scanData.code;
        qrViewController?.pauseCamera(); //停止扫描
        UserInfo? userInfo = await ApiRes.scanQrCodeAndLogin(
            code: qrCodeContent.value,
            onError: (err) {
              showTypeToast(msg: "登录错误：$err");
            });
        if (userInfo != null) {
          final shareKeys = Get.find<ShareKeys>();
          await shareKeys.setUserInfo(userInfo);
          await shareKeys.getUserBalance();
          showTypeToast(msg: "二维码账号找回成功", toastType: ToastType.SUCCESS);
          Future.delayed(Durations.extralong4, () async {
            await Get.offAllNamed(Routes.HOME);
          });
        }
      }
    } catch (e) {
      qrViewController?.pauseCamera(); //停止扫描
      showTypeToast(msg: "扫描失败，请检测摄像头是否清晰");
    }
  }
}
