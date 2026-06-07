import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/widgets/drawer.dart';
import 'package:cosmox_client/presentation/widgets/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DangerSettingPage extends StatefulWidget {
  const DangerSettingPage({super.key, required this.title});

  final String title;

  @override
  State<DangerSettingPage> createState() => _DangerSettingPageState();
}

class _DangerSettingPageState extends State<DangerSettingPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    void confirmDelete() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(loc.warning),
          content: Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(loc.delete),
            ),
          ],
        ),
      );
    }

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
            SettingsSectionTitle(loc.dangerZone),
            SettingsCard(
              children: [
                SettingsDangerButton(
                  icon: Icons.delete_forever_outlined,
                  title: loc.deleteAccount,
                  subtitle:
                      'Permanently delete your account and all associated data',
                  buttonLabel: loc.delete,
                  onPressed: confirmDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
