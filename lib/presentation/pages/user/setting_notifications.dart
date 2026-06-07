import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/widgets/drawer.dart';
import 'package:cosmox_client/presentation/widgets/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key, required this.title});

  final String title;

  @override
  State<NotificationSettingPage> createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;

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
            SettingsSectionTitle(loc.notifications),
            SettingsCard(
              children: [
                SettingsSwitchTile(
                  icon: Icons.push_pin_outlined,
                  title: loc.pushNotifications,
                  value: _pushEnabled,
                  onChanged: (val) {
                    setState(() => _pushEnabled = val);
                  },
                ),
                SettingsSwitchTile(
                  icon: Icons.email_outlined,
                  title: loc.emailNotifications,
                  value: _emailEnabled,
                  onChanged: (val) {
                    setState(() => _emailEnabled = val);
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
