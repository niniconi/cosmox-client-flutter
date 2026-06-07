import 'package:cosmox_client/core/common.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/widgets/drawer.dart';
import 'package:cosmox_client/presentation/widgets/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PreferenceSettingPage extends StatefulWidget {
  const PreferenceSettingPage({super.key, required this.title});

  final String title;

  @override
  State<PreferenceSettingPage> createState() => _PreferenceSettingPageState();
}

class _PreferenceSettingPageState extends State<PreferenceSettingPage> {
  late String logPath = "";
  late String cachePath = "";
  late TextEditingController _cachePathController;
  late TextEditingController _logPathController;

  @override
  void initState() {
    super.initState();
    _cachePathController = TextEditingController(text: cachePath);
    _logPathController = TextEditingController(text: logPath);
  }

  @override
  void dispose() {
    _cachePathController.dispose();
    _logPathController.dispose();
    super.dispose();
  }

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
            SettingsSectionTitle(loc.preferences),
            SettingsCard(
              children: [
                SettingsFormField(
                  label: loc.cachePath,
                  controller: _cachePathController,
                  validator: (val) => Validate.path(val),
                ),
                SettingsFormField(
                  label: loc.logPath,
                  controller: _logPathController,
                  validator: (val) => Validate.path(val),
                ),
              ],
            ),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.view_module_outlined,
                  title: loc.defaultLibraryView,
                  trailing: DropdownButton<String>(
                    value: 'grid',
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: 'grid',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.grid_view, size: 18),
                            const SizedBox(width: 6),
                            Text(loc.gridView),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'list',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.list, size: 18),
                            const SizedBox(width: 6),
                            Text(loc.listView),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (_) {},
                  ),
                ),
                SettingsTile(
                  icon: Icons.language,
                  title: loc.contentLanguage,
                  subtitle: 'All',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.family_restroom_outlined,
                  title: loc.parentalControls,
                  onTap: () {},
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
