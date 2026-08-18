import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/pages/resource_detail/metadata_parser.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';

/// The "Episodes" tab: mirrors the metadata tree as Season → Episode files.
class EpisodesTab extends StatelessWidget {
  const EpisodesTab({super.key, required this.metadata, this.onPlay});

  final MetadataNode metadata;

  /// Invoked with the tapped episode and its metadata root so the owner can
  /// start playback for the whole resource beginning at that episode.
  final void Function(MetadataNode metadata, MetadataNode episode)? onPlay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // A "season" is a Virtual branch that contains File-type children, or
    // that carries a season identifier. Fall back to a single anonymous group
    // when the tree has no season grouping at all.
    final branches = metadata.subMetadatas.where((c) {
      final hasFiles = c.subMetadatas.any(
        (x) => x.metadataType == MetadataType.file,
      );
      final hasSeason = extendValue(c.extend, 'season_number').isNotEmpty;
      return hasFiles || hasSeason;
    }).toList();

    if (branches.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.episodeList,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: branches.length,
      itemBuilder: (context, index) => _SeasonTile(
        season: branches[index],
        onPlay: onPlay == null ? null : (ep) => onPlay!(metadata, ep),
      ),
    );
  }
}

class _SeasonTile extends StatelessWidget {
  const _SeasonTile({required this.season, required this.onPlay});

  final MetadataNode season;
  final void Function(MetadataNode episode)? onPlay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final seasonNo = extendValue(season.extend, 'season_number');
    final episodes =
        season.subMetadatas
            .where((c) => c.metadataType == MetadataType.file)
            .toList()
          ..sort((a, b) {
            final ae = int.tryParse(extendValue(a.extend, 'episode_number'));
            final be = int.tryParse(extendValue(b.extend, 'episode_number'));
            return (ae ?? 0).compareTo(be ?? 0);
          });

    if (episodes.isEmpty) {
      // Season whose files live one level deeper (rare) — try descendants.
      final nestedFiles = collectOfType(season, type: MetadataType.file);
      if (nestedFiles.isEmpty) return const SizedBox.shrink();
    }

    final title = seasonNo.isNotEmpty ? '${loc.season} $seasonNo' : season.name;

    return ExpansionTile(
      maintainState: true,
      leading: Icon(Icons.video_library_outlined, color: colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        if (season.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              season.description,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ...episodes.map((e) => _EpisodeTile(episode: e, onPlay: onPlay)),
      ],
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.episode, required this.onPlay});

  final MetadataNode episode;
  final void Function(MetadataNode episode)? onPlay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final num = extendValue(episode.extend, 'episode_number');
    final duration = extendValue(episode.extend, 'duration_minutes');
    final cleanName = cleanFileName(
      episode.name.isEmpty ? 'Episode $num' : episode.name,
    );

    return ListTile(
      leading: Icon(Icons.play_circle_outline, color: colorScheme.primary),
      title: Text(
        num.isNotEmpty ? 'E$num  $cleanName' : cleanName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colorScheme.onSurface),
      ),
      subtitle: duration.isNotEmpty
          ? Text(
              '$duration min',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          : null,
      onTap: onPlay != null && episode.dataFileMapId != null
          ? () => onPlay!(episode)
          : null,
    );
  }
}
