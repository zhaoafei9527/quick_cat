// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:path/path.dart' as path;

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/address.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/src/cache_image.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/src/my_image_cache_manager.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';

class ImageLoader {
  String? address;
  String? loaderImg;
  String? remoteUri = Address.imgCdn;
  final double? width;
  final double? height;
  final bool? isGauss; // 是否高斯模糊
  final double? scale;
  final BoxFit? fit;
  final Color? color; // 图片的颜色  只针对PNG有效
  final Color? bgColor; // 图片背后的颜色 当填充不足时展示
  final Alignment? alignment;
  final double? radius;
  final Widget? placeholder;
  final Widget? loadError;
  final bool? thumb;
  final bool? showShimmer;
  final double? errorFontSize;
  final double? errorIconSize;
  final Animation<double>? opacity;

  ImageLoader.withP(this.address,
      {this.scale = 1.0,
      this.radius = .0,
      this.thumb = true,
      this.isGauss = false,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.alignment = Alignment.center,
      this.bgColor,
      this.color,
      this.placeholder,
      this.opacity,
      this.errorFontSize,
      this.errorIconSize,
      this.showShimmer = true, // 是否展示默认加载
      this.loadError});

  Widget load() {
    // if ((address ?? "").startsWith("v3/")) {
    //   return buildDefaultImage(showError: true);
    // }
    if ((address ?? "").isNotEmpty) {
      final decryptPath = address ?? "";
      if (!address!.startsWith("http") && !address!.startsWith("https")) {
        String imgCdn = Address.imgCdnV3 ?? "";
        address = path.join(imgCdn, "$address");
      }
      return ClipRRect(
          borderRadius: BorderRadius.circular(radius ?? 0),
          child: CachedNetworkImage(
              imageUrl: address ?? "",
              width: width,
              height: height,
              color: color,
              fit: fit ?? BoxFit.cover,
              // 图片填充方式
              cacheManager: MyImageCacheManager(),
              httpHeaders: {imageDecryptPathHeader: decryptPath},
              fadeInDuration: const Duration(milliseconds: 200),
              fadeOutDuration: const Duration(milliseconds: 300),
              imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
              placeholder: (context, url) => buildDefaultImage(),
              // 加载中的占位符
              errorWidget: (context, url, error) =>
                  buildDefaultImage() // 加载失败时的占位符
              ));
    } else {
      return buildDefaultImage();
    }
  }

  static Future<void> clearCache() async {
    await CachedImageConfig.clearAllCachedImages();
  }

  ImageProvider<Object> loadMemory() {
    ImageProvider<Object> content;
    if (!(address ?? "").contains("http")) {
      address = path.join(Address.imgCdn ?? "", address ?? "");
    }

    content = CachedImageProvider(address!);
    return content;
  }

  Widget buildDefaultImage({showError = false}) {
    return RepaintBoundary(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(radius ?? 0),
            child: Stack(alignment: Alignment.center, children: [
              Container(
                width: width,
                height: height,
                alignment: Alignment.center,
                color: const Color(0xFF222433),
                child: Image.asset(R.assetsImgImgDef,
                    width: height != null ? height! / 1.3 : Dimens.pt80),
              ),
              if (showError)
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.cloud_off_outlined,
                      size: errorIconSize ?? Dimens.pt80,
                      color: Colors.red.withOpacity(.5)),
                  Text("加载失败",
                      style: TextStyle(
                          fontSize: errorFontSize ?? Dimens.pt22,
                          color: Colors.red.withOpacity(.5))),
                ]),
            ])));
  }
}
