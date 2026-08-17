import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/widgets/drawer.dart';
import 'package:cosmox_client/presentation/widgets/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client/core/state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key, required this.title});

  final String title;

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(
      text: context.read<AuthController>().token ?? "",
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
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
                  onTap: () => context.push('/user/setting/sessions'),
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
