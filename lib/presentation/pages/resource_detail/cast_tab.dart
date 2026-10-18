import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/presentation/pages/resource_detail/metadata_parser.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';

/// The "Cast" tab: characters with cover + voice actors, plus a detail dialog.
class CastTab extends StatelessWidget {
  const CastTab({super.key, required this.metadata});

  final MetadataNode metadata;

  @override
  Widget build(BuildContext context) {
    final cast = branchByName(metadata, 'Cast');
    if (cast == null) {
      return _empty(context);
    }
    final characters = collectOfType(cast, type: MetadataType.virtual);
    if (characters.isEmpty) {
      return _empty(context);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 264,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) =>
          _CharacterCard(character: characters[index]),
    );
  }

  Widget _empty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        AppLocalizations.of(context)!.unnamed,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});

  final MetadataNode character;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final role = extendValue(character.extend, 'role');
    final vas = parseVoiceActors(extendValue(character.extend, 'voice_actors'));

    return Card(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _CharacterDetailDialog.show(context, character),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Cover(future: coverUrl(character.coverFileMapId))),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (role.isNotEmpty)
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (vas.isNotEmpty)
                    Text(
                      vas.map((v) => v.name).join(' / '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.future});

  final Future<String?> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        final url = snapshot.hasData ? snapshot.data : null;
        if (url == null) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          );
        }
        return SdkProxy.instance.authImage(url, context: context);
      },
    );
  }
}

class _CharacterDetailDialog extends StatelessWidget {
  const _CharacterDetailDialog._({required this.character});

  final MetadataNode character;

  static Future<void> show(BuildContext context, MetadataNode character) {
    return showDialog<void>(
      context: context,
      builder: (_) => _CharacterDetailDialog._(character: character),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final role = extendValue(character.extend, 'role');
    final vas = parseVoiceActors(extendValue(character.extend, 'voice_actors'));

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 90,
                      height: 120,
                      child: _Cover(future: coverUrl(character.coverFileMapId)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (role.isNotEmpty)
                          Text(
                            role,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (character.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  character.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
              if (vas.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${loc.voiceActors}:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...vas.map(
                  (v) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: v.imageUrl != null
                          ? NetworkImage(v.imageUrl!)
                          : null,
                      child: v.imageUrl == null
                          ? Icon(
                              Icons.person,
                              color: colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    title: Text(
                      v.name,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
