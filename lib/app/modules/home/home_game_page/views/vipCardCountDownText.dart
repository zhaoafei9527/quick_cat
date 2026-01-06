import 'dart:async';

import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VipCardCountdownText extends StatefulWidget {
  final String? eventEndTime;
  final int? eventDays;

  const VipCardCountdownText({Key? key, this.eventEndTime, this.eventDays}) : super(key: key);

  @override
  State<VipCardCountdownText> createState() => _VipCardCountdownState();
}

class _VipCardCountdownState extends State<VipCardCountdownText> {
  late int remainSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if ((widget.eventDays ?? 0) > 0) {
      remainSeconds = 0;
    } else {
      remainSeconds = _getRemainSeconds(widget.eventEndTime);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (remainSeconds > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (remainSeconds > 1) {
          setState(() => remainSeconds -= 1);
        } else {
          setState(() => remainSeconds = 0);
          _timer?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    String renderText = "";
    if ((widget.eventDays ?? 0) > 0) {
      renderText = "${widget.eventDays}天";
    } else {
      renderText = _formatRemainTime(remainSeconds);
    }
    return Text("$renderText 后失效",
        style: TextStyle(
            fontSize: Dimens.pt26,
            color: theme.getColor(ThemeColor.textYellow)));
  }
}

int _getRemainSeconds(String? eventEndTime) {
  int remainSeconds = 0;
  final end = DateTime.tryParse(eventEndTime ?? "");
  if (end != null) {
    remainSeconds = end.difference(DateTime.now()).inSeconds;
    if (remainSeconds < 0) remainSeconds = 0;
  } else {
    remainSeconds = 0;
  }
  return remainSeconds;
}


String _formatRemainTime(int seconds) {
  if (seconds <= 0) return "00:00:00";
  int hour = seconds ~/ 3600;
  int minute = (seconds % 3600) ~/ 60;
  int second = seconds % 60;
  return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
}