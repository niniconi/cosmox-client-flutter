import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/core/state.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/presentation/pages/error.dart';
import 'package:cosmox_client_flutter/presentation/widgets/drawer.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DeviceSessionSettingPage extends StatefulWidget {
  const DeviceSessionSettingPage({super.key, required this.title});

  final String title;

  @override
  State<DeviceSessionSettingPage> createState() =>
      _DeviceSessionSettingPageState();
}

class _DeviceSessionSettingPageState extends State<DeviceSessionSettingPage> {
  final Logger _logger = Logger('DeviceSessionSettingPage');
  late Future<List<DeviceSession>?> _sessionsFuture;

  List<DeviceSession> get _dumpyData => [
    DeviceSession(
      did: BigInt.zero,
      uid: BigInt.zero,
      userAgent: 'Loading device…',
      lastLoginDatetime: DateTime.fromMillisecondsSinceEpoch(0),
      lastLoginIp: '0.0.0.0',
    ),
  ];

  int? get _selfUid => AuthController.instance.uid;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchSessions();
  }

  Future<List<DeviceSession>?> _fetchSessions() {
    return SdkProxy.instance.userQueryDevices(
      uid: _selfUid == null ? null : BigInt.from(_selfUid!),
    );
  }

  Future<void> _logoutDevice(DeviceSession session) async {
    try {
      await SdkProxy.instance.logoutDevice(did: session.did);
    } catch (error) {
      _logger.severe('Failed to logout device', error);
      _showSnackBar('Failed to sign out device: $error');
      return;
    }
    _reload();
  }

  Future<void> _logoutAll() async {
    final uid = _selfUid;
    if (uid == null) return;
    try {
      await SdkProxy.instance.logoutUser(uid: BigInt.from(uid));
    } catch (error) {
      _logger.severe('Failed to logout all devices', error);
      _showSnackBar('Failed to sign out all devices: $error');
      return;
    }
    _reload();
  }

  void _reload() {
    setState(() {
      _sessionsFuture = _fetchSessions();
    });
  }

  void _showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.title),
      ),
      drawer: const HomeDrawerComponent(),
      body: FutureBuilder<List<DeviceSession>?>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildContent(isLoading: true, sessions: _dumpyData);
          }
          if (snapshot.hasError || snapshot.data == null) {
            return ErrorBlock(
              message: '${snapshot.error}',
              onRetry: () => setState(() {
                _sessionsFuture = _fetchSessions();
              }),
            );
          }
          return _buildContent(isLoading: false, sessions: snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent({
    required bool isLoading,
    required List<DeviceSession> sessions,
  }) {
    final loc = AppLocalizations.of(context)!;
    return Skeletonizer(
      enabled: isLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          _reload();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (sessions.isEmpty && !isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text(loc.noActiveSessions)),
              ),
            ...sessions.map((session) => _buildSessionCard(context, session)),
            const SizedBox(height: 8),
            if (sessions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _logoutAll,
                    icon: const Icon(Icons.logout),
                    label: Text(loc.logoutAllDevices),
                  ),
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
          '${loc.lastLoginAt}: ${session.lastLoginDatetime} · ${session.lastLoginIp}',
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
