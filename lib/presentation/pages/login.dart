import 'package:cosmox_client/core/common.dart';
import 'package:cosmox_client/core/global_keys.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/core/state.dart';
import 'package:cosmox_client/presentation/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';

class LoginPage extends StatefulWidget {
  final Function(String? username, String? password)? onSubmitted;

  const LoginPage({super.key, this.onSubmitted});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger('LoginPage');
  bool remenberMe = false;
  bool _obscurePassword = true;
  Map<String, dynamic> payload = {"username": "", "password": ""};

  Function(String? username, String? password)? get onSubmitted =>
      widget.onSubmitted;

  void loginError(String message) {
    SnackBar messageSnackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      width: MediaQuery.of(context).size.width * 0.8,
      content: Text(message),
      // SnackBar auto-dismisses, no close action needed
    );
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(messageSnackBar);
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _logger.fine('[Login] Attempting login for user: ${payload["username"]}');

      try {
        final token = await SdkProxy.instance.login(
          username: payload["username"],
          password: payload["password"],
        );

        if (token != null) {
          await context.read<AuthController>().storeToken(token);
          _logger.info('[Login] Success - user: ${payload["username"]}');

          if (onSubmitted != null) {
            onSubmitted!(payload["username"], payload["password"]);
          }

          context.read<AuthController>().stateNext();
        } else {
          _logger.warning('[Login] Login returned no token');
          loginError('Login failed - unexpected error');
        }
      } catch (error) {
        _logger.severe('[Login] Login failed', error);
        loginError(error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(height: screenHeight * .12),
              Text(
                AppLocalizations.of(context)!.welcome,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: screenHeight * .01),
              Text(
                AppLocalizations.of(context)!.signInToContinue,
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: screenHeight * .12),
              InputFormField(
                labelText: AppLocalizations.of(context)!.username,
                validator: (val) => Validate.username(val),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onSaved: (val) => payload["username"] = val,
                autoFocus: true,
              ),
              SizedBox(height: screenHeight * .025),
              InputFormField(
                labelText: AppLocalizations.of(context)!.password,
                validator: (val) => Validate.password(val),
                onSaved: (val) => payload["password"] = val,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => submit(),
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: remenberMe,
                        onChanged: (val) {
                          setState(() {
                            (val != null) ? remenberMe = val : ();
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.rememberMe),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return DialogProvider.alert(
                            context,
                            title: AppLocalizations.of(context)!.tip,
                            content: [
                              AppLocalizations.of(context)!.contactAdmin,
                            ],
                            confirmAction: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * .075),
              FormButton(
                text: AppLocalizations.of(context)!.login,
                onPressed: submit,
              ),
              SizedBox(height: screenHeight * .0075),
              FormButton(
                text: AppLocalizations.of(context)!.selectOtherServer,
                onPressed: () => context.go("/select/server"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
