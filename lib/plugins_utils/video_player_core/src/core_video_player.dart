import 'dart:async';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

import 'core_video_cache_manager.dart';
import 'core_video_models.dart';

class CoreFijkVideoPlayer extends StatefulWidget {
  final CoreVideoItem item;
  final bool autoPlay;
  final bool prepareOnLoad;
  final bool loop;
  final double aspectRatio;
  final BoxFit fit;
  final FijkPlayer? player;
  final bool releasePlayerOnDispose;
  final bool fs;
  final Color? backgroundColor;
  final CoreVideoCacheConfig cacheConfig;
  final CoreVideoCoverBuilder? coverBuilder;
  final CoreVideoPlaceholderBuilder? placeholderBuilder;
  final CoreVideoPanelBuilder? panelBuilder;
  final CoreVideoOverlayBuilder? overlayBuilder;
  final ValueChanged<CoreVideoPlaybackState>? onStateChanged;
  final ValueChanged<String>? onPlayableUrlResolved;
  final VoidCallback? onCompleted;

  const CoreFijkVideoPlayer({
    super.key,
    required this.item,
    this.autoPlay = true,
    this.prepareOnLoad = false,
    this.loop = false,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.contain,
    this.player,
    this.releasePlayerOnDispose = true,
    this.fs = false,
    this.backgroundColor,
    this.cacheConfig = const CoreVideoCacheConfig(),
    this.coverBuilder,
    this.placeholderBuilder,
    this.panelBuilder,
    this.overlayBuilder,
    this.onStateChanged,
    this.onPlayableUrlResolved,
    this.onCompleted,
  });

  @override
  State<CoreFijkVideoPlayer> createState() => _CoreFijkVideoPlayerState();
}

class _CoreFijkVideoPlayerState extends State<CoreFijkVideoPlayer> {
  FijkPlayer? _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _bufferingSub;
  CoreVideoPlaybackState _state = const CoreVideoPlaybackState();
  String? _playableUrl;
  int _operationToken = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load(widget.item.url));
  }

  @override
  void didUpdateWidget(covariant CoreFijkVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.url != widget.item.url ||
        oldWidget.player != widget.player) {
      unawaited(_load(widget.item.url));
    }
  }

  Future<void> _load(String url) async {
    final token = ++_operationToken;
    _playableUrl = null;
    _emit(const CoreVideoPlaybackState());
    await _detachPlayer(release: _player != widget.player);
    final player = widget.player ?? FijkPlayer();
    _player = player;
    player.addListener(_onPlayerChanged);
    _positionSub = player.onCurrentPosUpdate.listen((position) {
      _emit(_state.copyWith(position: position));
    });
    _bufferingSub = player.onBufferStateUpdate.listen((buffering) {
      _emit(_state.copyWith(buffering: buffering));
    });

    var playableUrl = url;
    if (widget.cacheConfig.enabled) {
      try {
        playableUrl = await CoreVideoCacheManager().preparePlayableUrl(
          url,
          cacheAheadSegmentCount: widget.cacheConfig.aheadSegmentCount,
        );
      } catch (_) {
        // 缓存代理解析失败回退到原始地址，避免一直停在加载中。
        playableUrl = url;
      }
    }
    if (!mounted || token != _operationToken) return;
    _playableUrl = playableUrl;
    widget.onPlayableUrlResolved?.call(playableUrl);

    // 同地址且已经处于非 Idle 状态：保留当前播放，避免重复 setDataSource。
    if (player.dataSource == playableUrl &&
        player.state != FijkState.idle &&
        player.state != FijkState.end &&
        player.state != FijkState.error) {
      return;
    }

    // 非 Idle 状态先 reset，避免 ijk 抛出 IllegalStateException。
    if (player.state != FijkState.idle &&
        player.state != FijkState.end &&
        player.state != FijkState.error) {
      try {
        await player.reset();
      } catch (_) {}
      if (!mounted || token != _operationToken) return;
    }

    try {
      await player.setDataSource(playableUrl, autoPlay: widget.autoPlay);
    } catch (_) {
      // 错误信息会通过 player.value.exception 传到 _onPlayerChanged。
      return;
    }
    if (!mounted || token != _operationToken) return;
    if (!widget.autoPlay &&
        widget.prepareOnLoad &&
        !player.value.prepared &&
        player.state != FijkState.asyncPreparing) {
      try {
        await player.prepareAsync();
      } catch (_) {}
    }
  }

  void _onPlayerChanged() {
    final player = _player;
    if (player == null) return;
    final value = player.value;
    final nextDuration = value.duration;
    final nextPrepared = value.prepared;
    final nextPlaying = value.state == FijkState.started;
    final nextError = value.exception.message;
    if (nextDuration == _state.duration &&
        nextPrepared == _state.prepared &&
        nextPlaying == _state.playing &&
        nextError == _state.error) {
      // 状态未变化，跳过 setState，降低重建开销。
    } else {
      _emit(_state.copyWith(
        duration: nextDuration,
        prepared: nextPrepared,
        playing: nextPlaying,
        error: nextError,
      ));
    }
    if (value.state == FijkState.completed) {
      widget.onCompleted?.call();
      if (widget.loop && _playableUrl != null) {
        unawaited(_restartLoop(_playableUrl!));
      }
    }
  }

  Future<void> _restartLoop(String url) async {
    final player = _player;
    if (player == null) return;
    try {
      await player.stop();
      await player.reset();
      await player.setDataSource(url, autoPlay: true);
    } catch (_) {
      // 循环重启失败时静默忽略，由 _onPlayerChanged 的 error 字段反馈。
    }
  }

  void _emit(CoreVideoPlaybackState state) {
    if (!mounted) return;
    setState(() => _state = state);
    widget.onStateChanged?.call(state);
  }

  @override
  void dispose() {
    _operationToken++;
    unawaited(_detachPlayer(release: widget.releasePlayerOnDispose));
    super.dispose();
  }

  Future<void> _detachPlayer({required bool release}) async {
    await _positionSub?.cancel();
    await _bufferingSub?.cancel();
    _positionSub = null;
    _bufferingSub = null;
    final player = _player;
    if (player == null) return;
    player.removeListener(_onPlayerChanged);
    if (release) {
      try {
        await player.stop();
        await player.reset();
        await player.release();
      } catch (_) {}
    }
    _player = null;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_state.prepared && _player != null)
            FijkView(
              player: _player!,
              color: widget.backgroundColor ?? Colors.black,
              fit: widget.fit == BoxFit.cover ? FijkFit.cover : FijkFit.contain,
              panelBuilder: (player, data, context, size, rect) =>
                  widget.panelBuilder
                      ?.call(player, data, context, size, rect) ??
                  const SizedBox(),
              fs: widget.fs,
            )
          else
            widget.placeholderBuilder?.call(context, widget.item, _state) ??
                _DefaultPlaceholder(
                  item: widget.item,
                  coverBuilder: widget.coverBuilder,
                ),
          if (_player != null && widget.overlayBuilder != null)
            Positioned.fill(
              child: widget.overlayBuilder!(
                context,
                widget.item,
                _player!,
                _state,
              ),
            ),
        ],
      ),
    );
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  final CoreVideoItem item;
  final CoreVideoCoverBuilder? coverBuilder;

  const _DefaultPlaceholder({required this.item, this.coverBuilder});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: coverBuilder?.call(context, item) ??
              Container(color: Colors.black),
        ),
        const CircularProgressIndicator(color: Colors.white),
      ],
    );
  }
}

extension on CoreVideoPlaybackState {
  CoreVideoPlaybackState copyWith({
    Duration? duration,
    Duration? position,
    bool? prepared,
    bool? playing,
    bool? buffering,
    String? error,
  }) {
    return CoreVideoPlaybackState(
      duration: duration ?? this.duration,
      position: position ?? this.position,
      prepared: prepared ?? this.prepared,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      error: error ?? this.error,
    );
  }
}
