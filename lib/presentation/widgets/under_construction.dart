import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';

/// Inline under-construction placeholder for embedding inside pages
/// (e.g. inside a ShellRoute or an existing Scaffold).
///
/// Contains the shared icon + message UI that both [UnderConstructionPage]
/// and inline placeholders render.
class UnderConstructionWidget extends StatelessWidget {
  final String? message;
  final Widget? child;

  const UnderConstructionWidget({super.key, this.message, this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction_rounded,
                size: 56,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              message ?? AppLocalizations.of(context)!.underConstruction,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.thisFeatureIsComingSoon,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (child != null) ...[const SizedBox(height: 24), child!],
          ],
        ),
      ),
    );
  }
}

/// Full-page under construction display, usable as a GoRoute destination.
/// Delegates its icon + message content to [UnderConstructionWidget].
class UnderConstructionPage extends StatelessWidget {
  final String? message;
  const UnderConstructionPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UnderConstructionWidget(message: message),
              const SizedBox(height: 36),
              SizedBox(
                width: 260,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(AppLocalizations.of(context)!.goBack),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showUnderConstructionSnackBar(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.construction, color: colorScheme.onPrimary),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.thisFeatureIsUnderConstruction),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.primary,
      duration: const Duration(seconds: 2),
    ),
  );
}
