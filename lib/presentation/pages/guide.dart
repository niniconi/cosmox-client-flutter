import 'package:cosmox_client_flutter/presentation/widgets/form.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/models/lang.dart';
import 'package:cosmox_client_flutter/models/location.dart';
import 'package:cosmox_client_flutter/core/state.dart';
import 'package:cosmox_client_flutter/core/common.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:responsive_framework/responsive_framework.dart';

String _adminPassword = '';
String _adminConfirmPassword = '';

// Guide Shell — thick M3 animated progress bar
// + step dots + fade-slide page transition

class GuideShellPage extends StatelessWidget {
  final Widget child;
  final int currentStep;

  static const int totalSteps = 4;

  const GuideShellPage({
    super.key,
    required this.child,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back + animated progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  if (currentStep > 1)
                    IconButton(
                      onPressed: () => context.go('/guide/${currentStep - 1}'),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  const SizedBox(width: 8),
                  Expanded(child: _M3ProgressBar(currentStep: currentStep)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Animated page content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(key: ValueKey(currentStep), child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thick M3-style progress bar with animated fill + step dots.
///
/// Uses a continuous rounded bar that smoothly fills from the previous
/// step position (not from 0) thanks to begin=(currentStep-1)/total.
class _M3ProgressBar extends StatelessWidget {
  final int currentStep;
  const _M3ProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = GuideShellPage.totalSteps;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Step dots
        Row(
          children: List.generate(total, (i) {
            final isDone = i < currentStep;
            return Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  width: isDone ? 8 : 6,
                  height: isDone ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? cs.primary : cs.surfaceContainerHighest,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Thick animated bar (animates from previous step, not 0)
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                // Background track
                Container(height: 12, color: cs.surfaceContainerHighest),
                // Animated fill
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: (currentStep - 1) / total,
                    end: currentStep / total,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  builder: (context, value, _) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          gradient: value > 0
                              ? LinearGradient(
                                  colors: [
                                    cs.primary,
                                    cs.primary.withValues(alpha: 0.85),
                                  ],
                                  stops: const [0.0, 1.0],
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Step 1 — Welcome

class GuideStep1Page extends StatefulWidget {
  const GuideStep1Page({super.key});

  @override
  State<GuideStep1Page> createState() => _GuideStep1PageState();
}

class _GuideStep1PageState extends State<GuideStep1Page> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: isMobile ? 96 : 112,
                  height: isMobile ? 96 : 112,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    size: isMobile ? 44 : 56,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 36),
                Text(
                  AppLocalizations.of(context)!.welcomeToUse,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 32),
                  child: Text(
                    AppLocalizations.of(context)!.exploreTheUniverse,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 36 : 48),
                // Button with safe margin on mobile
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                  child: SizedBox(
                    width: isDesktop ? 360 : double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () => context.go('/guide/2'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.startUse),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Step 2 — Create admin account

class GuideStep2Page extends StatefulWidget {
  const GuideStep2Page({super.key});

  @override
  State<GuideStep2Page> createState() => _GuideStep2PageState();
}

class _GuideStep2PageState extends State<GuideStep2Page> {
  final Logger _logger = Logger('GuidePage');
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String nickname = '';
  String password = '';
  String confirmPassword = '';

  Future<bool> _initServer() async {
    try {
      SdkProxy.instance.initialize(
        adminPassword: _adminPassword,
        confirmPassword: _adminConfirmPassword,
      );
      return true;
    } catch (error) {
      _logger.severe('Init Server failed: $error');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  AppLocalizations.of(context)!.createAdminAccount,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.setupAdminAccount,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 32),
                Center(
                  child: MaxWidthBox(
                    maxWidth: 480,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputFormField(
                              labelText: AppLocalizations.of(context)!.username,
                              onSaved: (val) {
                                if (val != null) username = val;
                              },
                              validator: (val) => Validate.username(val),
                            ),
                            const SizedBox(height: 14),
                            InputFormField(
                              labelText: AppLocalizations.of(context)!.nickname,
                              onSaved: (val) {
                                if (val != null) nickname = val;
                              },
                            ),
                            const SizedBox(height: 14),
                            InputFormField(
                              labelText: AppLocalizations.of(context)!.password,
                              onChanged: (val) {
                                password = val;
                                _adminPassword = val;
                              },
                              validator: (val) => Validate.password(val),
                            ),
                            const SizedBox(height: 14),
                            InputFormField(
                              labelText: AppLocalizations.of(
                                context,
                              )!.confirmPassword,
                              validator: (val) {
                                if (password != val) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.passwordNotMatch;
                                }
                                _adminConfirmPassword = val!;
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
                  child: SizedBox(
                    width: isDesktop ? 480 : double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final isSuccess = await _initServer();
                          if (isSuccess) {
                            if (!mounted || !context.mounted) return;
                            context.go('/guide/3');
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.createAccount),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Step 3 — Library Setup

class GuideStep3Page extends StatefulWidget {
  const GuideStep3Page({super.key});

  @override
  State<GuideStep3Page> createState() => _GuideStep3PageState();
}

class _GuideStep3PageState extends State<GuideStep3Page> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: isMobile ? 80 : 96,
                  height: isMobile ? 80 : 96,
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.library_books_rounded,
                    size: isMobile ? 40 : 48,
                    color: cs.onTertiaryContainer,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 28),
                Text(
                  AppLocalizations.of(context)!.librarySetup,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.manageLibraries,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 28),
                Center(
                  child: MaxWidthBox(
                    maxWidth: 480,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          _ChecklistRow(
                            icon: Icons.check_circle,
                            iconColor: cs.primary,
                            text: AppLocalizations.of(
                              context,
                            )!.adminAccountCreated,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(height: 1),
                          ),
                          _ChecklistRow(
                            icon: Icons.radio_button_unchecked,
                            iconColor: cs.outline,
                            text: AppLocalizations.of(context)!.addFirstLibrary,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(height: 1),
                          ),
                          _ChecklistRow(
                            icon: Icons.radio_button_unchecked,
                            iconColor: cs.outline,
                            text: AppLocalizations.of(
                              context,
                            )!.configureLanguageRegion,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 32),
                Center(
                  child: SizedBox(
                    width: isMobile ? double.infinity : 280,
                    height: 50,
                    child: FilledButton(
                      onPressed: () => context.go('/guide/4'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.continueAction),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _ChecklistRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 14),
        Expanded(child: Text(text, style: textTheme.bodyMedium)),
      ],
    );
  }
}

// Step 4 — Language & region

class GuideStep4Page extends StatefulWidget {
  const GuideStep4Page({super.key});

  @override
  State<GuideStep4Page> createState() => _GuideStep4PageState();
}

class _GuideStep4PageState extends State<GuideStep4Page> {
  final Logger _logger = Logger('GuidePage');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    final languageEntries = LanguageLabel.langSet.map((e) {
      return DropdownMenuEntry(value: e.languageCode, label: e.label);
    }).toList();

    final locationEntries = LocationLabel.locationSet.map((e) {
      return DropdownMenuEntry(value: e.nationCode, label: e.label);
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: isMobile ? 72 : 80,
                  height: isMobile ? 72 : 80,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    size: isMobile ? 32 : 40,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                Text(
                  AppLocalizations.of(context)!.settings,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 28),
                Center(
                  child: MaxWidthBox(
                    maxWidth: 480,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          DropdownMenu(
                            initialSelection: languageEntries[0],
                            dropdownMenuEntries: languageEntries,
                            label: Text(AppLocalizations.of(context)!.language),
                            onSelected: (index) {
                              _logger.fine('index $index');
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownMenu(
                            initialSelection: locationEntries[0],
                            dropdownMenuEntries: locationEntries,
                            label: Text(AppLocalizations.of(context)!.region),
                            onSelected: (index) {
                              _logger.fine('index $index');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 28),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
                  child: SizedBox(
                    width: isDesktop ? 480 : double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () =>
                          context.read<AuthController>().stateNext(),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.confirm),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
