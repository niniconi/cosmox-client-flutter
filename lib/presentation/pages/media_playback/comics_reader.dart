import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cosmox_client/core/global_keys.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';

class ComicsPlayerPage extends StatefulWidget {
  const ComicsPlayerPage({super.key});
  @override
  State<ComicsPlayerPage> createState() => _ComicsPlayerPageState();
}

enum ScrollType { default_, upToDown, rightToLeft, leftToRight }

class _ComicsPlayerPageState extends State<ComicsPlayerPage> {
  final Logger _logger = Logger('ComicsPlayerPage');

  bool _showControlPanel = true;

  ScrollType selectedScrollType = ScrollType.default_;
  int _currentPage = 1;
  int pageCount = 84;
  int pageRenderLimit = 3;
  Color _backgroundColor = Colors.black;

  final ScrollController _scrollController = ScrollController();
  final Duration _fadeDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControlPanel = false;
        });
      }
    });
  }

  void _toggleFloatControlShow() {
    _logger.fine(
      'toggle float control panel show status to ${_showControlPanel.toString()}',
    );
    setState(() {
      _showControlPanel = !_showControlPanel;
    });
  }

  String _getUrl(int page) {
    return "https://archive.org/download/artbook_An_Omnipresence_in_Wired/An_Omnipresence_in_Wired.cbr/An%20Omnipresence%20in%20Wired%2Fscan$page.jpg";
  }

  Widget _buildPageImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      fadeInDuration: _fadeDuration,
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => Container(
        color: Colors.white.withAlpha(10),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.white.withAlpha(10),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined, color: Colors.grey, size: 32),
              SizedBox(height: 4),
              Text(
                'Failed to load',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPanel({required Widget child, double opacity = 0.85}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withAlpha((opacity * 255).round()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    Axis scrollDirection;
    bool reverse;

    switch (selectedScrollType) {
      case ScrollType.upToDown:
        scrollDirection = Axis.vertical;
        reverse = false;
        break;
      case ScrollType.leftToRight:
        scrollDirection = Axis.horizontal;
        reverse = false;
        break;
      case ScrollType.rightToLeft:
        scrollDirection = Axis.horizontal;
        reverse = true;
        break;
      case ScrollType.default_:
        scrollDirection = Axis.vertical;
        reverse = false;
        break;
    }

    List<String> pageUrls = List.generate(pageCount, (index) {
      return _getUrl(index + 1);
    });

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Comic pages
          GestureDetector(
            onTap: _toggleFloatControlShow,
            child: Container(
              color: _backgroundColor,
              child: ListView.builder(
                scrollDirection: scrollDirection,
                reverse: reverse,
                controller: _scrollController,
                itemCount: pageUrls.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: screenWidth,
                    child: GestureDetector(
                      onLongPress: () {},
                      child: _buildPageImage(pageUrls[index]),
                    ),
                  );
                },
              ),
            ),
          ),

          // Top control panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            left: 0,
            top: _showControlPanel ? 0 : -200,
            right: 0,
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showControlPanel ? 1.0 : 0.0,
              child: _buildGlassPanel(
                opacity: 0.7,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(AppLocalizations.of(context)!.myComics),
                ),
              ),
            ),
          ),

          // Bottom control panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            left: 10,
            right: 10,
            bottom: _showControlPanel ? 10 : -200,
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showControlPanel ? 1.0 : 0.0,
              child: _buildGlassPanel(
                child: SizedBox(
                  height: 75,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Text(
                        '$_currentPage / $pageCount',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Slider(
                          value: _currentPage.toDouble(),
                          max: pageCount.toDouble().clamp(1, double.infinity),
                          divisions: pageCount > 1 ? pageCount - 1 : null,
                          label: '$_currentPage / $pageCount',
                          onChanged: (double value) {
                            setState(() {
                              _currentPage = value.toInt();
                            });
                            final offset = scrollDirection == Axis.vertical
                                ? (_currentPage - 1) * screenHeight
                                : (_currentPage - 1) * screenWidth;
                            _scrollController.animateTo(
                              offset,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            showDragHandle: true,
                            context: context,
                            builder: (context) => ComicsViewModalBottomSheet(
                              scrollType: selectedScrollType,
                              pageCount: pageCount,
                              currentPage: _currentPage,
                              getUrl: _getUrl,
                              onPageTap: (page) {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                              backgroundColorSwitch: (color) {
                                setState(() {
                                  _backgroundColor = color;
                                });
                              },
                              scrollTypeSwitch: (scrollType) {
                                setState(() {
                                  selectedScrollType = scrollType;
                                });
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.grid_view_rounded),
                      ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            showDragHandle: true,
                            context: context,
                            builder: (context) => ComicsSettingModalBottomSheet(
                              scrollType: selectedScrollType,
                              backgroundColorSwitch: (color) {
                                setState(() {
                                  _backgroundColor = color;
                                });
                              },
                              scrollTypeSwitch: (scrollType) {
                                setState(() {
                                  selectedScrollType = scrollType;
                                });
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComicsSettingModalBottomSheet extends StatefulWidget {
  const ComicsSettingModalBottomSheet({
    super.key,
    required this.scrollTypeSwitch,
    required this.backgroundColorSwitch,
    required this.scrollType,
  });
  final ScrollType scrollType;
  final Function(ScrollType scrollType) scrollTypeSwitch;
  final Function(Color backgroundColor) backgroundColorSwitch;
  @override
  State<ComicsSettingModalBottomSheet> createState() => _ComicsSettingModalBottomSheetState();
}

class _ComicsSettingModalBottomSheetState
    extends State<ComicsSettingModalBottomSheet> {
  late ScrollType selectedScrollType;
  List<Color> colors = const [
    Color(0xFF343131),
    Color(0xFFDEAA79),
    Color(0xFFFFE6A9),
    Color(0xFFB1C29E),
    Color(0xFF659287),
    Color(0xFFEEDF7A),
    Color(0xFFD8A25E),
    Color(0xFFA04747),
    Color(0xFF5BBCFF),
    Color(0xFFFFFAB7),
    Color(0xFFFFD1E3),
    Color(0xFF7EA1FF),
  ];

  int selectedColorIndex = 3;

  @override
  void initState() {
    selectedScrollType = widget.scrollType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Actions
          Row(
            children: [
              _buildActionChip(
                icon: Icons.save_outlined,
                label: loc.savePicture,
                onTap: () {
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('保存功能开发中')),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildActionChip(
                icon: Icons.fullscreen_outlined,
                label: loc.routeScreen,
                onTap: () {
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('全屏切换功能开发中')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Reading direction
          Text(
            'Reading Direction',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ScrollType>(
              segments: [
                ButtonSegment(
                  value: ScrollType.default_,
                  icon: const Icon(Icons.vertical_align_bottom, size: 18),
                  label: const Text('Default', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: ScrollType.upToDown,
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  label: const Text('Up→Down', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: ScrollType.rightToLeft,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text(
                    loc.rightToLeft,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                ButtonSegment(
                  value: ScrollType.leftToRight,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    loc.leftToRight,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
              selected: {selectedScrollType},
              onSelectionChanged: (selected) {
                setState(() {
                  selectedScrollType = selected.first;
                });
                widget.scrollTypeSwitch(selected.first);
              },
              showSelectedIcon: false,
            ),
          ),

          const SizedBox(height: 20),

          // Background color
          Text(
            loc.backgroundColor,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(colors.length, (index) {
              final isSelected = index == selectedColorIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColorIndex = index;
                  });
                  widget.backgroundColorSwitch(colors[index]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 44 : 36,
                  height: isSelected ? 44 : 36,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(isSelected ? 22 : 18),
                    color: colors[index],
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors[index].withAlpha(100),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class ComicsViewModalBottomSheet extends StatefulWidget {
  const ComicsViewModalBottomSheet({
    super.key,
    required this.scrollTypeSwitch,
    required this.backgroundColorSwitch,
    required this.scrollType,
    required this.pageCount,
    required this.currentPage,
    required this.getUrl,
    required this.onPageTap,
  });
  final ScrollType scrollType;
  final Function(ScrollType scrollType) scrollTypeSwitch;
  final Function(Color backgroundColor) backgroundColorSwitch;
  final int pageCount;
  final int currentPage;
  final Function(int) getUrl;
  final Function(int) onPageTap;
  @override
  State<ComicsViewModalBottomSheet> createState() => _ComicsViewsModalBottomSheetState();
}

class _ComicsViewsModalBottomSheetState
    extends State<ComicsViewModalBottomSheet> {
  late ScrollType selectedScrollType;
  List<Color> colors = const [
    Color(0xFF343131),
    Color(0xFFDEAA79),
    Color(0xFFFFE6A9),
    Color(0xFFB1C29E),
    Color(0xFF659287),
    Color(0xFFEEDF7A),
    Color(0xFFD8A25E),
    Color(0xFFA04747),
    Color(0xFF5BBCFF),
    Color(0xFFFFFAB7),
    Color(0xFFFFD1E3),
    Color(0xFF7EA1FF),
  ];

  int selectedColorIndex = 3;

  @override
  void initState() {
    selectedScrollType = widget.scrollType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 800,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "Catalog"),
                Tab(text: "Preview"),
                Tab(text: "Settings"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: widget.pageCount,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          widget.onPageTap(index + 1);
                          Navigator.pop(context);
                        },
                        child: CachedNetworkImage(
                          imageUrl: widget.getUrl(index + 1).toString(),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  Wrap(
                    children: List.generate(widget.pageCount, (index) {
                      return CachedNetworkImage(
                        imageUrl: widget.getUrl(index + 1).toString(),
                        width: 100,
                        height: 200,
                      );
                    }),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.brightness_6),
                          title: const Text('背景颜色'),
                          subtitle: const Text('选择阅读背景颜色'),
                        ),
                        Wrap(
                          children: List.generate(colors.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.all(5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColorIndex = index;
                                  });
                                  widget.backgroundColorSwitch(colors[index]);
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: index == selectedColorIndex
                                        ? Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            width: 2,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(25),
                                    color: colors[index],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
