import 'package:cosmox_client/core/global_keys.dart';
import 'package:cosmox_client/presentation/widgets/page_switcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';

class LibraryViewPage extends StatefulWidget {
  const LibraryViewPage({super.key, required this.lid});
  final int lid;
  @override
  State<StatefulWidget> createState() => _LibraryViewerPageState();
}

class _LibraryViewerPageState extends State<LibraryViewPage> {
  final Logger _logger = Logger('LibraryViewPage');
  final int _pageSize = 20;
  int _pageCount = 1;
  int _page = 1;
  List<Resource> _resources = [];

  void _fetchResourcesByLid() async {
    _logger.fine('fetch page $_page');
    try {
      final resources = await SdkProxy.instance.resourceQuery();
      _logger.fine('fetched ${resources.length} resources');
      if (!mounted) return;
      setState(() {
        _resources = resources;
        _pageCount = resources.length < _pageSize ? _page : _page + 1;
      });
    } catch (error) {
      _logger.severe('Failed to fetch resources', error);
      if (!mounted) return;
      setState(() => _resources.clear());
      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to fetch resources: $error")),
      );
    }
  }

  Widget _buildResourceCard(int index) {
    Resource resource = _resources[index];
    String title = resource.name ?? "Unknown name";
    Widget coverImage = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => context.push("/resource/${_resources[index].rid}"),
            onSecondaryTap: () {},
            child: Container(
              height: 200,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                //image: DecorationImage(image: getCover(index), fit: BoxFit.cover),
              ),
              child: coverImage,
            ),
          ),
        ),

        Text(title, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(50),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              mainAxisExtent: 250,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Center(
                child: SizedBox(
                  width: 150,
                  height: 250,
                  child: _buildResourceCard(index),
                ),
              ),
              childCount: _resources.length,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: PageSwitcher(
                currentPage: _page,
                totalPages: _pageCount,
                onPageChanged: (page) {
                  setState(() => _page = page);
                  _fetchResourcesByLid();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Positioned(child: _buildMainContent()),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(27, (index) {
              String text = "#";
              if (index < 26) {
                text = String.fromCharCode(65 + index);
              }
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => _logger.fine('click $text'),
                  child: Text(text),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchResourcesByLid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(/*lib.title ??*/ "None"),
      ),
      body: _buildContent(),
    );
  }
}
