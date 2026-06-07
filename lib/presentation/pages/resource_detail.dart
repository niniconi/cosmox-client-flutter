import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:cosmox_client/presentation/pages/error.dart';

typedef Detail = (List<Tag>, Resource);

class ResourceDetailPage extends StatefulWidget {
  const ResourceDetailPage({super.key, required this.rid});
  final int rid;

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  final Logger _logger = Logger('ResourceDetailPage');
  final Detail _dumpyData = (
    <Tag>[],
    Resource(
      rid: BigInt.zero,
      name: "    ",
      description: "",
      createDatetime: DateTime.now(),
      lastUpdateDatetime: DateTime.now(),
    ),
  );
  final List<String> _tags = [
    '科幻',
    '百合',
    'TV',
    '日本',
    '原创',
    '意识流',
    '实验动画',
    '1998',
    '赛博朋克',
    'Lain',
    '安倍吉俊',
    '内涵',
    '中村隆太郎',
    ' 庵野秀明',
    '八成也看不懂',
    ' 小中千昭, 内涵系, 电波',
    '年代',
    '神作',
    'SF',
    '1998年',
  ];
  final double _score = 7.8;
  late Future<Detail?> _detailFuture;

  void _refresh() {
    setState(() {
      _detailFuture = _fetchDetail();
    });
  }

  Future<Resource?> _fetchResource() async {
    try {
      return SdkProxy.instance.resourceGet(rid: BigInt.from(widget.rid));
    } catch (error) {
      _logger.severe('Failed to fetch resource: $error');
      return null;
    }
  }

  Future<List<Tag>?> _fetchTags() async {
    return <Tag>[];
  }

  Future<Detail?> _fetchDetail() async {
    final resource = await _fetchResource();
    final tag = await _fetchTags();

    if (resource != null && tag != null) {
      return (tag, resource);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetail();
  }

  Widget _buildTagList() {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _tags
          .map(
            (tag) => ActionChip(
              label: Text(tag),
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: null,
            ),
          )
          .toList(),
    );
  }

  Widget _buildContent({required bool isLoading, required Detail data}) {
    final (tags, resource) = data;
    return Skeletonizer(
      enabled: isLoading,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            actions: [
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                double top = constraints.biggest.height;
                double statusBarHeight = MediaQuery.of(context).padding.top;
                bool isCollapsed =
                    top <= (statusBarHeight + kToolbarHeight + 20);

                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      const SizedBox.shrink(),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.shadow.withAlpha(75),
                                Theme.of(context).colorScheme.surface,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: statusBarHeight + 10,
                          left: 20,
                        ),
                        child: Row(
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isCollapsed ? 0 : 1,
                              child: _buildPoster(resource),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: isCollapsed ? 20 : 26,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    child: Text(resource.name ?? "Unkown name"),
                                  ),
                                  if (!isCollapsed) ...[
                                    const SizedBox(height: 8),
                                    _buildScoreBadge(),
                                    const SizedBox(height: 8),
                                    Text(
                                      "13集全 / 意识流经典",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            bottom: TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors
                  .transparent, // Colors.transparent is safe—no branding needed
              tabs: [
                Tab(text: AppLocalizations.of(context)!.introduction),
                Tab(text: AppLocalizations.of(context)!.episodes),
                Tab(text: AppLocalizations.of(context)!.reviews),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              children: [
                _buildIntroTab(resource),
                Center(child: Text(AppLocalizations.of(context)!.episodeList)),
                Center(
                  child: Text(AppLocalizations.of(context)!.reviewSection),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: null,
          label: Text(AppLocalizations.of(context)!.playNow),
          icon: const Icon(Icons.play_arrow),
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        body: FutureBuilder(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildContent(isLoading: true, data: _dumpyData);
            }
            if (snapshot.hasError || snapshot.data == null) {
              return ErrorBlock(
                message: snapshot.hasError
                    ? '${snapshot.error}'
                    : 'Resource not found',
                onRetry: _refresh,
              );
            }
            return _buildContent(isLoading: false, data: snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildPoster(Resource resource) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.outline.withAlpha(66),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(color: Colors.grey[900]),
        ),
      ),
    );
  }

  Widget _buildScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "Score $_score",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIntroTab(Resource resource) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.plotSummary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "",
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 25),
          Text(
            AppLocalizations.of(context)!.coreTags,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          _buildTagList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
