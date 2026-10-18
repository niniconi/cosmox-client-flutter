import 'dart:convert';

import 'package:cosmox_client_flutter/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';

class ServerController extends ChangeNotifier {
  static JsonEncoder encoder = const JsonEncoder();
  static JsonDecoder decoder = const JsonDecoder();
}

class ThemeController extends ChangeNotifier {
  final Logger _logger = Logger('ThemeController');
  ThemeMode _themeMode = ThemeMode.system;
  ColorSeed _colorSeed = ColorSeed.baseColor;
  ColorImageProvider imageSelected = ColorImageProvider.leaves;
  ColorScheme? imageColorScheme = const ColorScheme.light();
  ColorSelectionMethod _colorSelectionMethod = ColorSelectionMethod.colorSeed;

  ColorSeed get colorSeed => _colorSeed;
  ColorSelectionMethod get colorSelectionMethod => _colorSelectionMethod;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final colorSeedString = prefs.getString('theme_color_seed');
      final themeModeString = prefs.getString('theme_mode');
      final colorSelectionMethodString = prefs.getString(
        'theme_color_selection_method',
      );

      if (colorSeedString != null) {
        _colorSeed = ColorSeed.values.byName(colorSeedString);
      }

      if (themeModeString != null) {
        _themeMode = ThemeMode.values.byName(themeModeString);
      }
      if (colorSelectionMethodString != null) {
        _colorSelectionMethod = ColorSelectionMethod.values.byName(
          colorSelectionMethodString,
        );
      }
    } catch (error, st) {
      _logger.severe('Failed to load theme settings', error, st);
    }
  }

  Future<void> updateColorSeed(ColorSeed seed) async {
    _colorSeed = seed;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_color_seed', seed.name);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_mode', themeMode.name);
    notifyListeners();
  }

  Future<void> updateColorSelectionMethod(
    ColorSelectionMethod colorSelectionMethod,
  ) async {
    _colorSelectionMethod = colorSelectionMethod;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_color_selection_method', colorSelectionMethod.name);
    notifyListeners();
  }
}

enum AuthStatus {
  serverUnselected,
  serverUninitialized,
  unauthenticated,
  authenticated,
}

class AuthController extends ChangeNotifier {
  final Logger _logger = Logger('AuthController');
  static final AuthController _instance = AuthController._internal();
  AuthStatus _status = AuthStatus.serverUnselected;
  String? _address;
  String? _token;
  int? _uid;

  AuthStatus get status => _status;
  String? get address => _address;
  String? get token => _token;
  int? get uid => _uid;

  static AuthController get instance => _instance;

  AuthController._internal();
  factory AuthController() => _instance;

  void _updateUidFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final claims = jsonDecode(payload) as Map<String, dynamic>;
      final uid = int.parse(claims['sub']?.toString() ?? '');
      _uid = uid;
      _logger.fine('[Auth] Parsed user ID from token: $uid');
    } catch (error, st) {
      _logger.severe('[Auth] Failed to parse token', error, st);
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final server = prefs.getString('server_url');
    final token = prefs.getString('token');

    if (server == null || server.isEmpty) {
      _status = AuthStatus.serverUnselected;
    } else {
      _address = server;

      try {
        final uri = Uri.parse(server);
        SdkProxy.instance.init(hostname: uri.host, port: uri.port);

        if (token != null && token.isNotEmpty) {
          SdkProxy.instance.setToken(token: token);
          _updateUidFromToken(token);
        }

        final info = await SdkProxy.instance.systemInfo();
        if (info.isFirstBoot) {
          _status = AuthStatus.serverUninitialized;
        } else {
          _status = AuthStatus.authenticated;
        }
      } on SdkError_ConnectionFailed catch (e, st) {
        _logger.severe("[Auth] Cannot reach server", e, st);
        // Real connection failure
        _status = AuthStatus.serverUnselected;
        _address = null;
      } on SdkError_Unauthenticated catch (e, st) {
        _logger.severe("[Auth] Unauthenticated", e, st);
        // Server reached but rejected our token
        // if (token != null && token.isNotEmpty) {
        // _token = token;
        // _updateUidFromToken(token);
        // _status = AuthStatus.authenticated;
        // } else {
        _status = AuthStatus.unauthenticated;
        // }
      } catch (error, st) {
        _logger.severe("[Auth] Failed to connect to server", error, st);
        // Generic fallback — treat as connection failure
        _status = AuthStatus.serverUnselected;
        _address = null;
      }
    }
  }

  void triggerSessionExpired() {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void triggerServerLost() {
    _status = AuthStatus.serverUnselected;
    notifyListeners();
  }

  void triggerServerUnInit() {
    _status = AuthStatus.serverUninitialized;
    notifyListeners();
  }

  void stateNext() {
    _status = switch (_status) {
      AuthStatus.serverUnselected => AuthStatus.serverUninitialized,
      AuthStatus.serverUninitialized => AuthStatus.unauthenticated,
      AuthStatus.unauthenticated => AuthStatus.authenticated,
      AuthStatus.authenticated => AuthStatus.authenticated,
    };
    notifyListeners();
  }

  Future<void> storeAddress(String address) async {
    _address = address;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('server_url', address);
    _logger.fine('[Auth] Server address saved: $address');
  }

  Future<void> removeToken() async {
    _token = null;
    // Clear token from Rust SDK in case client is initialised
    try {
      SdkProxy.instance.setToken(token: '');
    } catch (_) {
      // SDK client may not be initialised; ignore
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _logger.info('[Auth] Token removed - logging out');
    triggerSessionExpired();
  }

  Future<void> storeToken(String token) async {
    _updateUidFromToken(token);

    _token = token;
    // Sync token to Rust SDK so later SDK calls use it
    try {
      SdkProxy.instance.setToken(token: token);
    } catch (_) {
      // SDK client may not be initialised; ignore
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);

    _logger.info('[Auth] Token saved successfully');
  }

  Future<void> storeTokenAndRedirect(String token) async {
    await storeToken(token);

    _status = AuthStatus.authenticated;
    notifyListeners();
  }
}
