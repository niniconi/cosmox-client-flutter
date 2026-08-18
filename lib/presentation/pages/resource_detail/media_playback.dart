import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/presentation/pages/media_playback/video_player.dart';
import 'package:cosmox_client/presentation/pages/resource_detail/metadata_parser.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

// Playback helpers for the resource detail page: resolve the authenticated
// media URL for a file node via its `data_file_map_id` and route to the
// video player. The backend currently serves video only, so every playable
// file is played through [VideoPlayerPage].
final Logger _playbackLogger = Logger('MediaPlayback');

/// Collects the file nodes under [root] as a flat list whose order exactly
/// mirrors the Episodes tab: branches keep their tree order and the file
/// children of each branch are ordered by `episode_number`. Playback then
/// follows the same order the user sees in the panel.
List<MetadataNode> collectPlayableFiles(MetadataNode root) {
  final out = <MetadataNode>[];
  final branches = root.subMetadatas.where((c) {
    final hasFiles = c.subMetadatas.any(
      (x) => x.metadataType == MetadataType.file,
    );
    final hasSeason = extendValue(c.extend, 'season_number').isNotEmpty;
    return hasFiles || hasSeason;
  });
  for (final branch in branches) {
    final episodes =
        branch.subMetadatas
            .where((c) => c.metadataType == MetadataType.file)
            .toList()
          ..sort(_compareByEpisodeNumber);
    out.addAll(episodes);
  }
  return out;
}

int _compareByEpisodeNumber(MetadataNode a, MetadataNode b) {
  final an = int.tryParse(extendValue(a.extend, 'episode_number')) ?? 0;
  final bn = int.tryParse(extendValue(b.extend, 'episode_number')) ?? 0;
  return an.compareTo(bn);
}

/// Resolves the auth-aware pull URL for a file node, or null when there is no
/// `data_file_map_id` or the pull fails.
Future<String?> mediaUrl(MetadataNode node) async {
  final id = node.dataFileMapId;
  if (id == null) return null;
  try {
    final url = await SdkProxy.instance.itemPull(id: id);
    return url.isEmpty ? null : url;
  } catch (error) {
    _playbackLogger.severe('Failed to resolve media URL', error);
    return null;
  }
}

/// Human-friendly title for a file node, e.g. "E3  My Episode".
String mediaTitle(MetadataNode node) {
  final episodeNum = extendValue(node.extend, 'episode_number');
  final name = cleanFileName(
    node.name.isEmpty ? 'Episode $episodeNum' : node.name,
  );
  return episodeNum.isNotEmpty ? 'E$episodeNum  $name' : name;
}

/// Resolves the media URLs for every playable file under [root] and opens the
/// video player. Playback starts at [startAt] when given, otherwise at the
/// first file. Files whose URL cannot be resolved are skipped; nothing happens
/// when no playable file remains.
Future<void> openVideoPlayback(
  BuildContext context,
  MetadataNode root, {
  MetadataNode? startAt,
}) async {
  final files = collectPlayableFiles(root);
  final items = <PlaybackItem>[];
  int? resolvedStart;
  for (final file in files) {
    final url = await mediaUrl(file);
    if (url == null) continue;
    if (identical(file, startAt)) resolvedStart = items.length;
    items.add(PlaybackItem(title: mediaTitle(file), url: url));
  }
  if (items.isEmpty) return;

  final token = SdkProxy.instance.getToken();

  // The URLs were resolved across several awaits; the page may have been
  // disposed meanwhile, so bail out instead of navigating on a dead context.
  if (!context.mounted) return;

  context.push(
    '/player/video/playlist',
    extra: VideoPlaybackPayload(
      items: items,
      token: token,
      startIndex: resolvedStart ?? 0,
    ),
  );
}
