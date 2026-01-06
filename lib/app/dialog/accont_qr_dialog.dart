// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/app_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import '../data/address.dart';
import '../model/home/qrmodel.dart';

GlobalKey repaintBoundaryKey = GlobalKey();

Future showAccountQrDialog(BuildContext context,
    {String? title,
    String? content,
    List<InlineSpan>? attachedText,
    List<String>? btnList,
    int? btnActionIndex = 0}) async {
  ThemeManager theme = Get.find<ThemeManager>();
  return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            child: SizedBox(
                width: Dimens.pt630,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  RepaintBoundary(
                      key: repaintBoundaryKey, child: const QrCodeView()),
                  SizedBox(height: Dimens.pt30),
                  GestureDetector(
                      onTap: () async {
                        await ApiRes.saveUserQrCodeTask();
                        await AppUtils.captureAndDownloadImage(
                            repaintBoundaryKey);
                        Get.back();
                      },
                      child: Container(
                          height: Dimens.pt74,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimens.pt74),
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFEBD6),
                                    Color(0xFFFFD6A9)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight)),
                          child: Center(
                              child: Text("立即保存",
                                  style: TextStyle(
                                      fontSize: Dimens.pt26,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5E3D05))))))
                ])));
      });
}

class QrCodeView extends StatefulWidget {
  const QrCodeView({super.key});

  @override
  State<QrCodeView> createState() => _QrCodeViewState();
}

class _QrCodeViewState extends State<QrCodeView> {
  String? qrValue;

  @override
  void initState() {
    super.initState();
    _getQrcodeNetData();
  }

  _getQrcodeNetData() async {
    QrModel? model = await ApiRes.getUserQrCode();
    if (model != null) {
      setState(() {
        qrValue = model.value ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = Dimens.pt700 + Dimens.pt110;
    ThemeManager theme = Get.find<ThemeManager>();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    return Container(
        height: height,
        decoration: BoxDecoration(
            color: Color(0xFF1B1B1B),
            borderRadius: BorderRadius.circular(Dimens.pt20)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
              child: Text("为了防止账号丢失",
                  style: TextStyle(
                      fontSize: Dimens.pt64,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))),
          Center(
              child: Text("请保存账号凭证",
                  style: TextStyle(
                      fontSize: Dimens.pt36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))),
          SizedBox(height: Dimens.pt20),
          (qrValue ?? "").isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.pt20),
                  child: QrImageView(
                      data: qrValue ?? "",
                      version: QrVersions.auto,
                      size: Dimens.pt500,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(18)),
                )
              : getLoadingWidget(color: AppColors.primaryColor),
          SizedBox(height: Dimens.pt20),
          Text("快猫视频永久域名:${Address.officeUrl ?? ""}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Dimens.pt30, color: Colors.white)),
          SizedBox(height: Dimens.pt15)
        ]));
  }
}
