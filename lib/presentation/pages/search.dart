import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class SearchHistory {
  final String title;
  const SearchHistory({required this.title});
}

class SearchCategory {
  final IconData icon;
  final String label;
  const SearchCategory({required this.icon, required this.label});
}

class _SearchPageState extends State<SearchPage> {
  final Logger _logger = Logger('SearchPage');
  final List<SearchHistory> _histories = [];
  final List<SearchHistory> _suggestions = const [
    SearchHistory(title: 'One Piece'),
    SearchHistory(title: 'Family Guy'),
    SearchHistory(title: 'Rick and Morty'),
    SearchHistory(title: 'Demon Slayer'),
    SearchHistory(title: 'Attack on Titan'),
  ];
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;

    // Add to history
    final existingIndex = _histories.indexWhere((h) => h.title == query.trim());
    if (existingIndex != -1) {
      _histories.removeAt(existingIndex);
    }
    _histories.insert(0, SearchHistory(title: query.trim()));
    if (_histories.length > 10) {
      _histories.removeLast();
    }

    setState(() => _searchQuery = query.trim());

    // Simulate search (replace with actual SdkProxy call)
    _logger.fine('Searching: $query');
  }

  void _deleteHistory(int index) {
    setState(() {
      _histories.removeAt(index);
    });
  }

  void _clearHistory() {
    setState(() {
      _histories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.search),
        actions: [
          if (_histories.isNotEmpty && _searchQuery == null)
            TextButton(
              onPressed: _clearHistory,
              child: Text(
                AppLocalizations.of(context)!.clear,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: AppLocalizations.of(context)!.searchHint,
              leading: const Icon(Icons.search),
              trailing: _searchController.text.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = null);
                        },
                      ),
                    ]
                  : null,
              onChanged: (value) {
                if (value.isEmpty && _searchQuery != null) {
                  setState(() => _searchQuery = null);
                } else {
                  setState(() {});
                }
              },
              onSubmitted: _onSearch,
            ),
          ),
          Expanded(child: _buildContent(colorScheme, textTheme, _searchQuery)),
        ],
      ),
    );
  }

  Widget _buildContent(
    ColorScheme colorScheme,
    TextTheme textTheme,
    String? query,
  ) {
    if (query != null) {
      return _buildSearchResults(colorScheme, textTheme, query);
    }

    return _buildHistoryAndSuggestions(colorScheme, textTheme);
  }

  Widget _buildHistoryAndSuggestions(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_histories.isNotEmpty) ...[
          _buildSectionHeader(
            AppLocalizations.of(context)!.recentSearches,
            textTheme,
            onClear: _clearHistory,
          ),
          const SizedBox(height: 8),
          ...List.generate(_histories.length, (index) {
            return _buildHistoryTile(index, colorScheme);
          }),
          const SizedBox(height: 24),
        ],
        _buildSectionHeader(
          AppLocalizations.of(context)!.popularSearches,
          textTheme,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions.map((s) {
            return ActionChip(
              avatar: const Icon(Icons.trending_up, size: 18),
              label: Text(s.title),
              onPressed: () {
                _searchController.text = s.title;
                _onSearch(s.title);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          AppLocalizations.of(context)!.browseCategories,
          textTheme,
        ),
        const SizedBox(height: 12),
        _buildCategoryGrid(colorScheme),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    TextTheme textTheme, {
    VoidCallback? onClear,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (onClear != null)
          TextButton(onPressed: onClear, child: const Text('Clear all')),
      ],
    );
  }

  Widget _buildHistoryTile(int index, ColorScheme colorScheme) {
    final history = _histories[index];
    return ListTile(
      leading: Icon(Icons.history, color: colorScheme.outline),
      title: Text(history.title),
      trailing: IconButton(
        icon: Icon(Icons.close, size: 20, color: colorScheme.outline),
        onPressed: () => _deleteHistory(index),
      ),
      onTap: () {
        _searchController.text = history.title;
        _onSearch(history.title);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }

  Widget _buildCategoryGrid(ColorScheme colorScheme) {
    const categories = <SearchCategory>[
      SearchCategory(icon: Icons.movie, label: 'Movies'),
      SearchCategory(icon: Icons.tv, label: 'TV Shows'),
      SearchCategory(icon: Icons.music_note, label: 'Music'),
      SearchCategory(icon: Icons.book, label: 'Books'),
      SearchCategory(icon: Icons.games, label: 'Games'),
      SearchCategory(icon: Icons.image, label: 'Images'),
      SearchCategory(icon: Icons.article, label: 'Documents'),
      SearchCategory(icon: Icons.folder, label: 'Archives'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () => _onSearch(category.label),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category.icon, size: 28),
                const SizedBox(height: 4),
                Text(
                  category.label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(
    ColorScheme colorScheme,
    TextTheme textTheme,
    String query,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noResultsFound,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.of(context)!.noResultsFor} "$query"',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = null);
            },
            icon: const Icon(Icons.arrow_back),
            label: Text(AppLocalizations.of(context)!.backToSearch),
          ),
        ],
      ),
    );
  }
}
