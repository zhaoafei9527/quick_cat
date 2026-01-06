// 🐦 Flutter imports:
import 'package:flutter/material.dart';

/// A custom Tab Indicator with a rounded underline of specified width.
class RoundUnderlineTabIndicator extends Decoration {
  /// Creates an underline style selected tab indicator with rounded ends.
  ///
  /// The [borderSide] and [insets] arguments must not be null.
  const RoundUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.wantToWith = 25.0,
  });

  /// The color and thickness of the underline.
  final BorderSide borderSide;

  /// The desired width of the underline.
  final double wantToWith;

  /// The insets to apply to the underline relative to the tab's boundary.
  final EdgeInsetsGeometry insets;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is UnderlineTabIndicator) {
      final leapBorderSide = BorderSide.lerp(a.borderSide, borderSide, t);
      final leapInsets = EdgeInsetsGeometry.lerp(a.insets, insets, t);
      if (leapInsets != null) {
        return UnderlineTabIndicator(
          borderSide: leapBorderSide,
          insets: leapInsets,
        );
      }
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is UnderlineTabIndicator) {
      final leapBorderSide = BorderSide.lerp(borderSide, b.borderSide, t);
      final leapInsets = EdgeInsetsGeometry.lerp(insets, b.insets, t);
      if (leapInsets != null) {
        return UnderlineTabIndicator(
          borderSide: leapBorderSide,
          insets: leapInsets,
        );
      }
    }
    return super.lerpTo(b, t);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(this, onChanged, wantToWith);
  }
}

/// The painter responsible for drawing the rounded underline.
class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, VoidCallback? onChanged, this.wantToWith)
      : super(onChanged);

  final RoundUnderlineTabIndicator decoration;
  final double wantToWith;

  BorderSide get borderSide => decoration.borderSide;

  EdgeInsetsGeometry get insets => decoration.insets;

  /// Calculates the rectangle for the underline indicator.
  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);

    // 计算 tab 的实际宽度
    double tabWidth = indicator.width;

    // 确保最小宽度
    if (tabWidth < 20) {
      tabWidth = 20;
    }

    // 计算下划线宽度(减去10,但不小于10)
    double underlineWidth = (tabWidth - 10).clamp(10.0, tabWidth);

    // 计算下划线的起始位置(居中)
    double startX = indicator.left + (tabWidth - underlineWidth) / 2;

    return Rect.fromLTWH(
      startX,
      indicator.bottom - borderSide.width,
      underlineWidth,
      borderSide.width,
    );
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size? size = configuration.size;
    final TextDirection? textDirection = configuration.textDirection;

    // Ensure size and textDirection are not null
    if (size == null || textDirection == null) return;

    final Rect rect = offset & size;
    final Rect indicator =
        _indicatorRectFor(rect, textDirection).deflate(borderSide.width / 2.0);

    final Paint paint = borderSide.toPaint()
      ..strokeCap = StrokeCap.round; // Rounded ends

    // Draw the underline
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
