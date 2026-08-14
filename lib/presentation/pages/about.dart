import 'package:cosmox_client/core/global_keys.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client/presentation/widgets/drawer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/core/app_info.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final Logger _logger = Logger('AboutPage');
  final FocusNode _focusNode = FocusNode();
  late final Future<SystemInfo> _serverInfoFuture;

  /// Skeletonizer dummy data to keep layout stable while loading.
  static const SystemInfo _dumpyData = SystemInfo(
    version: 'x.x.x',
    os: 'Loading...',
    name: '',
    author: '',
    isFirstBoot: false,
  );
  LogicalKeyboardKey? _lastDebugKey;

  static const String _repositoryUrl = 'https://github.com/niniconi/cosmox';

  Future<SystemInfo> _fetchServerInfo() async {
    try {
      final info = await SdkProxy.instance.systemInfo();
      _logger.fine('Server info loaded: ${info.version}');
      return info;
    } catch (error) {
      _logger.severe('Failed to fetch server info', error);
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _serverInfoFuture = _fetchServerInfo();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() => _serverInfoFuture = _fetchServerInfo());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.keyD:
              _lastDebugKey = event.logicalKey;
            case LogicalKeyboardKey.keyE:
              if (_lastDebugKey == LogicalKeyboardKey.keyD) {
                _lastDebugKey = event.logicalKey;
              } else {
                _lastDebugKey = null;
              }
            case LogicalKeyboardKey.keyB:
              if (_lastDebugKey == LogicalKeyboardKey.keyE) {
                _lastDebugKey = event.logicalKey;
              } else {
                _lastDebugKey = null;
              }
            case LogicalKeyboardKey.keyU:
              if (_lastDebugKey == LogicalKeyboardKey.keyB) {
                _lastDebugKey = event.logicalKey;
              } else {
                _lastDebugKey = null;
              }
            case LogicalKeyboardKey.keyG:
              if (_lastDebugKey == LogicalKeyboardKey.keyU) {
                _lastDebugKey = null;
                context.push('/debug');
              }
            default:
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.about),
        ),
        drawer: const HomeDrawerComponent(),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: _buildAppIcon(colorScheme)),
            const SizedBox(height: 24),
            _buildVersionCard(theme, colorScheme),
            const SizedBox(height: 16),
            _buildServerInfoCard(theme, colorScheme),
            const SizedBox(height: 16),
            _buildLicensesCard(theme, colorScheme),
            const SizedBox(height: 16),
            _buildLinksCard(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(ColorScheme colorScheme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/app_icon.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVersionCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(Icons.info_outline, color: colorScheme.primary),
        title: Text(AppLocalizations.of(context)!.clientVersion),
        subtitle: Text(AppInfo.version),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: AppInfo.version));
            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.versionCopiedToClipboard,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServerInfoCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.serverInformation,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<SystemInfo>(
              future: _serverInfoFuture,
              builder: (context, snapshot) {
                // Loading → skeleton
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Skeletonizer(
                    enabled: true,
                    child: _buildServerInfoContent(theme, _dumpyData),
                  );
                }
                // Error state
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.unableToFetchServerInfo,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  );
                }
                // Success
                return _buildServerInfoContent(theme, snapshot.data!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerInfoContent(ThemeData theme, SystemInfo info) {
    return Column(
      children: [
        _buildInfoRow(theme, 'Version', info.version),
        _buildInfoRow(theme, 'OS', info.os),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicensesCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(Icons.description_outlined, color: colorScheme.primary),
        title: Text(AppLocalizations.of(context)!.openSourceLicenses),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showLicensePage(
          context: context,
          applicationName: 'Cosmox',
          applicationVersion: AppInfo.version,
        ),
      ),
    );
  }

  Widget _buildLinksCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Repository'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchUrl(_repositoryUrl),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(AppLocalizations.of(context)!.reportIssue),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchUrl('$_repositoryUrl/issues'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(AppLocalizations.of(context)!.aboutContent),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about/content'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class AboutContentPage extends StatefulWidget {
  const AboutContentPage({super.key});

  @override
  State<AboutContentPage> createState() => _AboutContentPageState();
}

class _AboutContentPageState extends State<AboutContentPage> {
  late final Future<String> _docFuture;
  final Logger _logger = Logger('AboutContentPage');

  @override
  void initState() {
    super.initState();
    _docFuture = _fetchAboutMd();
  }

  Future<String> _fetchAboutMd() async {
    try {
      final content = await SdkProxy.instance.systemAbout();
      _logger.fine('About content loaded: ${content.length} chars');
      return content;
    } catch (error) {
      _logger.severe('Error fetching about content', error);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.about),
      ),
      body: FutureBuilder<String>(
        future: _docFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load about content',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _docFuture = _fetchAboutMd()),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return Markdown(data: snapshot.data!);
        },
      ),
    );
  }
}
