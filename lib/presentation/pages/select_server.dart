import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:cosmox_client/core/common.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/core/state.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class SelectServerPage extends StatefulWidget {
  const SelectServerPage({super.key});

  @override
  State<SelectServerPage> createState() => _SelectServerPageState();
}

class _SelectServerPageState extends State<SelectServerPage> {
  final Logger _logger = Logger('SelectServerPage');
  final _formKey = GlobalKey<FormState>();

  String? _serverAddress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.pleaseSelectServer,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.example,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text("http://server.domain:port"),
                          const Text("https://192.168.1.1:8080"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    InputFormField(
                      labelText: AppLocalizations.of(context)!.serverAddress,
                      icon: const Icon(Icons.dns_outlined),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitForm(),
                      validator: (val) => Validate.serverAddress(val),
                      onSaved: (val) {
                        _serverAddress = val;
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_serverAddress != null) {
        // Initialise the Rust SDK with the new server host/port so
        // subsequent API calls (guide, login, …) can reach the server.
        try {
          final uri = Uri.parse(_serverAddress!);
          SdkProxy.instance.init(hostname: uri.host, port: uri.port);
        } catch (e) {
          _logger.severe('Failed to init SDK with address', e);
        }

        await context.read<AuthController>().storeAddress(_serverAddress!);
        context.read<AuthController>().stateNext();
      }
    }
  }
}
