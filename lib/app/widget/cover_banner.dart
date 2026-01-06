// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:card_swiper/card_swiper.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:get/get.dart';
import '../../utils/dimens.dart';
import '../data/ads_type.dart';
import '../model/home/config_model_model.dart';
import '../themes/app_colors.dart';

///所有比例的广告多个
class CoverBanner extends StatefulWidget {
  final AdsType? adsType;
  final double? aspectRatio;
  final double? radius;
  final double? scale;
  final double? viewportFraction;
  final List<String>? list;
  final bool? showPlayBtn;
  final bool? showIndexPoint;
  final ValueChanged<Advertise>? onItemClick;
  final Function(int)? onIndexChange;

  const CoverBanner(
      {super.key,
      this.aspectRatio = 320 / 480,
      this.adsType,
      this.scale = 1,
      this.viewportFraction = 1,
      this.radius = .0,
      this.showPlayBtn = true,
      this.onItemClick,
      this.onIndexChange,
      this.showIndexPoint,
      this.list})
      : assert((list?.length ?? 0) >= 0 || null != adsType);

  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<CoverBanner> {
  /// 广告列表
  List<Advertise>? adsList;

  Color color = Colors.white;
  int actionIndex = 0;

  @override
  void initState() {
    super.initState();
    initAd();
  }

  initAd() async {
    adsList = [];
    if ((widget.list ?? []).isNotEmpty) {
      for (String item in widget.list ?? []) {
        adsList?.add(Advertise(cover: item));
      }
    } else if (widget.adsType != null) {
      adsList = await LocalAdsStore().where(widget.adsType) ?? [];
    }
    setState(() {});
  }

  onIndexChange(int index) {
    setState(() => actionIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if ((adsList ?? []).isEmpty) {
      return Container();
    }
    final ThemeManager theme = Get.find<ThemeManager>();
    return Stack(alignment: Alignment.bottomCenter, children: [
      AspectRatio(
          aspectRatio: widget.aspectRatio ?? 1,
          child: Swiper(
              autoplay: true,
              autoplayDelay: 5000,
              viewportFraction: widget.viewportFraction ?? 1.0,
              // scale: 1,
              onIndexChanged: (index) {
                onIndexChange(index);
                widget.onIndexChange?.call(index);
              },
              loop: ((adsList?.length ?? 0) > 1),
              itemBuilder: (c, index) {
                var model = adsList![index].cover;
                return GestureDetector(
                    onTap: () => widget.onItemClick?.call(adsList![index]),
                    child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    widget.radius ?? 0.0)),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(widget.radius ?? 0.0),
                                child: ImageLoader.withP(model ?? '',
                                        height: double.infinity,
                                        width: double.infinity,
                                        radius: widget.radius)
                                    .load()))));
              },
              itemCount: adsList?.length ?? 0)),
      if (widget.showIndexPoint ?? true)
        Padding(
            padding: EdgeInsets.only(bottom: Dimens.pt20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ...List.generate(
                  adsList?.length ?? 0,
                  (index) => Obx(
                        () => Container(
                            width:
                                actionIndex == index ? Dimens.pt18 : Dimens.pt8,
                            height: Dimens.pt8,
                            margin: EdgeInsets.only(right: Dimens.pt5),
                            decoration: BoxDecoration(
                                color: actionIndex == index
                                    ? theme
                                        .getColor(ThemeColor.textYellow)
                                        .withOpacity(.8)
                                    : theme
                                        .getColor(ThemeColor.primary)
                                        .withOpacity(.8),
                                borderRadius:
                                    BorderRadius.circular(Dimens.pt8))),
                      ))
            ]))
    ]);
  }
}
