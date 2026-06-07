import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:flutter/material.dart';

/// Section title — matches UserPage header styling
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Card — matches UserPage card style: radius 20, no border
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// ListTile — matches UserPage tile style: vertical 4 padding
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing:
              trailing ??
              (onTap != null
                  ? const Icon(Icons.chevron_right, size: 20)
                  : null),
          onTap: onTap,
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
}

/// Switch tile with label
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: Switch(value: value, onChanged: onChanged),
          onTap: onChanged != null ? () => onChanged!(!value) : null,
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
}

/// Form field wrapped in a card-compatible layout
class SettingsFormField extends StatelessWidget {
  const SettingsFormField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.helpText,
    this.showDivider = true,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final String? helpText;
  final bool showDivider;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: InputFormField(
            labelText: label,
            controller: controller,
            validator: validator,
            helpText: helpText,
            maxLines: maxLines,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Theme.of(context).colorScheme.outlineVariant.withAlpha(40),
          ),
      ],
    );
  }
}

/// Danger action button row
class SettingsDangerButton extends StatelessWidget {
  const SettingsDangerButton({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 2,
          ),
          leading: Icon(icon, color: theme.colorScheme.error),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.error,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    color: theme.colorScheme.error.withAlpha(180),
                  ),
                )
              : null,
          trailing: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}
