import 'package:cosmox_client_flutter/presentation/widgets/form.dart';
import 'package:cosmox_client_flutter/core/common.dart';
import 'package:cosmox_client_flutter/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

class NetworkSettingPage extends StatefulWidget {
  const NetworkSettingPage({super.key});

  @override
  State<NetworkSettingPage> createState() => _NetworkSettingPageState();
}

class _NetworkSettingPageState extends State<NetworkSettingPage> {
  double padding = 20;
  double margin = 20;
  Map<String, dynamic> settings = {"http_port": 8080};

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _httpPortController;

  @override
  void initState() {
    super.initState();
    _httpPortController = TextEditingController(
      text: settings["http_port"].toString(),
    );
  }

  @override
  void dispose() {
    _httpPortController.dispose();
    super.dispose();
  }

  void save() {}

  void cancel() {}

  @override
  Widget build(BuildContext context) {
    double screenWidth = ResponsiveBreakpoints.of(context).screenWidth;
    double width = screenWidth;
    if (width > Config.minFormWidth) {
      width = Config.minFormWidth;
    }

    return Form(
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
                  labelText: AppLocalizations.of(context)!.localHttpPort,
                  helpText: AppLocalizations.of(context)!.httpPortHelp,
                  controller: _httpPortController,
                  validator: (val) => Validate.path(val),
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
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
