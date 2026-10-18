import 'package:cosmox_client_flutter/core/constants.dart';
import 'package:cosmox_client_flutter/core/state.dart';
import 'package:cosmox_client_flutter/presentation/widgets/settings_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' as platform;

import 'package:provider/provider.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';

class ClientSettingPage extends StatefulWidget {
  const ClientSettingPage({super.key});

  @override
  State<ClientSettingPage> createState() => _ClientSettingPageState();
}

class _ClientSettingPageState extends State<ClientSettingPage> {
  // Existing theme widgets (preserved)

  Widget _buildThemeTile({
    required ColorScheme colors,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 65,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surfaceContainerHighest.withAlpha(51),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: colors.primary,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: Container(color: colors.primary)),
                      Expanded(
                        child: Container(color: colors.primaryContainer),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: Container(color: colors.secondary)),
                      Expanded(
                        child: Container(color: colors.secondaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageThemeTile({required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap, child: Container());
  }

  Widget _buildGeneralSetting() {
    return Wrap(
      direction: Axis.horizontal,
      children: ColorSeed.values
          .map(
            (seed) => _buildThemeTile(
              colors: ColorScheme.fromSeed(seedColor: seed.color),
              isSelected: context.watch<ThemeController>().colorSeed == seed,
              onTap: () =>
                  context.read<ThemeController>().updateColorSeed(seed),
            ),
          )
          .toList(),
    );
  }

  Widget _buildWebSetting() {
    return _buildGeneralSetting();
  }

  Widget _buildLinuxSetting() {
    return _buildGeneralSetting();
  }

  Widget _buildUnknownPlatform() {
    return _buildGeneralSetting();
  }

  // Remaining private helpers

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<DropdownMenuItem<String>> items,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 2,
          ),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: items,
            onChanged: null,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 60,
            endIndent: 20,
            color: Theme.of(context).colorScheme.outlineVariant.withAlpha(40),
          ),
      ],
    );
  }

  Widget _buildThemeModeSelector() {
    final themeMode = context.watch<ThemeController>().themeMode;
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.brightness_6,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              loc.themeMode,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(loc.system, style: const TextStyle(fontSize: 12)),
                icon: const Icon(Icons.brightness_auto, size: 18),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(loc.light, style: const TextStyle(fontSize: 12)),
                icon: const Icon(Icons.light_mode, size: 18),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(loc.dark, style: const TextStyle(fontSize: 12)),
                icon: const Icon(Icons.dark_mode, size: 18),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (value) {
              context.read<ThemeController>().updateThemeMode(value.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              loc.selectLanguage,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          DropdownButton<String>(
            value: Localizations.localeOf(context).languageCode,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'zh', child: Text('中文')),
            ],
            onChanged: (_) {
              // Placeholder — language switching logic later
            },
          ),
        ],
      ),
    );
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Preserved: which platform-specific builder to use for the theme section
    Widget themePicker;
    if (kIsWeb) {
      themePicker = _buildWebSetting();
    } else {
      if (platform.Platform.isLinux) {
        themePicker = _buildLinuxSetting();
      } else {
        themePicker = _buildUnknownPlatform();
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Appearance
            SettingsSectionTitle(loc.appearance),
            SettingsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    AppLocalizations.of(context)!.themeMode,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: themePicker,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildThemeModeSelector(),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildLanguageSelector(),
              ],
            ),

            // Section: Playback
            SettingsSectionTitle(loc.playback),
            SettingsCard(
              children: [
                _buildDropdownTile(
                  icon: Icons.subtitles_outlined,
                  title: loc.defaultSubtitleLanguage,
                  value: 'English',
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(value: '中文', child: Text('中文')),
                  ],
                ),
                _buildDropdownTile(
                  icon: Icons.audiotrack_outlined,
                  title: loc.defaultAudioLanguage,
                  value: 'English',
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(value: '中文', child: Text('中文')),
                  ],
                ),
                _buildDropdownTile(
                  icon: Icons.text_fields,
                  title: loc.subtitleFontSize,
                  value: loc.medium,
                  items: [
                    DropdownMenuItem(value: loc.small, child: Text(loc.small)),
                    DropdownMenuItem(
                      value: loc.medium,
                      child: Text(loc.medium),
                    ),
                    DropdownMenuItem(value: loc.large, child: Text(loc.large)),
                  ],
                ),
                _buildDropdownTile(
                  icon: Icons.speed,
                  title: loc.defaultPlaybackSpeed,
                  value: '1.0x',
                  items: const [
                    DropdownMenuItem(value: '0.5x', child: Text('0.5x')),
                    DropdownMenuItem(value: '1.0x', child: Text('1.0x')),
                    DropdownMenuItem(value: '1.5x', child: Text('1.5x')),
                    DropdownMenuItem(value: '2.0x', child: Text('2.0x')),
                  ],
                ),
                SettingsSwitchTile(
                  icon: Icons.memory,
                  title: loc.hardwareDecoding,
                  subtitle: loc.hardwareDecodingHint,
                  value: true,
                  onChanged: null,
                ),
                SettingsSwitchTile(
                  icon: Icons.skip_next_outlined,
                  title: loc.autoPlayNextEpisode,
                  value: true,
                  onChanged: null,
                ),
                SettingsSwitchTile(
                  icon: Icons.play_circle_outline,
                  title: loc.resumePlayback,
                  value: true,
                  onChanged: null,
                  showDivider: false,
                ),
              ],
            ),

            // Section: Downloads & Cache
            SettingsSectionTitle(loc.cacheStorage),
            SettingsCard(
              children: [
                _buildDropdownTile(
                  icon: Icons.high_quality_outlined,
                  title: loc.downloadQuality,
                  value: loc.qualityOriginal,
                  items: [
                    DropdownMenuItem(
                      value: loc.qualityOriginal,
                      child: Text(loc.qualityOriginal),
                    ),
                    DropdownMenuItem(
                      value: loc.qualityHigh,
                      child: Text(loc.qualityHigh),
                    ),
                    DropdownMenuItem(
                      value: loc.qualityMedium,
                      child: Text(loc.qualityMedium),
                    ),
                    DropdownMenuItem(
                      value: loc.qualityLow,
                      child: Text(loc.qualityLow),
                    ),
                  ],
                ),
                SettingsSwitchTile(
                  icon: Icons.wifi,
                  title: loc.wifiOnlyDownload,
                  value: false,
                  onChanged: null,
                ),
                SettingsTile(
                  icon: Icons.download_outlined,
                  title: loc.downloadPath,
                  subtitle: '/downloads',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.storage_outlined,
                  title: loc.cacheSize,
                  subtitle: 'Calculating…',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.delete_outline,
                  title: loc.clearCache,
                  trailing: TextButton(onPressed: null, child: Text(loc.clear)),
                  showDivider: false,
                ),
              ],
            ),

            // Section: Network
            SettingsSectionTitle(loc.network),
            SettingsCard(
              children: [
                _buildDropdownTile(
                  icon: Icons.data_usage_outlined,
                  title: loc.streamingBufferSize,
                  value: loc.bufferMedium,
                  items: [
                    DropdownMenuItem(
                      value: loc.bufferSmall,
                      child: Text(loc.bufferSmall),
                    ),
                    DropdownMenuItem(
                      value: loc.bufferMedium,
                      child: Text(loc.bufferMedium),
                    ),
                    DropdownMenuItem(
                      value: loc.bufferLarge,
                      child: Text(loc.bufferLarge),
                    ),
                  ],
                ),
                SettingsSwitchTile(
                  icon: Icons.https_outlined,
                  title: loc.httpsOnly,
                  value: true,
                  onChanged: null,
                ),
                SettingsTile(
                  icon: Icons.vpn_lock_outlined,
                  title: loc.proxySettings,
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),

            // Section: Accessibility
            SettingsSectionTitle(loc.accessibility),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.opacity,
                  title: loc.subtitleBgOpacity,
                  subtitle: '75%',
                  onTap: () {},
                ),
                SettingsSwitchTile(
                  icon: Icons.text_fields,
                  title: loc.largeTextMode,
                  value: false,
                  onChanged: null,
                ),
                SettingsSwitchTile(
                  icon: Icons.invert_colors_outlined,
                  title: loc.highContrastMode,
                  value: false,
                  onChanged: null,
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
