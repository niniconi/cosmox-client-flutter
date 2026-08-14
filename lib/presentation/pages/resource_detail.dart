import 'dart:ui';

import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/pages/error.dart';
import 'package:cosmox_client/presentation/pages/resource_detail/cast_tab.dart';
import 'package:cosmox_client/presentation/pages/resource_detail/episodes_tab.dart';
import 'package:cosmox_client/presentation/pages/resource_detail/intro_tab.dart';
import 'package:cosmox_client/presentation/pages/resource_detail/metadata_parser.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// One resource's assembled detail view: the base [Resource] row plus its
/// metadata tree root ([MetadataNode], the same `rid`).
typedef Detail = ({Resource resource, MetadataNode metadata});

class ResourceDetailPage extends StatefulWidget {
  const ResourceDetailPage({super.key, required this.rid});
  final int rid;

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  final Logger _logger = Logger('ResourceDetailPage');
  final Detail _dumpyData = (
    resource: Resource(
      rid: BigInt.zero,
      name: "    ",
      description: "",
      createDatetime: DateTime.now(),
      lastUpdateDatetime: DateTime.now(),
    ),
    metadata: _emptyMetadata(),
  );
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
      _logger.severe('Failed to fetch resource', error);
      return null;
    }
  }

  Future<MetadataNode?> _fetchMetadata() async {
    try {
      return SdkProxy.instance.metadataQuery(
        rootNode: BigInt.from(widget.rid),
        depth: BigInt.from(4),
      );
    } catch (error) {
      _logger.severe('Failed to fetch metadata', error);
      return null;
    }
  }

  Future<Detail?> _fetchDetail() async {
    final resource = await _fetchResource();
    final metadata = await _fetchMetadata();
    if (resource != null && metadata != null) {
      return (resource: resource, metadata: metadata);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetail();
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

  Widget _buildContent({required bool isLoading, required Detail data}) {
    final resource = data.resource;
    final metadata = data.metadata;
    final extend = metadata.extend;
    final coverFuture = coverUrl(metadata.coverFileMapId);
    var rating = extendValue(extend, 'rating');
    if (rating.isEmpty) rating = extendValue(extend, 'score');
    final platform = extendValue(extend, 'platform');
    final eps = extendValue(extend, 'eps');
    final startDate = extendValue(extend, 'start_date');
    final title = titleFromJson(extendValue(extend, 'titles'));
    final displayTitle = title.isNotEmpty
        ? title
        : (resource.name ?? 'Unknown name');

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
                              child: _buildPoster(coverFuture),
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
                                    child: Text(displayTitle),
                                  ),
                                  if (!isCollapsed) ...[
                                    const SizedBox(height: 8),
                                    if (rating.isNotEmpty)
                                      _buildScoreBadge(rating),
                                    const SizedBox(height: 8),
                                    Text(
                                      _subtitle(platform, eps, startDate),
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
              dividerColor: Theme.of(context).colorScheme.outline.withAlpha(0),
              tabs: [
                Tab(text: AppLocalizations.of(context)!.introduction),
                Tab(text: AppLocalizations.of(context)!.episodes),
                Tab(text: AppLocalizations.of(context)!.castTab),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              children: [
                IntroTab(metadata: metadata),
                EpisodesTab(metadata: metadata),
                CastTab(metadata: metadata),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(String platform, String eps, String startDate) {
    final parts = <String>[
      if (platform.isNotEmpty) platform,
      if (eps.isNotEmpty) '$eps集',
      if (startDate.isNotEmpty) startDate,
    ];
    return parts.isEmpty ? '' : parts.join(' / ');
  }

  Widget _buildPoster(Future<String?> coverUrl) {
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
          child: FutureBuilder<String?>(
            future: coverUrl,
            builder: (context, snapshot) {
              final url = snapshot.hasData ? snapshot.data : null;
              if (url == null) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                );
              }
              return SdkProxy.instance.authImage(url, context: context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(String score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Score $score',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

MetadataNode _emptyMetadata() {
  return MetadataNode(
    lid: BigInt.zero,
    rid: BigInt.zero,
    fileSize: BigInt.zero,
    fileCnt: BigInt.zero,
    name: "",
    aliasName: const [],
    originName: "",
    description: "",
    flags: 0,
    metadataType: MetadataType.virtual,
    origin: "",
    dataFileMapId: null,
    coverFileMapId: null,
    subMetadatas: const [],
    url: "",
    checksum: "",
    extend: const {},
  );
}
