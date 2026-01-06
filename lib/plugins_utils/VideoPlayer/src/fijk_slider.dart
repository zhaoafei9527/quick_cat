import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/model/home/topic_list_model.dart';
import '../../../app/model/home/video_play_model.dart';
import '../fijk_player.dart';

class FIJKSlider extends StatefulWidget {
  final double value;
  final double cacheValue;

  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  final double min;
  final double max;

  const FIJKSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.cacheValue = 0.0,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
  })  : assert(min <= max),
        assert(value >= min && value <= max);

  @override
  State<StatefulWidget> createState() {
    return _FIJKSliderState();
  }
}

class FIJKSliderColors {
  const FIJKSliderColors({
    this.playedColor = const Color.fromRGBO(251, 255, 255, 0.99),
    this.bufferedColor = const Color.fromRGBO(178, 178, 178, .7),
    this.cursorColor = const Color.fromRGBO(255, 255, 255, 0.99),
    this.baselineColor = const Color.fromRGBO(178, 178, 178, 0.25),
    this.showTimeColor = const Color.fromRGBO(178, 178, 178, 0.75),
  });

  final Color playedColor;
  final Color bufferedColor;
  final Color cursorColor;
  final Color baselineColor;
  final Color showTimeColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FIJKSliderColors &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  @override
  int get hashCode => Object.hash(
      playedColor, bufferedColor, cursorColor, baselineColor, showTimeColor);
}

class _FIJKSliderState extends State<FIJKSlider> {
  bool dragging = false;
  double dragValue = 0.0;

  static const double margin = 2.0;

  @override
  Widget build(BuildContext context) {
    // 归一化并裁剪在 [0,1]
    double total =
        (widget.max - widget.min) <= 0 ? 1.0 : (widget.max - widget.min);
    double v = ((widget.value - widget.min) / total).clamp(0.0, 1.0);
    double cv = widget.cacheValue;

    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(left: margin, right: margin),
        height: double.infinity,
        width: double.infinity,
        color: Colors.transparent,
        child:
            CustomPaint(painter: _SliderPainter(v, cv, dragging, widget.max)),
      ),
      onHorizontalDragStart: (DragStartDetails details) {
        setState(() {
          dragging = true;
        });
        dragValue = widget.value;
        widget.onChangeStart?.call(dragValue);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        final box = context.findRenderObject() as RenderBox;
        final dx = details.localPosition.dx;
        dragValue = (dx - margin) / (box.size.width - 2 * margin);
        dragValue = max(0, min(1, dragValue));
        dragValue = dragValue * (widget.max - widget.min) + widget.min;
        widget.onChanged(dragValue);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        setState(() {
          dragging = false;
        });
        widget.onChangeEnd?.call(dragValue);
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double v;
  final double cv;
  final double duration;

  final bool dragging;
  final Paint pt = Paint();

  final FIJKSliderColors colors;

  _SliderPainter(this.v, this.cv, this.dragging, this.duration,
      {FIJKSliderColors? colors})
      : colors = colors ?? const FIJKSliderColors();

  @override
  void paint(Canvas canvas, Size size) {
    double lineHeight = min(size.height / 2, 2);
    pt.color = colors.baselineColor;

    double radius = min(size.height / 2, 4);
    // draw background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromPoints(Offset(0, size.height / 2 - lineHeight),
              Offset(size.width, size.height / 2 + lineHeight)),
          Radius.circular(.0)),
      pt,
    );

    final double value = v * size.width;

    // draw played part
    pt.color = colors.playedColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromPoints(Offset(0, size.height / 2 - lineHeight),
              Offset(value, size.height / 2 + lineHeight)),
          Radius.circular(.0)),
      pt,
    );

    // draw cached part
    double cacheValue = cv * size.width;

    // 当缓存已接近末尾时，避免留下 1px 视觉空隙
    if ((size.width - cacheValue).abs() <= 1.0) {
      cacheValue = size.width;
    }
    if (cacheValue > value && cacheValue > 0) {
      pt.color = colors.bufferedColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromPoints(Offset(value, size.height / 2 - lineHeight),
                Offset(cacheValue, size.height / 2 + lineHeight)),
            Radius.circular(.0)),
        pt,
      );
    }

    FIJKPlayerManager manager = FIJKPlayerManager();
    MediaInfo? media = manager.mediaPlayModel?.mediaInfo;
    List<SecondsPlayInfoModel> showTimes = media?.showTime ?? [];
    for (int i = 0; i < showTimes.length; i++) {
      pt.color = colors.showTimeColor;
      int time = showTimes[i].duration?.inMilliseconds ?? 0;
      // 计算当前时间点占总时间的比例
      double value = 0;
      if (duration > 0) {
        value = (time / (duration - .0)) * size.width;
      }
      // 根据时间绘制进度条上的小线条
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromPoints(Offset(value - 3, size.height / 2 - lineHeight),
                Offset(value + 3, size.height / 2 + lineHeight)),
            Radius.circular(.0)),
        pt,
      );

      // 绘制描述文本
      TextSpan span = TextSpan(
          text: showTimes[i].name ?? '',
          style: TextStyle(color: Color(0xFF83827E), fontSize: 9));
      TextPainter textPainter =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      textPainter.layout();
      // 计算文本位置
      double textX = value - textPainter.width / 2;
      double textY = size.height / 2 + lineHeight + 4; // 在进度条下方
      Offset textOffset = Offset(textX, textY);
      // 绘制文本
      textPainter.paint(canvas, textOffset);
    }

    // draw circle cursor
    pt.color = colors.cursorColor;
    pt.color = pt.color.withAlpha(max(0, pt.color.alpha - 100));
    radius = min(size.height / 2, dragging ? 10 : 5);
    canvas.drawCircle(Offset(value, size.height / 2), radius, pt);
    pt.color = colors.cursorColor;
    radius = min(size.height / 2, dragging ? 6 : 3);
    canvas.drawCircle(Offset(value, size.height / 2), radius, pt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SliderPainter && hashCode == other.hashCode;

  @override
  int get hashCode => Object.hash(v, cv, dragging, colors);

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return hashCode != oldDelegate.hashCode;
  }
}
