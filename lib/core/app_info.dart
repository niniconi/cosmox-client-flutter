import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Holds application metadata loaded from the platform at startup.
class AppInfo {
  static final Logger _logger = Logger('AppInfo');

  static String _version = '0.0.0';
  static String _buildNumber = '0';
  static String _appName = 'cosmox';
  static String _packageName = '';

  static String get version => _version;
  static String get buildNumber => _buildNumber;
  static String get appName => _appName;
  static String get packageName => _packageName;

  /// Must be called once from [main] after plugin channel is ready.
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _version = info.version;
      _buildNumber = info.buildNumber;
      _appName = info.appName;
      _packageName = info.packageName;
    } catch (e) {
      _logger.severe('Failed to read package info', e);
      // Keep defaults.
    }
  }
}
