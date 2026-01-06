import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MarqueeRich extends StatefulWidget {
  final TextSpan text;
  final double velocity; // 滚动速度（单位：像素/帧）
  final double gap; // 每条文字之间的间距
  final double height;

  const MarqueeRich({
    super.key,
    required this.text,
    this.velocity = 1.0,
    this.gap = 40.0,
    this.height = 30.0,
  });

  @override
  State<MarqueeRich> createState() => _MarqueeState();
}

class _MarqueeState extends State<MarqueeRich> with SingleTickerProviderStateMixin {
  late final ScrollController _controller;
  late final Ticker _ticker;
  double _position = 0;
  late RichText _cachedRichText;
  bool _hasContentSize = false;
  double _contentWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _updateRichText();
    _ticker = createTicker((_) {
      if (!_hasContentSize) return;
      _position += widget.velocity;

      if (_controller.hasClients) {
        final maxScrollExtent = _controller.position.maxScrollExtent;

        if (_position >= maxScrollExtent) {
          _position = 0;
          _controller.jumpTo(0);
        } else {
          _controller.jumpTo(_position);
        }
      }
    });

    // 启动 ticker 在第一帧之后，避免 UI 报错
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateContentWidth();
      _ticker.start();
    });
  }

  void _updateRichText() {
    _cachedRichText = RichText(text: widget.text);
  }

  @override
  void didUpdateWidget(MarqueeRich oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _updateRichText();
      _updateContentWidth();
    }
  }

  void _updateContentWidth() {
    final textPainter = TextPainter(
      text: widget.text,
      textDirection: TextDirection.ltr,
    )..layout();

    setState(() {
      _contentWidth = textPainter.width;
      _hasContentSize = true;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: SizedBox(
            height: widget.height,
            child: ListView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) {
                  return Row(
                      children: [_cachedRichText, SizedBox(width: widget.gap)]);
                })));
  }
}
