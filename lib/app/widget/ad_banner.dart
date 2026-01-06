// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:card_swiper/card_swiper.dart';

// 🌎 Project imports:
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import '../../utils/array_util.dart';
import '../../utils/dimens.dart';
import '../data/ads_type.dart';
import '../model/home/config_model_model.dart';

///所有比例的广告多个
class AdBanner extends StatefulWidget {
  final AdsType? adsType;
  final double? aspectRatio;
  final double? radius;
  final double? scale;
  final double? viewportFraction;
  final List<Advertise>? list;
  final bool? showPlayBtn;
  final ValueChanged<Advertise>? onItemClick;
  final Function(int)? onIndexChange;

  const AdBanner(
      {super.key,
      this.aspectRatio = 320 / 480,
      this.adsType,
      this.scale = 1,
      this.viewportFraction = 1,
      this.radius = .0,
      this.showPlayBtn = true,
      this.onItemClick,
      this.onIndexChange,
      this.list})
      : assert((list?.length ?? 0) >= 0 || null != adsType);

  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  /// 广告列表
  List<Advertise>? adList;

  Color color = Colors.white;

  @override
  void initState() {
    super.initState();
    initAd();
  }

  initAd() async {
    if (ArrayUtil.isNotEmpty(widget.list ?? [])) {
      adList = widget.list;
    } else {
      adList = await LocalAdsStore().where(widget.adsType);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if ((adList ?? []).isEmpty) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: widget.aspectRatio ?? 1,
        child: Swiper(
            autoplay: true,
            autoplayDelay: 5000,
            viewportFraction: widget.viewportFraction ?? 1.0,
            scale: 0.9,
            onIndexChanged: (index) => widget.onIndexChange?.call(index),
            loop: ((adList?.length ?? 0) > 1),
            pagination: SwiperCustomPagination(builder: (context, config) {
              // 总条数
              int itemCount = config.itemCount ?? 0;
              // 当前索引
              int activeIndex = config.activeIndex ?? 0;
              var model = adList?[activeIndex];
              return Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: Dimens.pt12),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Visibility(
                        visible: widget.showPlayBtn!,
                        child: GestureDetector(
                            // onTap: () {
                            //   if (null != widget.onItemClick) {
                            //     widget.onItemClick?.call(model);
                            //   } else {
                            //     JRouter().handleAdsInfo(model?.href);
                            //   }
                            // },
                            )),
                    // if (config.itemCount > 1)
                    //   Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: List.generate(
                    //           itemCount,
                    //           (index) => Container(
                    //               height: Dimens.pt4,
                    //               width: Dimens.pt16,
                    //               margin: EdgeInsets.only(left: Dimens.pt6),
                    //               decoration: BoxDecoration(
                    //                   color: index == activeIndex
                    //                       ? Colors.white
                    //                       : AppColors.shadowGrey,
                    //                   borderRadius:
                    //                       BorderRadius.circular(Dimens.pt12)))))
                  ]));
            }),
            itemBuilder: (c, index) {
              var model = adList![index];
              return GestureDetector(
                  onTap: () {
                    if (null != widget.onItemClick) {
                      widget.onItemClick?.call(model);
                    } else {
                      // JRouter().handleAdsInfo(model?.href);
                    }
                  },
                  child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimens.pt12),
                            border: Border.all(
                                color: Colors.white, width: Dimens.pt1 / 2)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.pt12),
                          child: ImageLoader.withP(model.cover ?? '',
                                  height: double.infinity,
                                  width: double.infinity,
                                  radius: widget.radius)
                              .load(),
                        ),
                      )));
            },
            itemCount: adList?.length ?? 0));
  }
}
