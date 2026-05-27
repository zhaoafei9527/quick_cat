import 'dart:async';
import 'dart:math';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'core_video_cache_manager.dart';
import 'core_video_models.dart';

typedef CoreTiktokLoadMore = Future<List<CoreVideoItem>> Function(int page);

class CoreFijkTiktokFeedController extends ChangeNotifier {
  _CoreFijkTiktokFeedPageState? _state;

  int get currentIndex => _state?._currentIndex ?? 0;

  List<CoreVideoItem> get items =>
      List.unmodifiable(_state?._items ?? const []);

  void _attach(_CoreFijkTiktokFeedPageState state) {
    _state = state;
  }

  void togglePause(bool pause) {
    final state = _state;
    if (state == null) return;
    final holder = state._pool.holderOf(state._currentIndex);
    if (pause) {
      unawaited(holder?.pause());
    } else {
      unawaited(holder?.play());
    }
  }

  void jumpTo(int index) {
    final state = _state;
    if (state == null) return;
    state._pageController.jumpToPage(index.clamp(0, state._items.length - 1));
  }

  void resetItems(
    List<CoreVideoItem> items, {
    int initIndex = 0,
    bool autoPlay = false,
  }) {
    final state = _state;
    if (state == null || items.isEmpty) return;
    state.resetItems(items, initIndex: initIndex, autoPlay: autoPlay);
    notifyListeners();
  }

  void append(List<CoreVideoItem> items) {
    final state = _state;
    if (state == null || items.isEmpty) return;
    state.appendItems(items);
    notifyListeners();
  }

  Future<void> setAllLooping(bool loop) async {
    await _state?._pool.setAllLooping(loop);
    notifyListeners();
  }

  Future<void> setCurrentLooping(bool loop) async {
    final state = _state;
    if (state == null) return;
    await state._pool.setLooping(state._currentIndex, loop);
    notifyListeners();
  }

  bool getCurrentLooping() {
    final state = _state;
    if (state == null) return true;
    return state._pool.getLooping(state._currentIndex);
  }
}

class CoreFijkTiktokFeedPage extends StatefulWidget {
  final List<CoreVideoItem> items;
  final int initIndex;
  final bool firstPlay;
  final int playerCacheCount;
  final bool loop;
  final CoreVideoCacheConfig cacheConfig;
  final CoreFijkTiktokFeedController? controller;
  final CoreVideoCoverBuilder? coverBuilder;
  final CoreVideoPlaceholderBuilder? placeholderBuilder;
  final CoreVideoOverlayBuilder? overlayBuilder;
  final CoreVideoItemPredicate? isVideoItem;
  final CoreTiktokNonVideoItemBuilder? nonVideoItemBuilder;
  final CoreTiktokLoadMore? onLoadMore;
  final FutureOr<void> Function(CoreVideoItem item, int index)? onVideoPlay;

  const CoreFijkTiktokFeedPage({
    super.key,
    required this.items,
    this.initIndex = 0,
    this.firstPlay = true,
    this.playerCacheCount = 3,
    this.loop = true,
    this.cacheConfig = const CoreVideoCacheConfig(),
    this.controller,
    this.coverBuilder,
    this.placeholderBuilder,
    this.overlayBuilder,
    this.isVideoItem,
    this.nonVideoItemBuilder,
    this.onLoadMore,
    this.onVideoPlay,
  });

  @override
  State<CoreFijkTiktokFeedPage> createState() => _CoreFijkTiktokFeedPageState();
}

class _CoreFijkTiktokFeedPageState extends State<CoreFijkTiktokFeedPage>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late _CorePlayerPool _pool;
  late List<CoreVideoItem> _items;
  int _currentIndex = 0;
  int _page = 1;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _items = List.of(widget.items);
    _currentIndex = widget.initIndex.clamp(0, max(0, _items.length - 1));
    _pageController = PageController(initialPage: _currentIndex);
    _pool = _CorePlayerPool(
      items: _items,
      capacity: widget.playerCacheCount,
      cacheConfig: widget.cacheConfig,
      loop: widget.loop,
    );
    widget.controller?._attach(this);
    if (_items.isNotEmpty &&
        (widget.isVideoItem?.call(_items[_currentIndex]) ?? true)) {
      _pool.ensureHolder(_currentIndex);
    }
    unawaited(_pool.switchTo(
      _currentIndex,
      direction: ScrollDirection.idle,
      autoPlay: widget.firstPlay,
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final holder = _pool.holderOf(_currentIndex);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(holder?.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    unawaited(_pool.disposeAll());
    super.dispose();
  }

  Future<void> _onPageChanged(int index) async {
    final direction = index > _currentIndex
        ? ScrollDirection.forward
        : index < _currentIndex
            ? ScrollDirection.reverse
            : ScrollDirection.idle;
    setState(() {
      _currentIndex = index;
      if (widget.isVideoItem?.call(_items[index]) ?? true) {
        _pool.ensureHolder(index);
      }
    });
    unawaited(_pool.switchTo(index, direction: direction));
    unawaited(Future<void>.sync(() async {
      await widget.onVideoPlay?.call(_items[index], index);
    }));
    if (!_loadingMore &&
        widget.onLoadMore != null &&
        index >= _items.length - 2) {
      _loadingMore = true;
      final more = await widget.onLoadMore!(_page + 1);
      _loadingMore = false;
      if (more.isEmpty || !mounted) return;
      setState(() => _items.addAll(more));
      _pool.updateItems(_items);
      _page += 1;
    }
  }

  void resetItems(
    List<CoreVideoItem> items, {
    int initIndex = 0,
    bool autoPlay = false,
  }) {
    setState(() {
      _items = List.of(items);
      _currentIndex = initIndex.clamp(0, _items.length - 1);
      _page = max(1, _items.length ~/ 10);
    });
    _pool.updateItems(_items);
    _pageController.jumpToPage(_currentIndex);
    unawaited(_pool.switchTo(
      _currentIndex,
      direction: ScrollDirection.idle,
      autoPlay: autoPlay,
    ));
  }

  void appendItems(List<CoreVideoItem> items) {
    setState(() => _items.addAll(items));
    _pool.updateItems(_items);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final isVideo = widget.isVideoItem?.call(_items[index]) ?? true;
        return _CoreTiktokItem(
          item: _items[index],
          holder: isVideo ? _pool.ensureHolder(index) : null,
          coverBuilder: widget.coverBuilder,
          placeholderBuilder: widget.placeholderBuilder,
          overlayBuilder: widget.overlayBuilder,
          isVideo: isVideo,
          nonVideoItemBuilder: widget.nonVideoItemBuilder,
        );
      },
    );
  }
}

class _CoreTiktokItem extends StatelessWidget {
  final CoreVideoItem item;
  final _CorePlayerHolder? holder;
  final CoreVideoCoverBuilder? coverBuilder;
  final CoreVideoPlaceholderBuilder? placeholderBuilder;
  final CoreVideoOverlayBuilder? overlayBuilder;
  final bool isVideo;
  final CoreTiktokNonVideoItemBuilder? nonVideoItemBuilder;

  const _CoreTiktokItem({
    required this.item,
    required this.holder,
    this.coverBuilder,
    this.placeholderBuilder,
    this.overlayBuilder,
    this.isVideo = true,
    this.nonVideoItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final aspectRatio = (item.width != null && item.height != null)
        ? item.width! / item.height!
        : MediaQuery.of(context).size.aspectRatio;
    if (!isVideo) {
      return nonVideoItemBuilder?.call(context, item) ??
          const ColoredBox(color: Colors.black);
    }
    return ColoredBox(
      color: Colors.black,
      child: holder == null
          ? _buildPlaceholder(context, const CoreVideoPlaybackState())
          : Stack(
              alignment: Alignment.center,
              children: [
                // FijkView 与占位封面仅依赖 prepared 字段，避免随 position 重复重建。
                _PreparedSwitcher(
                  notifier: holder!.stateNotifier,
                  preparedBuilder: (context) => AspectRatio(
                    aspectRatio: aspectRatio,
                    child: FijkView(
                      player: holder!.player,
                      fit: FijkFit.fill,
                      panelBuilder: (player, data, context, size, rect) =>
                          const SizedBox(),
                    ),
                  ),
                  placeholderBuilder: (context, state) =>
                      _buildPlaceholder(context, state),
                ),
                if (overlayBuilder != null)
                  Positioned.fill(
                    child: ValueListenableBuilder<CoreVideoPlaybackState>(
                      valueListenable: holder!.stateNotifier,
                      builder: (context, state, _) => overlayBuilder!(
                          context, item, holder!.player, state),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, CoreVideoPlaybackState state) {
    return placeholderBuilder?.call(context, item, state) ??
        Stack(
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

/// 仅在 prepared 状态发生变化时切换 FijkView 与占位封面，避免随 position 频繁重建。
class _PreparedSwitcher extends StatelessWidget {
  final ValueNotifier<CoreVideoPlaybackState> notifier;
  final WidgetBuilder preparedBuilder;
  final Widget Function(BuildContext, CoreVideoPlaybackState) placeholderBuilder;

  const _PreparedSwitcher({
    required this.notifier,
    required this.preparedBuilder,
    required this.placeholderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CoreVideoPlaybackState>(
      valueListenable: notifier,
      builder: (context, state, _) => state.prepared
          ? preparedBuilder(context)
          : placeholderBuilder(context, state),
    );
  }
}

class _CorePlayerPool {
  List<CoreVideoItem> items;
  final int capacity;
  final CoreVideoCacheConfig cacheConfig;
  final bool loop;
  final Map<int, _CorePlayerHolder> _holders = {};
  int currentIndex = 0;

  _CorePlayerPool({
    required this.items,
    required this.capacity,
    required this.cacheConfig,
    required this.loop,
  });

  _CorePlayerHolder? holderOf(int index) => _holders[index];

  _CorePlayerHolder? ensureHolder(int index) => _getOrCreate(index);

  _CorePlayerHolder? _getOrCreate(int index) {
    if (index < 0 || index >= items.length) return null;
    if (items[index].url.isEmpty) return null;
    return _holders[index] ??= _CorePlayerHolder(
      item: items[index],
      cacheConfig: cacheConfig,
      looping: loop,
    );
  }

  void updateItems(List<CoreVideoItem> nextItems) {
    items = nextItems;
    final removeKeys = _holders.keys.where((key) => key >= items.length);
    for (final key in removeKeys.toList()) {
      unawaited(_holders.remove(key)?.dispose());
    }
  }

  Future<void> switchTo(
    int index, {
    required ScrollDirection direction,
    bool autoPlay = true,
  }) async {
    if (index < 0 || index >= items.length) return;
    currentIndex = index;
    _pauseOthers(index);
    final current = _getOrCreate(index);
    if (autoPlay) unawaited(current?.play());

    final preload = <int>[];
    if (direction == ScrollDirection.reverse) {
      preload.addAll([index - 1, index + 1]);
    } else {
      preload.addAll([index + 1, index - 1]);
    }
    for (final i in preload) {
      unawaited(_getOrCreate(i)?.preload());
    }
    _trim();
  }

  void _pauseOthers(int except) {
    for (final entry in _holders.entries.toList()) {
      if (entry.key == except) continue;
      if (entry.value.isPreparing) {
        _holders.remove(entry.key);
        unawaited(entry.value.dispose());
      } else {
        unawaited(entry.value.pause());
      }
    }
  }

  void _trim() {
    if (_holders.length <= capacity) return;
    final keepRadius = max(0, (capacity - 1) ~/ 2);
    final keep = <int>{};
    for (var i = currentIndex - keepRadius;
        i <= currentIndex + keepRadius;
        i++) {
      if (i >= 0 && i < items.length) keep.add(i);
    }
    final remove = _holders.keys.where((key) => !keep.contains(key)).toList();
    for (final key in remove) {
      if (_holders.length <= capacity) break;
      unawaited(_holders.remove(key)?.dispose());
    }
  }

  Future<void> disposeAll() async {
    await Future.wait(_holders.values.map((holder) => holder.dispose()));
    _holders.clear();
  }

  Future<void> setAllLooping(bool loop) async {
    for (final holder in _holders.values) {
      holder.setLooping(loop);
    }
  }

  Future<void> setLooping(int index, bool loop) async {
    _holders[index]?.setLooping(loop);
  }

  bool getLooping(int index) {
    return _holders[index]?.looping ?? loop;
  }
}

class _CorePlayerHolder {
  final CoreVideoItem item;
  final CoreVideoCacheConfig cacheConfig;
  bool looping;
  final FijkPlayer player = FijkPlayer();
  final ValueNotifier<CoreVideoPlaybackState> stateNotifier =
      ValueNotifier<CoreVideoPlaybackState>(const CoreVideoPlaybackState());
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _bufferingSub;
  bool _prepared = false;
  bool _disposed = false;
  int _operationToken = 0;
  String? _playableUrl;
  Future<void>? _preloadFuture;

  _CorePlayerHolder({
    required this.item,
    required this.cacheConfig,
    required this.looping,
  }) {
    player.addListener(_onPlayerChanged);
    _positionSub = player.onCurrentPosUpdate.listen((position) {
      _emit(stateNotifier.value.copyWith(position: position));
    });
    _bufferingSub = player.onBufferStateUpdate.listen((buffering) {
      _emit(stateNotifier.value.copyWith(buffering: buffering));
    });
  }

  bool get isPreparing => player.state == FijkState.asyncPreparing;

  Future<void> preload({int? token}) async {
    final currentToken = token ?? _operationToken;
    if (_preloadFuture != null) {
      await _preloadFuture;
      return;
    }
    _preloadFuture = _preload(currentToken);
    try {
      await _preloadFuture;
    } finally {
      _preloadFuture = null;
    }
  }

  Future<void> _preload(int currentToken) async {
    if (_disposed || _prepared || item.url.isEmpty) return;
    var url = item.url;
    if (cacheConfig.enabled) {
      url = await CoreVideoCacheManager().preparePlayableUrl(
        item.url,
        cacheAheadSegmentCount: cacheConfig.aheadSegmentCount,
      );
    }
    if (_disposed || currentToken != _operationToken) return;
    _playableUrl = url;
    await player.setDataSource(url, autoPlay: false);
    if (_disposed || currentToken != _operationToken) return;
    await player.prepareAsync();
    if (_disposed || currentToken != _operationToken) return;
    _prepared = true;
  }

  Future<void> play() async {
    final currentToken = _operationToken;
    if (!_prepared) await preload(token: currentToken);
    if (_disposed || currentToken != _operationToken) return;
    await player.start();
  }

  Future<void> pause() async {
    _operationToken++;
    if (_disposed) return;
    if (player.state == FijkState.asyncPreparing) {
      try {
        await player.reset();
      } catch (_) {}
      _prepared = false;
      _emit(stateNotifier.value.copyWith(prepared: false, playing: false));
      return;
    }
    if (player.state == FijkState.started ||
        player.state == FijkState.prepared) {
      await player.pause();
      _emit(stateNotifier.value.copyWith(playing: false));
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _operationToken++;
    await _positionSub?.cancel();
    await _bufferingSub?.cancel();
    player.removeListener(_onPlayerChanged);
    try {
      if (_playableUrl != null) CoreVideoCacheManager().stop(_playableUrl!);
      await player.stop();
      await player.reset();
      await player.release();
    } catch (_) {}
    stateNotifier.dispose();
  }

  void setLooping(bool loop) {
    looping = loop;
  }

  void _onPlayerChanged() {
    _emit(stateNotifier.value.copyWith(
      duration: player.value.duration,
      prepared: player.value.prepared,
      playing: player.state == FijkState.started,
      error: player.value.exception.message,
    ));
    if (looping &&
        player.state == FijkState.completed &&
        _playableUrl != null) {
      unawaited(_restartLoop());
    }
  }

  Future<void> _restartLoop() async {
    final url = _playableUrl;
    if (_disposed || url == null) return;
    try {
      await player.stop();
      await player.reset();
      await player.setDataSource(url, autoPlay: true);
      await player.prepareAsync();
    } catch (_) {}
  }

  void _emit(CoreVideoPlaybackState state) {
    if (_disposed) return;
    stateNotifier.value = state;
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
