// // 🐦 Flutter imports:
// import 'package:flutter/material.dart';
//
// // 📦 Package imports:
// import 'package:chewie/chewie.dart';
// import 'package:chewie/src/notifiers/index.dart';
// import 'package:video_player/video_player.dart';
//
// // 🌎 Project imports:
// import 'package:quick_cat_client/utils/dimens.dart';
//
// class PlayerSettingPanel extends StatefulWidget {
//   final PlayerNotifier? notifier;
//   final VideoPlayerController controller;
//   final ChewieController? chewieController;
//   final bool? showSettingPanel;
//
//   const PlayerSettingPanel(
//       this.notifier, this.controller, this.chewieController,
//       {this.showSettingPanel, super.key});
//
//   @override
//   State<PlayerSettingPanel> createState() => _PlayerSettingPanelState();
// }
//
// String speedKey = "speedKey";
// String speedTitle = "播放速度";
// String qualityTitle = "画质";
// String barrageTitle = "弹幕";
// String key = "key", value = "value", select = "select";
//
// class _PlayerSettingPanelState extends State<PlayerSettingPanel>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animateController;
//   late double _animation;
//   late String? panelTitle;
//   late SettingType? settingType;
//   late int speedIndex;
//
//   bool get _showSettingPanel => widget.showSettingPanel ?? false;
//
//   PlayerNotifier? get _notifier => widget.notifier;
//
//   VideoPlayerController? get _controller => widget.controller;
//
//   ChewieController? get _chewieController => widget.chewieController;
//
//   @override
//   void initState() {
//     double begin = Dimens.pt75;
//     settingType = null;
//     // _notifier?.addListener(() =>_notifierListener());
//     _animateController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 300));
//     _animation = Tween(begin: begin, end: begin).evaluate(_animateController);
//
//     List<double>? speeds = [0.5, 0.75, 1, 1.75, 2];
//     speedIndex = speeds.indexWhere((element) => element == 1.0);
//     for (var i = 0; i < speeds.length; i++) {
//       settingKey[speedKey].add(
//           {value: speeds[i], key: "${speeds[i] == 1.0 ? "正常" : speeds[i]}"});
//     }
//     super.initState();
//   }
//
//   @override
//   void didUpdateWidget(oldWidget) {
//     super.didUpdateWidget(oldWidget);
//   }
//
//   @override
//   void dispose() {
//     // _notifier?.removeListener(() =>_notifierListener());
//     _animateController.dispose();
//     super.dispose();
//   }
//
//   void setPanelType(SettingType? type) {
//     settingType = type;
//     if (type == SettingType.playerSpeed) {
//       panelTitle = speedTitle;
//     } else if (type == SettingType.playerQuality) {
//       panelTitle = qualityTitle;
//     } else if (type == SettingType.playerBarrage) {
//       panelTitle = barrageTitle;
//     }
//     setState(() {});
//     _animateController.forward();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return positionWidget(child: containerAnimate());
//   }
//
//   Widget containerAnimate() {
//     return AnimatedBuilder(
//       animation: _animateController,
//       builder: (BuildContext context, Widget? child) {
//         double begin = Dimens.pt75, barrageEnd = Dimens.pt85, end = Dimens.pt75;
//
//         double speedEnd = Dimens.pt155, qualityEnd = Dimens.pt85;
//         if (settingType == SettingType.playerSpeed) {
//           end = speedEnd;
//         } else if (settingType == SettingType.playerQuality) {
//           end = qualityEnd;
//         } else if (settingType == SettingType.playerBarrage) {
//           end = barrageEnd;
//         }
//
//         var value = Tween(begin: begin, end: end).evaluate(_animateController);
//
//         return Container(
//           width: Dimens.pt135,
//           height: value,
//           decoration: BoxDecoration(
//               color: Colors.black.withOpacity(.85),
//               borderRadius: BorderRadius.circular(Dimens.pt6)),
//           child: child,
//         );
//       },
//       child:
//           Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//         if (settingType != null) ...[
//           _buildPanelHeader(),
//           Expanded(
//               child: Container(
//             padding: EdgeInsets.symmetric(horizontal: Dimens.pt5),
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   if (settingType == SettingType.playerSpeed)
//                     ...buildSpeedItem()
//                 ]),
//           ))
//         ] else ...[
//           _buildSettingMainItem(
//               speedTitle, settingKey[speedKey][speedIndex][key],
//               type: SettingType.playerSpeed),
//           _buildSettingMainItem(barrageTitle, "开启",
//               type: SettingType.playerBarrage),
//           _buildSettingMainItem(qualityTitle, "自动(720P)",
//               type: SettingType.playerQuality)
//         ]
//       ]),
//     );
//   }
//
//   List<Widget> buildSpeedItem() {
//     return List.generate(settingKey[speedKey].length ?? 0, (index) {
//       return GestureDetector(
//         onTap: () {
//           speedIndex = index;
//           double chosenSpeed = settingKey[speedKey][index][value];
//           _controller?.setPlaybackSpeed(chosenSpeed);
//         },
//         child: Row(children: [
//           SizedBox(
//               width: Dimens.pt16,
//               child: speedIndex == index
//                   ? Icon(Icons.check, size: Dimens.pt12, color: Colors.white)
//                   : const SizedBox()),
//           SizedBox(
//             width: Dimens.pt12,
//           ),
//           Text(settingKey[speedKey][index][key],
//               style: TextStyle(fontSize: Dimens.pt12, color: Colors.white))
//         ]),
//       );
//     });
//   }
//
//   Widget positionWidget({Widget? child}) {
//     bool isFullScreen = _chewieController?.isFullScreen ?? false;
//     double bottom = isFullScreen ? Dimens.pt100 : Dimens.pt50;
//     return Positioned(
//         right: Dimens.pt12,
//         bottom: bottom,
//         child: AnimatedOpacity(
//             opacity: _showSettingPanel ? 1.0 : 0.0,
//             duration: const Duration(milliseconds: 300),
//             child: child ?? const SizedBox()));
//   }
//
//   Widget _buildSettingMainItem(k, v, {SettingType? type}) {
//     return GestureDetector(
//       onTap: _showSettingPanel ? () => setPanelType(type) : () {},
//       child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: Dimens.pt10),
//           child:
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text(k,
//                 style: TextStyle(fontSize: Dimens.pt11, color: Colors.white)),
//             const Spacer(),
//             Text(v,
//                 style: TextStyle(fontSize: Dimens.pt11, color: Colors.white)),
//             SizedBox(width: Dimens.pt6),
//             Icon(Icons.arrow_forward_ios_rounded,
//                 size: Dimens.pt15, color: Colors.white)
//           ])),
//     );
//   }
//
//   Widget _buildPanelHeader() {
//     return Container(
//       height: Dimens.pt35,
//       padding: EdgeInsets.symmetric(horizontal: Dimens.pt10),
//       decoration: const BoxDecoration(
//           border: Border(bottom: BorderSide(color: Colors.grey))),
//       child: GestureDetector(
//           onTap: () async {
//             settingType = null;
//             await _animateController.reverse();
//           },
//           child: Row(children: [
//             Icon(Icons.arrow_back_ios_rounded,
//                 size: Dimens.pt12, color: Colors.white),
//             SizedBox(width: Dimens.pt5),
//             Text(panelTitle ?? "",
//                 style: TextStyle(fontSize: Dimens.pt12, color: Colors.white))
//           ])),
//     );
//   }
// }
//
// enum SettingType {
//   playerSpeed, // 播放速度面板
//   playerQuality, // 播放画质面板
//   playerBarrage, // 弹幕控制面板
// }
//
// Map<String, dynamic> settingKey = {"speedKey": []};
