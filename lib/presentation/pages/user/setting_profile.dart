import 'package:cosmox_client_flutter/core/common.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/presentation/widgets/drawer.dart';
import 'package:cosmox_client_flutter/presentation/widgets/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingPage extends StatefulWidget {
  const ProfileSettingPage({super.key, required this.title});

  final String title;

  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
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
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(loc.addAvatar),
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
                      onPressed: null,
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
                      onPressed: () => context.pop(),
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
