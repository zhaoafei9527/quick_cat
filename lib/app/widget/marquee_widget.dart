// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:marquee/marquee.dart';

// 🌎 Project imports:
import '../../r.dart';
import '../../utils/dimens.dart';
import '../../utils/screen.dart';

class MarqueeWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? marqueeText;
  final double? width;
  final double? height;
  final Color? color;
  final Color? background;

  const MarqueeWidget(this.marqueeText,
      {this.color,
      this.height,
      this.width,
      this.background,
      this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
          width: width ?? screen.screenWidth,
          height: height ?? Dimens.pt30,
          margin: EdgeInsets.symmetric(horizontal: Dimens.pt10),
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt10),
          decoration: BoxDecoration(
              color: background ?? Colors.black,
              borderRadius: BorderRadius.circular(Dimens.pt45)),
          child: Center(
              child: Row(children: [
            Image.asset(R.assetsImgIconRunningLight, width: Dimens.pt15),
            SizedBox(width: Dimens.pt8),
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(top: Dimens.pt6),
                    child: Marquee(
                        text: marqueeText ?? "",
                        style: TextStyle(
                            color: color ?? Colors.white,
                            fontSize: Dimens.pt12),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 20.0,
                        velocity: 100.0,
                        pauseAfterRound: const Duration(seconds: 1),
                        startPadding: 10.0,
                        accelerationDuration: const Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: const Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut)))
          ]))),
    );
  }
}
