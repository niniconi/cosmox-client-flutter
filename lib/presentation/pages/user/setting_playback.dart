import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/presentation/widgets/drawer.dart';
import 'package:cosmox_client_flutter/presentation/widgets/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaybackSettingPage extends StatefulWidget {
  const PlaybackSettingPage({super.key, required this.title});

  final String title;

  @override
  State<PlaybackSettingPage> createState() => _PlaybackSettingPageState();
}

class _PlaybackSettingPageState extends State<PlaybackSettingPage> {
  double _playbackSpeed = 1.0;
  bool _hardwareDecoding = true;
  bool _autoPlayNext = true;
  bool _resumePlayback = false;
  bool _backgroundPlayback = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.title),
      ),
      drawer: const HomeDrawerComponent(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speed
            SettingsSectionTitle(loc.playback),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.speed,
                  title: loc.defaultPlaybackSpeed,
                  trailing: DropdownButton<double>(
                    value: _playbackSpeed,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                      DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                      DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                      DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                      DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                      DropdownMenuItem(value: 2.0, child: Text('2.0x')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _playbackSpeed = val);
                      }
                    },
                  ),
                ),
                SettingsSwitchTile(
                  icon: Icons.memory,
                  title: loc.hardwareDecoding,
                  subtitle: loc.hardwareDecodingHint,
                  value: _hardwareDecoding,
                  onChanged: (val) {
                    setState(() => _hardwareDecoding = val);
                  },
                ),
              ],
            ),

            // Auto-play
            SettingsSectionTitle(loc.preferences),
            SettingsCard(
              children: [
                SettingsSwitchTile(
                  icon: Icons.skip_next,
                  title: loc.autoPlayNextEpisode,
                  value: _autoPlayNext,
                  onChanged: (val) {
                    setState(() => _autoPlayNext = val);
                  },
                ),
                SettingsSwitchTile(
                  icon: Icons.replay,
                  title: loc.resumePlayback,
                  value: _resumePlayback,
                  onChanged: (val) {
                    setState(() => _resumePlayback = val);
                  },
                ),
                SettingsSwitchTile(
                  icon: Icons.play_circle_outline,
                  title: loc.backgroundPlayback,
                  value: _backgroundPlayback,
                  onChanged: (val) {
                    setState(() => _backgroundPlayback = val);
                  },
                  showDivider: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
