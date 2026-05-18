import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/widgets.dart';

class CoreVideoItem {
  final Object? id;
  final String url;
  final String? title;
  final String? coverUrl;
  final int? width;
  final int? height;
  final bool playable;
  final Object? extra;

  const CoreVideoItem({
    required this.url,
    this.id,
    this.title,
    this.coverUrl,
    this.width,
    this.height,
    this.playable = true,
    this.extra,
  });
}

class CoreVideoCacheConfig {
  final bool enabled;
  final int aheadSegmentCount;

  const CoreVideoCacheConfig({
    this.enabled = true,
    this.aheadSegmentCount = 2,
  });

  const CoreVideoCacheConfig.disabled()
      : enabled = false,
        aheadSegmentCount = 0;
}

class CoreVideoPlaybackState {
  final Duration duration;
  final Duration position;
  final bool prepared;
  final bool playing;
  final bool buffering;
  final String? error;

  const CoreVideoPlaybackState({
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.prepared = false,
    this.playing = false,
    this.buffering = false,
    this.error,
  });
}

typedef CoreVideoCoverBuilder = Widget Function(
  BuildContext context,
  CoreVideoItem item,
);

typedef CoreVideoPlaceholderBuilder = Widget Function(
  BuildContext context,
  CoreVideoItem item,
  CoreVideoPlaybackState state,
);

typedef CoreVideoOverlayBuilder = Widget Function(
  BuildContext context,
  CoreVideoItem item,
  FijkPlayer player,
  CoreVideoPlaybackState state,
);

typedef CoreVideoPanelBuilder = Widget Function(
  FijkPlayer player,
  FijkData data,
  BuildContext context,
  Size viewSize,
  Rect texturePos,
);

typedef CoreVideoItemPredicate = bool Function(CoreVideoItem item);

typedef CoreTiktokNonVideoItemBuilder = Widget Function(
  BuildContext context,
  CoreVideoItem item,
);
