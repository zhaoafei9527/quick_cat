// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

class FastCachedProgressData {
  ///[downloadedBytes] 表示下载的图像大小（以字节为单位）。当图像完全下载时，该值会增加并达到 [totalBytes]。
  int downloadedBytes;

  // 图片总大小
  int? totalBytes;

  ///[progressPercentage] 给出图像的下载进度
  ValueNotifier<double> progressPercentage;

  ///[isDownloading] will be true if the image is to be download, and will be false if the image is already in the cache
  bool isDownloading;

  ///[FastCachedProgressData] 如果要下载图像则为 true，如果图像已在缓存中则为 false
  FastCachedProgressData(
      {required this.progressPercentage,
      required this.totalBytes,
      required this.downloadedBytes,
      required this.isDownloading});
}
