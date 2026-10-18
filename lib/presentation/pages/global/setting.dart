import 'package:cosmox_client_flutter/presentation/widgets/form.dart';
import 'package:cosmox_client_flutter/core/constants.dart';
import 'package:cosmox_client_flutter/core/common.dart';
import 'package:cosmox_client_flutter/core/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';

class GlobalSettingPage extends StatefulWidget {
  const GlobalSettingPage({super.key});

  @override
  State<GlobalSettingPage> createState() => _GlobalSettingPageState();
}

class _GlobalSettingPageState extends State<GlobalSettingPage> {
  double padding = 20;
  double margin = 20;
  Map<String, dynamic> settings = {
    "cache_path": "/var/cache",
    "log_path": "/var/log",
    "metadata_path": "/metadata",
    "server_name": "cosmox",
    "notify_email": "admin@admin.com",
    "enable_quick_connect": false,
  };

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _serverNameController;
  late TextEditingController _cachePathController;
  late TextEditingController _logPathController;
  late TextEditingController _metadataPathController;
  late TextEditingController _notifyEmailController;
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _serverNameController = TextEditingController(
      text: settings["server_name"],
    );
    _cachePathController = TextEditingController(text: settings["cache_path"]);
    _logPathController = TextEditingController(text: settings["log_path"]);
    _metadataPathController = TextEditingController(
      text: settings["metadata_path"],
    );
    _notifyEmailController = TextEditingController(
      text: settings["notify_email"],
    );
    _tokenController = TextEditingController(
      text: context.read<AuthController>().token ?? "",
    );
  }

  @override
  void dispose() {
    _serverNameController.dispose();
    _cachePathController.dispose();
    _logPathController.dispose();
    _metadataPathController.dispose();
    _notifyEmailController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void save() {}

  void cancel() {}

  void saveToken(String? token) async {
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("token", token);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ResponsiveBreakpoints.of(context).screenWidth;
    double width = screenWidth;
    if (width > Config.minFormWidth) {
      width = Config.minFormWidth;
    }

    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(padding),
            width: width,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(margin),
                  child: InputFormField(
                    labelText: AppLocalizations.of(context)!.serverName,
                    helpText: AppLocalizations.of(context)!.serverNameHelp,
                    controller: _serverNameController,
                    validator: (val) => Validate.path(val),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(margin),
                  child: InputFormField(
                    labelText: AppLocalizations.of(context)!.cachePath,
                    helpText: AppLocalizations.of(context)!.cachePathHelp,
                    controller: _cachePathController,
                    validator: (val) => Validate.path(val),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(margin),
                  child: InputFormField(
                    labelText: AppLocalizations.of(context)!.logPath,
                    controller: _logPathController,
                    validator: (val) => Validate.path(val),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(margin),
                  child: InputFormField(
                    labelText: AppLocalizations.of(context)!.metadataPath,
                    helpText: AppLocalizations.of(context)!.metadataPathHelp,
                    controller: _metadataPathController,
                    validator: (val) => Validate.path(val),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(margin),
                  child: InputFormField(
                    labelText: AppLocalizations.of(context)!.notifyEmail,
                    controller: _notifyEmailController,
                    validator: (val) => Validate.email(val),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(margin),
                  child: InputFormField(
                    labelText: AppLocalizations.of(context)!.token,
                    validator: (val) {
                      if (val == null) {
                        return AppLocalizations.of(context)!.pleaseInputToken;
                      }
                      return null;
                    },
                    controller: _tokenController,
                    onSaved: (token) {
                      if (token != null) {
                        context.read<AuthController>().storeToken(token);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(margin),
                  child: ListTile(
                    leading: Switch(
                      value: settings["enable_quick_connect"],
                      onChanged: (val) {
                        setState(() {
                          settings["enable_quick_connect"] = val;
                        });
                      },
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.enableQuickConnect,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(margin),
                      width: width / 2 - 2 * margin - padding,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            save();
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.save),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(margin),
                      width: width / 2 - 2 * margin - padding,
                      child: ElevatedButton(
                        onPressed: cancel,
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
