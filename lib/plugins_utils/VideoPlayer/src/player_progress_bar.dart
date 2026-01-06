// // 🐦 Flutter imports:
// import 'package:quick_cat_client/app/themes/theme_manager.dart';
// import 'package:flutter/material.dart';
//
// // 📦 Package imports:
// import 'package:chewie/chewie.dart';
// import 'package:chewie/src/progress_bar.dart';
// import 'package:get/get.dart';
//
// // import 'package:fvp/fvp.dart';
// import 'package:video_player/video_player.dart';
//
// // 🌎 Project imports:
// import 'package:quick_cat_client/app/model/home/video_play_model.dart';
// import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/player_ui_controls.dart';
// import '../../../app/themes/app_colors.dart';
//
// class PlayerProgressBar extends StatefulWidget {
//   final double height;
//   final ChewieController? uiController;
//   final VideoPlayerController controller;
//   final ChewieProgressColors colors;
//   final Function()? onDragStart;
//   final Function()? onDragEnd;
//   final Function(String)? onDragUpdate;
//   final List<SecondsPlayInfoModel>? playerSeconds;
//
//   PlayerProgressBar(
//     this.controller, {
//     this.height = 4,
//     this.uiController,
//     ChewieProgressColors? colors,
//     this.onDragEnd,
//     this.onDragStart,
//     this.onDragUpdate,
//     this.playerSeconds,
//     super.key,
//   }) : colors = colors ?? ChewieProgressColors();
//
//   @override
//   State<PlayerProgressBar> createState() => _PlayerProgressBarState();
// }
//
// class _PlayerProgressBarState extends State<PlayerProgressBar> {
//   Future<void> listener() async {
//     if (!mounted || isDragging) return;
//     Duration position = controller.value.position;
//     Duration duration = controller.value.duration;
//     var bufferedRanges = controller.value.buffered;
//     if (bufferedRanges.isNotEmpty) {
//       // 获取已缓冲的最后一个区间的结束时间
//       var bufferedEnd = bufferedRanges.last.end;
//       var totalDuration = controller.value.duration;
//       setState(() {
//         bufferedValue =
//             (bufferedEnd.inMilliseconds / totalDuration.inMilliseconds)
//                 .clamp(0.0, 1.0);
//       });
//     }
//     if (!controller.value.isBuffering && controller.value.isPlaying) {
//       setState(() {
//         progress = (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
//       });
//     }
//   }
//
//   bool _controllerWasPlaying = false;
//   Offset? _latestDraggableOffset;
//   double progress = 0.0;
//   double bufferedValue = 0.0;
//   bool isDragging = false;
//
//   VideoPlayerController get controller => widget.controller;
//
//   List<SecondsPlayInfoModel> get playerSeconds => widget.playerSeconds ?? [];
//
//   @override
//   void initState() {
//     super.initState();
//     controller.addListener(listener);
//   }
//
//   @override
//   void deactivate() {
//     controller.removeListener(listener);
//     super.deactivate();
//   }
//
//   // 更新进度
//   void updateProgress(double globalPosition, double maxWidth) {
//     final RenderBox box = context.findRenderObject() as RenderBox;
//     double localPosition = box.globalToLocal(Offset(globalPosition, 0)).dx;
//     setState(() {
//       progress = (localPosition / maxWidth).clamp(0.0, 1.0);
//     });
//   }
//
//   void _seekToRelativePosition(Offset globalPosition) {
//     controller.seekTo(context.calcRelativePosition(
//       controller.value.duration,
//       globalPosition,
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ThemeManager theme = Get.find<ThemeManager>();
//     return LayoutBuilder(builder: (context, constraints) {
//       double maxWidth = constraints.maxWidth;
//       return Container(
//           height: 20,
//           color: Colors.transparent,
//           child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onHorizontalDragStart: (DragStartDetails details) {
//                 if (!controller.value.isInitialized) {
//                   return;
//                 }
//                 isDragging = true;
//                 _controllerWasPlaying = controller.value.isPlaying;
//                 // if (_controllerWasPlaying) {
//                 //   controller.pause();
//                 // }
//                 widget.onDragStart?.call();
//               },
//               onHorizontalDragUpdate: (details) {
//                 if (!controller.value.isInitialized) {
//                   return;
//                 }
//                 updateProgress(details.globalPosition.dx, maxWidth);
//                 Duration prevTime = context.calcRelativePosition(
//                     controller.value.duration, details.globalPosition);
//                 String timeStr = getDurationTimeStr(prevTime);
//                 _latestDraggableOffset = details.globalPosition;
//                 listener();
//                 widget.onDragUpdate?.call(timeStr);
//               },
//               onHorizontalDragEnd: (DragEndDetails details) {
//                 if (_latestDraggableOffset != null) {
//                   updateProgress(_latestDraggableOffset!.dx, maxWidth);
//                   _seekToRelativePosition(_latestDraggableOffset!);
//                   _latestDraggableOffset = null;
//                 }
//                 isDragging = false;
//                 if (_controllerWasPlaying) {
//                   controller.play();
//                 }
//                 widget.onDragEnd?.call();
//               },
//               onTapDown: (details) {
//                 if (!controller.value.isInitialized) {
//                   return;
//                 }
//                 updateProgress(details.globalPosition.dx, maxWidth);
//               },
//               child: Stack(
//                   clipBehavior: Clip.none,
//                   alignment: Alignment.centerLeft,
//                   children: [
//                     // 最底层总的进度条
//                     buildBackBarView(),
//                     buildBackBarView(widthFactor: bufferedValue, opacity: .4),
//
//                     ...List.generate(
//                         playerSeconds.length,
//                         (index) => buildSecondsPointer(
//                             playerSeconds[index].duration,
//                             playerSeconds[index].desc,
//                             playerSeconds[index].isBoom,
//                             maxWidth)),
//                     FractionallySizedBox(
//                         widthFactor: progress,
//                         child: Stack(clipBehavior: Clip.none, children: [
//                           IgnorePointer(
//                               child: Container(
//                                   height: widget.height,
//                                   decoration: BoxDecoration(
//                                       color:
//                                           theme.getColor(ThemeColor.textYellow),
//                                       borderRadius: BorderRadius.circular(
//                                           widget.height)))),
//                           Positioned(
//                               top: -8,
//                               right: -10,
//                               child: Container(
//                                   width: 20,
//                                   height: 20,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(.2),
//                                       borderRadius: BorderRadius.circular(20)),
//                                   child: Center(
//                                       child: Container(
//                                           width: 10,
//                                           height: 10,
//                                           decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(10))))))
//                         ]))
//                   ])));
//     });
//   }
//
//   //
//   Widget buildSecondsPointer(
//       Duration? position, String? name, bool? isBoom, double maxWidth) {
//     Duration duration = controller.value.duration;
//     if (position == null || position.inSeconds >= duration.inSeconds) {
//       return const SizedBox();
//     }
//
//     double progress =
//         ((position.inSeconds) / duration.inSeconds).clamp(0.0, 1.0);
//     ThemeManager theme = Get.find<ThemeManager>();
//     return Positioned(
//         left: progress * maxWidth - 7,
//         child: Stack(alignment: Alignment.bottomCenter, children: [
//           SizedBox(
//               width: 5,
//               height: widget.uiController!.isFullScreen ? 45 : 35,
//               child: Center(
//                   child: Container(
//                       width: 7,
//                       height: widget.height,
//                       color: Color(0xFFB2B2B2).withOpacity(.7)))),
//           Text(name ?? "",
//               style: TextStyle(
//                   fontSize: widget.uiController!.isFullScreen ? 12 : 9,
//                   color: const Color(0xFFC5C1BE)))
//         ]));
//   }
//
//   Widget buildBackBarView(
//       {double widthFactor = 1,
//       double opacity = .3,
//       Color? color = const Color(0xFFB2B2B2)}) {
//     return Align(
//         alignment: Alignment.centerLeft,
//         child: FractionallySizedBox(
//             widthFactor: widthFactor, // 宽度占父容器宽度的20%
//             child: Container(
//                 height: widget.height,
//                 decoration:
//                     BoxDecoration(color: color!.withOpacity(opacity)))));
//   }
// }
