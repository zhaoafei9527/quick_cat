// 🐦 Flutter imports:
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:flutter/widgets.dart';

// 🌎 Project imports:
import '../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../../utils/dimens.dart';
import '../data/ads_type.dart';
import '../model/home/config_model_model.dart';

///所有比例的广告单个
class AdView extends StatefulWidget {
  final AdsType? type;
  final double? width;
  final double? height;
  final double? radius;
  final Advertise? ad;

  const AdView(
      {super.key, this.type, this.width, this.height, this.radius, this.ad});

  @override
  _AdViewState createState() => _AdViewState();
}

class _AdViewState extends State<AdView> {
  Advertise? ad;

  @override
  void initState() {
    super.initState();
    ad = widget.ad;
    if (null == ad || widget.type != null) {
      () async {
        ad = await LocalAdsStore().randomWhere(widget.type!);
        if (mounted) setState(() {});
      }();
    }
  }

  @override
  void didUpdateWidget(covariant AdView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ad != widget.ad) {
      if (mounted) {
        setState(() => ad = widget.ad);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return null == ad
        ? Container()
        : GestureDetector(
            onTap: () {
              AppPages.jumpRouter(path: ad?.href, id: ad?.id);
            },

            child: ImageLoader.withP(ad?.cover ?? "",
                    radius: widget.radius,
                    width: widget.width ?? Dimens.pt700,
                    height: widget.height ?? Dimens.pt152)
                .load());
  }
}
