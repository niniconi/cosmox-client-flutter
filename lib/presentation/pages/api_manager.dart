import 'package:cosmox_client/core/global_keys.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/core/state.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/pages/error.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Dashboard's API management page.
///
/// Lists device sessions across all users (admin/audit view) and lets an
/// authorized administrator force log out any device. Querying all sessions
/// requires the `User.Audit` permission; logging out another user's device
/// requires `User.SessionManage`. Self-service is handled on the user-side
/// session page instead.
class ApiKeysManagerPage extends StatefulWidget {
  const ApiKeysManagerPage({super.key});

  @override
  State<ApiKeysManagerPage> createState() => _ApiKeysManagerPageState();
}

class _ApiKeysManagerPageState extends State<ApiKeysManagerPage> {
  final Logger _logger = Logger('ApiKeysManagerPage');
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 40;

  final List<DeviceSession> _sessions = [];
  int _page = 0;
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  Object? _error;

  List<DeviceSession> get _dumpyData => [
    DeviceSession(
      did: BigInt.zero,
      uid: BigInt.zero,
      userAgent: 'Loading device…',
      lastLoginDatetime: DateTime.fromMillisecondsSinceEpoch(0),
      lastLoginIp: '0.0.0.0',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchSessions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _initialLoading = true;
      _error = null;
      _page = 0;
    });
    try {
      final result = await _fetchPage(_page);
      setState(() {
        _sessions
          ..clear()
          ..addAll(result);
        _hasMore = result.length == _pageSize;
        _initialLoading = false;
      });
    } catch (error) {
      _logger.severe('Failed to fetch sessions', error);
      setState(() {
        _error = error;
        _initialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_initialLoading || _loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
    });
    try {
      final result = await _fetchPage(_page + 1);
      setState(() {
        _page += 1;
        _sessions.addAll(result);
        _hasMore = result.length == _pageSize;
        _loadingMore = false;
      });
    } catch (error) {
      _logger.severe('Failed to load more sessions', error);
      _showSnackBar('Failed to load more devices: $error');
      setState(() {
        _loadingMore = false;
      });
    }
  }

  Future<List<DeviceSession>> _fetchPage(int page) {
    return SdkProxy.instance.userQueryDevices(
      page: BigInt.from(page),
      pageSize: BigInt.from(_pageSize),
    );
  }

  bool _isCurrentUser(DeviceSession session) {
    final selfUid = AuthController.instance.uid;
    return selfUid != null && session.uid == BigInt.from(selfUid);
  }

  Future<void> _logoutDevice(DeviceSession session) async {
    if (_isCurrentUser(session)) {
      final confirmed = await _confirmLogoutSelf();
      if (!confirmed) return;
    }
    try {
      await SdkProxy.instance.logoutDevice(did: session.did);
    } catch (error) {
      _logger.severe('Failed to logout device', error);
      _showSnackBar('Failed to sign out device: $error');
      return;
    }
    _reload();
  }

  Future<bool> _confirmLogoutSelf() async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.logOut),
        content: Text(loc.logoutCurrentDeviceWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.dismiss),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _reload() {
    _fetchSessions();
  }

  void _showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: _initialLoading
            ? _buildContent(isLoading: true, sessions: _dumpyData)
            : (_error != null
                  ? ErrorBlock(
                      message: '$_error',
                      onRetry: _reload,
                    )
                  : _buildContent(isLoading: false, sessions: _sessions)),
      ),
    );
  }

  Widget _buildContent({
    required bool isLoading,
    required List<DeviceSession> sessions,
  }) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Skeletonizer(
      enabled: isLoading,
      child: RefreshIndicator(
        onRefresh: _fetchSessions,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (sessions.isEmpty && !isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text(loc.noActiveSessions)),
              ),
            ...sessions.map((session) => _buildSessionCard(context, session)),
            if (_loadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, DeviceSession session) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final uid = session.uid?.toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.devices_other,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          session.userAgent?.isNotEmpty == true
              ? session.userAgent!
              : loc.userAgentDevice,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${loc.lastLoginAt}: ${session.lastLoginDatetime}'
          ' · ${session.lastLoginIp}'
          '${uid != null ? ' · UID $uid' : ''}',
        ),
        trailing: IconButton(
          tooltip: loc.logOut,
          icon: const Icon(Icons.logout),
          onPressed: () => _logoutDevice(session),
        ),
      ),
    );
  }
}
