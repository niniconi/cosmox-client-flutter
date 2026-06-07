import 'package:cosmox_client/core/global_keys.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:cosmox_client/presentation/pages/error.dart';
import 'package:go_router/go_router.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.uid});
  final int uid;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final Logger _logger = Logger('UserPage');
  final User _dumpyData = User(
    uid: BigInt.zero,
    username: '',
    email: null,
    nickname: null,
    avatar: null,
    createDatetime: DateTime.now(),
    lastUpdateDatetime: DateTime.now(),
  );
  late final Future<User?> _userFuture;

  late final List<SettingsItem> _settings = [
    SettingsItem(
      title: AppLocalizations.of(context)!.subtitleSettings,
      icon: Icons.subtitles_outlined,
      onTap: () => context.push('/user/setting/subtitle'),
    ),
    SettingsItem(
      title: AppLocalizations.of(context)!.playbackSettings,
      icon: Icons.play_circle_outline,
      onTap: () => context.push('/user/setting/playback'),
    ),
    SettingsItem(
      title: AppLocalizations.of(context)!.profile,
      icon: Icons.person_outline,
      onTap: () => context.push('/user/setting/profile'),
    ),
    SettingsItem(
      title: AppLocalizations.of(context)!.account,
      icon: Icons.lock_outline,
      onTap: () => context.push('/user/setting/account'),
    ),
    SettingsItem(
      title: AppLocalizations.of(context)!.notifications,
      icon: Icons.notifications_outlined,
      onTap: () => context.push('/user/setting/notifications'),
    ),
    SettingsItem(
      title: AppLocalizations.of(context)!.preferences,
      icon: Icons.settings_outlined,
      onTap: () => context.push('/user/setting/preferences'),
    ),
    SettingsItem(
      title: AppLocalizations.of(context)!.dangerZone,
      icon: Icons.delete_forever_outlined,
      onTap: () => context.push('/user/setting/danger'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser(widget.uid);
  }

  Future<User?> _fetchUser(int uid) async {
    try {
      final userResult = await SdkProxy.instance.userGet(uid: BigInt.from(uid));
      _logger.fine('fetched user: ${userResult.username}');
      return userResult;
    } catch (error) {
      _logger.severe('Failed fetch user', error);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to fetch user: $error")),
      );
    }
    return null;
  }

  Widget _buildContent({required bool isLoading, required User user}) {
    return Skeletonizer(
      enabled: isLoading,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserHeader(context, user),
            const SizedBox(height: 10),
            _buildSettingsList(context),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle({required bool isLoading, required User user}) {
    return Skeletonizer(
      enabled: isLoading,
      child: Text(user.nickname ?? user.username),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            Colors.transparent, // Transparent AppBar is intentional design
        title: FutureBuilder(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildTitle(isLoading: true, user: _dumpyData);
            }

            if (snapshot.hasError || snapshot.data == null) {
              return Text(
                snapshot.hasError ? '${snapshot.error}' : 'User not found',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                overflow: TextOverflow.ellipsis,
              );
            }

            return _buildTitle(isLoading: false, user: snapshot.data!);
          },
        ),
      ),
      body: FutureBuilder(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildContent(isLoading: true, user: _dumpyData);
          }

          if (snapshot.hasError || snapshot.data == null) {
            return ErrorBlock(
              message: snapshot.hasError
                  ? '${snapshot.error}'
                  : 'User not found',
              onRetry: () {
                setState(() {
                  _userFuture = _fetchUser(widget.uid);
                });
              },
            );
          }

          return _buildContent(isLoading: false, user: snapshot.data!);
        },
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, User user) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'avatar',
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  "https://via.placeholder.com/150",
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname ?? user.username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "@${user.username}",
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withAlpha(175),
                  ),
                ),
              ],
            ),
          ),

          IconButton.filledTonal(
            onPressed: null,
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: _settings.map((item) {
          return _buildSettingItem(
            context,
            title: item.title,
            icon: item.icon,
            onTap: item.onTap,
            showDivider: _settings.indexOf(item) != _settings.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            indent: 60,
            endIndent: 20,
            height: 1,
            color: Colors.grey.withAlpha(25),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        onPressed: () => context.go('/logout'),
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          AppLocalizations.of(context)!.logout,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class SettingsItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const SettingsItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
