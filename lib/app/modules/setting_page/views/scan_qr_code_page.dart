// 🐦 Flutter imports:
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/widget/common_app_bar.dart';
import '../../../../utils/dimens.dart';
import '../../../themes/app_colors.dart';
import '../../../widget/common_widget.dart';
import '../controllers/scan_qr_code_controller.dart';
import '../controllers/setting_page_controller.dart';

class ScanQrCodePageView extends GetView<ScanQrCodeController> {
  const ScanQrCodePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScanQrCodeController logic = Get.put(ScanQrCodeController());
    return Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: getCommonAppBar("账号凭证找回"),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            QRView(
                key: logic.qrKey,
                onQRViewCreated: logic.onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: Dimens.pt10,
                  borderLength: Dimens.pt50,
                  borderWidth: Dimens.pt10,
                  cutOutSize: kIsWeb
                      ? screen.screenWidth * 0.4
                      : screen.screenWidth * 0.7,
                )),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text("对准二维码，即可自动识别",
                  style: TextStyle(fontSize: Dimens.pt28, color: Colors.white)),
              SizedBox(height: Dimens.pt80),
              GestureDetector(
                  onTap: () {
                    logic.qrViewController?.pauseCamera();
                    Get.back();
                    SettingPageController settingPageController =
                        Get.find<SettingPageController>();
                    settingPageController.scanQRCodeFromImage();
                  },
                  child:
                      Image.asset(R.assetsImgIconScanPic, width: Dimens.pt140)),
              SizedBox(height: Dimens.pt10),
              Text("相册",
                  style: TextStyle(fontSize: Dimens.pt28, color: Colors.white)),
              SizedBox(height: Dimens.pt150 + screen.paddingBottom)
            ])
          ],
        ));
  }
}
