import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/pages/resource_detail/metadata_parser.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';

/// The "Introduction" tab: plot summary, tags, staff grid and grouped
/// metadata extend entries.
class IntroTab extends StatelessWidget {
  const IntroTab({super.key, required this.metadata});

  final MetadataNode metadata;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final extend = metadata.extend;
    final genres = parseList(extendValue(extend, 'genres'));
    final studios = parseList(extendValue(extend, 'studios'));
    final tags = <String>[...genres, ...studios];
    final description = extend.containsKey('description')
        ? extend['description']!
        : metadata.description;
    final staff = branchByName(metadata, 'Staff');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.plotSummary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description.isNotEmpty ? description : metadata.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 25),
          if (tags.isNotEmpty) ...[
            Text(
              loc.coreTags,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            _TagList(tags: tags),
            const SizedBox(height: 25),
          ],
          if (staff != null) ...[
            Text(
              loc.staffTab,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _StaffGrid(staffNode: staff),
            const SizedBox(height: 25),
          ],
          ...MetadataExtendParser(
            extend,
          ).groups().map((g) => _ExtendGroup(label: g.label, items: g.items)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _TagList extends StatelessWidget {
  const _TagList({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (tags.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.unnamed,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      );
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags
          .map(
            (tag) => ActionChip(
              label: Text(tag),
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: null,
            ),
          )
          .toList(),
    );
  }
}

class _StaffGrid extends StatelessWidget {
  const _StaffGrid({required this.staffNode});

  final MetadataNode staffNode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final members = collectOfType(staffNode, type: MetadataType.virtual);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: members.map((m) {
        final career = extendValue(m.extend, 'career');
        return SizedBox(
          width: 100,
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: null,
                child: _StaffAvatar(coverUrl: coverUrl(m.coverFileMapId)),
              ),
              const SizedBox(height: 6),
              Text(
                m.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
              ),
              if (career.isNotEmpty)
                Text(
                  career,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StaffAvatar extends StatelessWidget {
  const _StaffAvatar({required this.coverUrl});

  final Future<String?> coverUrl;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: coverUrl,
      builder: (context, snapshot) {
        final url = snapshot.hasData ? snapshot.data : null;
        if (url == null) {
          return Icon(
            Icons.person,
            size: 26,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
        }
        return ClipOval(
          child: SdkProxy.instance.authImage(
            url,
            context: context,
            width: 60,
            height: 60,
          ),
        );
      },
    );
  }
}

class _ExtendGroup extends StatelessWidget {
  const _ExtendGroup({required this.label, required this.items});

  final String label;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (e) => _KeyValueRow(MetadataExtendParser.friendlyName(e.$1), e.$2),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
