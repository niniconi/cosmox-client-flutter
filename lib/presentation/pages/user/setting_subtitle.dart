import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/presentation/widgets/drawer.dart';
import 'package:cosmox_client_flutter/presentation/widgets/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubtitleSettingPage extends StatefulWidget {
  const SubtitleSettingPage({super.key, required this.title});

  final String title;

  @override
  State<SubtitleSettingPage> createState() => _SubtitleSettingPageState();
}

class _SubtitleSettingPageState extends State<SubtitleSettingPage> {
  String _subtitleLanguage = 'auto';
  String _fontSize = 'medium';
  double _bgOpacity = 0.5;
  String _textColor = 'white';
  bool _autoGenerate = false;

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
            // Subtitle Language
            SettingsSectionTitle(loc.defaultSubtitleLanguage),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.language,
                  title: loc.defaultSubtitleLanguage,
                  trailing: DropdownButton<String>(
                    value: _subtitleLanguage,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: 'auto',
                        child: Text(loc.selectLanguage),
                      ),
                      DropdownMenuItem(value: 'en', child: Text(loc.english)),
                      DropdownMenuItem(value: 'zh', child: Text(loc.chinese)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _subtitleLanguage = val);
                      }
                    },
                  ),
                ),
              ],
            ),

            // Display
            SettingsSectionTitle(loc.appearance),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.text_fields,
                  title: loc.subtitleFontSize,
                  trailing: DropdownButton<String>(
                    value: _fontSize,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'small', child: Text(loc.small)),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text(loc.medium),
                      ),
                      DropdownMenuItem(value: 'large', child: Text(loc.large)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _fontSize = val);
                      }
                    },
                  ),
                ),
                SettingsTile(
                  icon: Icons.text_fields,
                  title: loc.subtitleTextColor,
                  trailing: DropdownButton<String>(
                    value: _textColor,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: 'white',
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text('White'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'yellow',
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 16, color: Colors.yellow),
                            SizedBox(width: 6),
                            Text('Yellow'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'cyan',
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 16, color: Colors.cyan),
                            SizedBox(width: 6),
                            Text('Cyan'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _textColor = val);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.subtitleBgOpacity,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Slider(
                        value: _bgOpacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(_bgOpacity * 100).round()}%',
                        onChanged: (val) {
                          setState(() => _bgOpacity = val);
                        },
                      ),
                    ],
                  ),
                ),
                SettingsSwitchTile(
                  icon: Icons.auto_awesome,
                  title: loc.autoGenerateSubtitles,
                  value: _autoGenerate,
                  onChanged: (val) {
                    setState(() => _autoGenerate = val);
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
