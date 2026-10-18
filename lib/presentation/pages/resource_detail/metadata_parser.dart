import 'dart:convert' show jsonDecode;

import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';

/// Parses a [MetadataNode]'s `extend` map generically and produces grouped,
/// human-friendly display entries. Keys are grouped by their prefix
/// (e.g. `anime:`, `character:`) so future metadata types render too.
class MetadataExtendParser {
  MetadataExtendParser(this.extend);

  final Map<String, String> extend;

  /// Returns all entries grouped by prefix, preserving insertion order.
  List<({String label, List<(String, String)> items})> groups() {
    final order = <String>[];
    final map = <String, List<(String, String)>>{};
    extend.forEach((key, value) {
      final prefix = _prefixOf(key);
      map
          .putIfAbsent(prefix, () {
            order.add(prefix);
            return [];
          })
          .add((key, value));
    });
    return order.map((p) => (label: p, items: map[p]!)).toList(growable: false);
  }

  /// Best-effort friendly name for common fields across types.
  static String friendlyName(String key) {
    final field = key.contains(':') ? key.split(':').last : key;
    return switch (field) {
      'rating' || 'score' => 'Rating',
      'eps' => 'Episodes',
      'episode_number' => 'Episode',
      'season_number' => 'Season',
      'duration_minutes' => 'Duration',
      'platform' || 'format' => 'Format',
      'source' => 'Source',
      'status' => 'Status',
      'start_date' => 'Start Date',
      'end_date' => 'End Date',
      'genres' => 'Genres',
      'studios' => 'Studios',
      'titles' => 'Titles',
      'alias' => 'Alias',
      'official_website' => 'Official Website',
      'website' => 'Website',
      'role' => 'Role',
      'voice_actors' => 'Voice Actors',
      'career' => 'Career',
      'description' => 'Description',
      'subject_id' => 'Subject ID',
      'id' => 'ID',
      _ => field,
    };
  }

  String _prefixOf(String key) {
    final idx = key.indexOf(':');
    if (idx <= 0) return 'General';
    return key.substring(0, idx);
  }
}

/// Returns the value of the `extend` entry whose suffix (after the last `:`)
/// equals [field], ignoring the type prefix (e.g. `anime:rating` for 'rating').
String extendValue(Map<String, String> extend, String field) {
  for (final entry in extend.entries) {
    if (!entry.key.contains(':')) continue;
    if (entry.key.split(':').last == field) return entry.value;
  }
  return '';
}

/// Parses a raw string into a list of strings, tolerating JSON arrays,
/// a single plain value, or empty/null markers.
List<String> parseList(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == '[]' || trimmed == 'null') {
    return const [];
  }
  if (!trimmed.startsWith('[')) return [trimmed];
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is List) {
      return decoded
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
  } catch (_) {
    return [trimmed];
  }
  return const [];
}

/// Parses the `voice_actors` JSON array into a list of [VoiceActor].
List<VoiceActor> parseVoiceActors(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == '[]' || trimmed == 'null') {
    return const [];
  }
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) {
        final name = e['name'];
        return (
          name: name is String ? name : '',
          imageUrl: e['image_url'] is String ? e['image_url'] as String : null,
        );
      }).toList();
    }
  } catch (_) {
    return const [];
  }
  return const [];
}

/// Extracts a human-readable title from a JSON object string, falling back to
/// the raw string when it is not valid JSON.
String titleFromJson(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == '[]' || trimmed == 'null') return '';
  if (!trimmed.startsWith('{')) return trimmed;
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map) {
      for (final k in ['main', 'cn', 'ja', 'en', 'title']) {
        final v = decoded[k];
        if (v is String && v.isNotEmpty) return v;
      }
    }
  } catch (_) {
    return trimmed;
  }
  return '';
}

/// Keeps the readable part of a raw file name (strips bracketed tags).
String cleanFileName(String raw) {
  var s = raw.trim();
  while (s.startsWith('[')) {
    final end = s.indexOf(']');
    if (end < 0) break;
    s = s.substring(end + 1).trimLeft();
  }
  if (s.isEmpty) return raw;
  return s;
}

/// Finds a direct child whose [name] equals [name] (case-insensitive).
MetadataNode? branchByName(MetadataNode node, String name) {
  for (final c in node.subMetadatas) {
    if (c.name.toLowerCase() == name.toLowerCase()) return c;
  }
  return null;
}

/// Collects descendant [MetadataNode]s of the given [MetadataType].
List<MetadataNode> collectOfType(
  MetadataNode root, {
  required MetadataType type,
}) {
  final out = <MetadataNode>[];
  void walk(List<MetadataNode> nodes) {
    for (final n in nodes) {
      if (n.metadataType == type) {
        out.add(n);
      }
      if (n.subMetadatas.isNotEmpty) walk(n.subMetadatas);
    }
  }

  walk(root.subMetadatas);
  return out;
}

/// Resolves the auth-aware pull URL for a cover file map id, or null when
/// absent or the pull fails. Empty results are treated as null so callers can
/// show a fallback.
Future<String?> coverUrl(BigInt? coverFileMapId) async {
  if (coverFileMapId == null) return null;
  try {
    final url = await SdkProxy.instance.itemPull(id: coverFileMapId);
    return url.isEmpty ? null : url;
  } catch (_) {
    return null;
  }
}

/// Voice actor entry embedded in the `voice_actors` JSON string.
typedef VoiceActor = ({String name, String? imageUrl});
