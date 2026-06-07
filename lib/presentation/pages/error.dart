import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum ErrorType { notFound, error }

/// Full-page error display for critical failures (big errors).
///
/// [notFound] — 404 page with illustration and home link.
/// [error] — Generic error with details, retry, and home link.
class ErrorPage extends StatelessWidget {
  final ErrorType type;
  final String? title;
  final String? message;
  final String? details;
  final VoidCallback? onRetry;

  const ErrorPage({
    super.key,
    this.type = ErrorType.notFound,
    this.title,
    this.message,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isNotFound = type == ErrorType.notFound;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isNotFound ? cs.tertiaryContainer : cs.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNotFound
                      ? Icons.search_off_rounded
                      : Icons.error_outline_rounded,
                  size: 56,
                  color: isNotFound
                      ? cs.onTertiaryContainer
                      : cs.onErrorContainer,
                ),
              ),
              const SizedBox(height: 32),

              // Error code badge (for 404)
              if (isNotFound)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '404',
                    style: textTheme.labelLarge?.copyWith(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              if (isNotFound) const SizedBox(height: 16),

              // Title
              Text(
                title ??
                    (isNotFound ? 'Page Not Found' : 'Something Went Wrong'),
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message ??
                    (isNotFound
                        ? 'The page you are looking for does not exist or has been moved.'
                        : 'An unexpected error occurred. Please try again.'),
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              // Error details (expandable, for big errors)
              if (details != null && details!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _ErrorDetails(details: details!),
              ],

              const SizedBox(height: 36),

              // Action buttons
              if (onRetry != null) ...[
                SizedBox(
                  width: 260,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: FilledButton.styleFrom(
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
                const SizedBox(height: 14),
              ],
              SizedBox(
                width: 260,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go Home'),
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

/// Collapsible error detail section for technical information.
class _ErrorDetails extends StatefulWidget {
  final String details;
  const _ErrorDetails({required this.details});

  @override
  State<_ErrorDetails> createState() => _ErrorDetailsState();
}

class _ErrorDetailsState extends State<_ErrorDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            size: 18,
          ),
          label: Text(_expanded ? 'Hide Details' : 'Show Details'),
        ),
        if (_expanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              widget.details,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

/// Inline error widget for embedding inside pages (big error within a card/section).
class ErrorBlock extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorBlock({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: cs.error),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
