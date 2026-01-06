// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import '../../r.dart';
import '../../utils/common_util.dart';
import '../../utils/dimens.dart';
import '../../utils/time_util.dart';
import '../model/home/topic_list_model.dart';

class LongVideoCover extends StatelessWidget {
  final MediaInfo? mediaInfo;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool? showCover;

  const LongVideoCover(MediaInfo this.mediaInfo,
      {this.width, this.onTap, this.height, this.showCover,super.key});

  @override
  Widget build(BuildContext context) {
    String? desc = mediaInfo?.desc ?? "";
    return GestureDetector(
        onTap: () async {
          if (onTap != null) {
            onTap?.call();
          } else {
            if (mediaInfo?.isAds ?? false) {
              AppPages.jumpRouter(path: mediaInfo?.adsPath,id: mediaInfo?.adsId);
            } else {
              Get.toNamed(Routes.VIDEO_PLAYER_PAGE,
                  arguments: {"id": "${mediaInfo?.id}"});
            }
          }
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildCover(),
          SizedBox(height: Dimens.pt10),
          Container(
              height: Dimens.pt38,
              alignment: Alignment.centerLeft,
              child: Text(mediaInfo?.title ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: Dimens.pt28,
                      color: (mediaInfo?.isAds ?? false)
                          ? const Color(0xFFFF6213)
                          : Colors.white))),
          Container(
            height: Dimens.pt35,
            alignment: Alignment.centerLeft,
            child: Text(desc.isNotEmpty ? desc : mediaInfo?.title ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Dimens.pt26, color: const Color(0xFF8A8785))),
          ),
          Row(children: [
            if (!(mediaInfo?.isAds ?? false)) ...[
              Text(TimeUtil.showDateBefore(mediaInfo?.addedTime ?? ""),
                  style: TextStyle(
                      fontSize: Dimens.pt22, color: const Color(0xFF8A8785))),
              const Spacer(),
              Image.asset(R.assetsImgIconCoverComment, width: Dimens.pt23),
              SizedBox(width: Dimens.pt10),
              Text("${mediaInfo?.comments ?? 0}",
                  style: TextStyle(
                      fontSize: Dimens.pt22, color: const Color(0xFF8A8785)))
            ]
          ])
        ]));
  }

  Widget buildCover({double? horizontal, double? vertical}) {
    double defaultWidth = width ?? Dimens.pt345;
    double defaultHeight = defaultWidth / 16 * 9;

    return Stack(alignment: Alignment.bottomCenter, children: [
      ImageLoader.withP(mediaInfo?.coverImg,
              height: defaultHeight,
          radius: Dimens.pt12, width: defaultWidth)
          .load(),
      Container(
          width: defaultWidth,
          height: Dimens.pt67 + (vertical ?? 0),
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.symmetric(
              horizontal: horizontal ?? Dimens.pt10,
              vertical: vertical ?? Dimens.pt10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Dimens.pt12),
                  bottomRight: Radius.circular(Dimens.pt12)),
              gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (!(mediaInfo?.isAds ?? false))
              Row(children: [
                Image.asset(R.assetsImgIconCoverPlay, width: Dimens.pt31),
                SizedBox(width: Dimens.pt5),
                Text(
                    getShowWatchNumberStr(mediaInfo?.watchTimes ?? 0, count: 1),
                    style:
                        TextStyle(fontSize: Dimens.pt22, color: Colors.white))
              ]),
            if (!(mediaInfo?.isAds ?? false))
              Row(children: [
                Text(TimeUtil.getHHNNSS(mediaInfo?.playTime ?? 0),
                    style:
                        TextStyle(fontSize: Dimens.pt22, color: Colors.white))
              ])
          ])),
      Positioned(
          top: 0,
          right: Dimens.pt30,
          child: (mediaInfo?.isAds ?? false)
              ? Image.asset(R.assetsImgTipCoverAds, width: Dimens.pt58)
              : Image.asset(
                  mediaInfo?.payType == 0
                      ? R.assetsImgTipCoverFree
                      : R.assetsImgTipCoverVip,
                  width: Dimens.pt58))
    ]);
  }
}
