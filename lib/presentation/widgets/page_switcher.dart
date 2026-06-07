import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageSwitcher extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PageSwitcher({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : assert(currentPage >= 1 && totalPages >= 1);

  @override
  State<PageSwitcher> createState() => _PageSwitcherState();
}

class _PageSwitcherState extends State<PageSwitcher> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleJump() {
    final value = int.tryParse(_controller.text);
    if (value != null && value >= 1 && value <= widget.totalPages) {
      widget.onPageChanged(value);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.currentPage > 1
                  ? () => widget.onPageChanged(1)
                  : null,
              icon: const Icon(Icons.first_page),
              tooltip: 'First Page',
            ),
            IconButton.filledTonal(
              onPressed: widget.currentPage > 1
                  ? () => widget.onPageChanged(widget.currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
              tooltip: AppLocalizations.of(context)!.previousPage,
            ),
          ],
        ),

        _buildPageNumbers(colorScheme),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              onPressed: widget.currentPage < widget.totalPages
                  ? () => widget.onPageChanged(widget.currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next Page',
            ),
            IconButton(
              onPressed: widget.currentPage < widget.totalPages
                  ? () => widget.onPageChanged(widget.totalPages)
                  : null,
              icon: const Icon(Icons.last_page),
              tooltip: 'Last Page',
            ),
          ],
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Go to'),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              height: 40,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => _handleJump(),
              ),
            ),
            IconButton(
              onPressed: _handleJump,
              icon: const Icon(Icons.arrow_forward, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageNumbers(ColorScheme colorScheme) {
    List<int> pages = [];
    if (widget.totalPages <= 5) {
      pages = List.generate(widget.totalPages, (i) => i + 1);
    } else {
      if (widget.currentPage <= 3) {
        pages = [1, 2, 3, 4, 5];
      } else if (widget.currentPage >= widget.totalPages - 2) {
        pages = List.generate(5, (i) => widget.totalPages - 4 + i);
      } else {
        pages = [
          widget.currentPage - 2,
          widget.currentPage - 1,
          widget.currentPage,
          widget.currentPage + 1,
          widget.currentPage + 2,
        ];
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pages.map((page) {
        final isSelected = page == widget.currentPage;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: isSelected
              ? FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: null,
                  child: Text('$page'),
                )
              : OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  onPressed: () => widget.onPageChanged(page),
                  child: Text(
                    '$page',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
        );
      }).toList(),
    );
  }
}
