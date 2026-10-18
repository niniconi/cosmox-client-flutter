import 'package:cosmox_client_flutter/presentation/widgets/form.dart';
import 'package:cosmox_client_flutter/presentation/widgets/drawer.dart';
import 'package:cosmox_client_flutter/presentation/widgets/settings_ui.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client_flutter/core/common.dart';
import 'package:cosmox_client_flutter/core/state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({super.key, required this.title});

  final String title;

  @override
  State<UserSettingPage> createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  // Existing fields (preserved)
  late String logPath = "";
  late String cachePath = "";
  double padding = 20;
  double margin = 20;

  void save() {}

  void cancel() {}

  // Controller fields
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _cachePathController;
  late TextEditingController _logPathController;
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
    _cachePathController = TextEditingController(text: cachePath);
    _logPathController = TextEditingController(text: logPath);
    _tokenController = TextEditingController(
      text: context.read<AuthController>().token ?? "",
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _cachePathController.dispose();
    _logPathController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  // Build

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
            // Section: Profile
            SettingsSectionTitle(loc.profile),
            SettingsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "User",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "user@example.com",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsFormField(
                  label: loc.nickname,
                  controller: _nicknameController,
                  helpText: loc.nicknameNotSet,
                ),
                SettingsFormField(
                  label: loc.email,
                  controller: _emailController,
                  validator: (val) => Validate.email(val),
                  helpText: loc.invalidEmail,
                ),
                SettingsFormField(
                  label: loc.bio,
                  controller: _bioController,
                  helpText: 'A short description about yourself',
                  maxLines: 3,
                  showDivider: false,
                ),
              ],
            ),

            // Section: Account
            SettingsSectionTitle(loc.account),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.lock_outline,
                  title: loc.changePassword,
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.key_outlined,
                  title: loc.twoFactorAuth,
                  subtitle: 'Not configured',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.devices_outlined,
                  title: loc.activeSessions,
                  subtitle: '1 active session',
                  onTap: () {},
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: InputFormField(
                    labelText: loc.token,
                    controller: _tokenController,
                    obscureText: true,
                    helpText: loc.pleaseInputToken,
                  ),
                ),
              ],
            ),

            // Section: Notifications
            SettingsSectionTitle(loc.notifications),
            SettingsCard(
              children: [
                SettingsSwitchTile(
                  icon: Icons.push_pin_outlined,
                  title: loc.pushNotifications,
                  value: true,
                  onChanged: null,
                ),
                SettingsSwitchTile(
                  icon: Icons.email_outlined,
                  title: loc.emailNotifications,
                  value: false,
                  onChanged: null,
                  showDivider: false,
                ),
              ],
            ),

            // Section: Preferences
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
                    onChanged: null,
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

            // Danger Zone
            SettingsSectionTitle(loc.dangerZone),
            SettingsCard(
              children: [
                SettingsDangerButton(
                  icon: Icons.delete_forever_outlined,
                  title: loc.deleteAccount,
                  subtitle:
                      'Permanently delete your account and all associated data',
                  buttonLabel: loc.delete,
                  onPressed: null,
                ),
              ],
            ),

            // Save / Cancel (preserved, beautified)
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        save();
                      },
                      child: Text(loc.save),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: cancel,
                      child: Text(loc.cancel),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
