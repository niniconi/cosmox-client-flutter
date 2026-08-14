import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:cosmox_client/core/common.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client/presentation/widgets/under_construction.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});
  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _passwordFormKey = GlobalKey<FormState>();
  // final _accessFormKey = GlobalKey<FormState>();
  // final _personalFormKey = GlobalKey<FormState>();
  // final _familyFormKey = GlobalKey<FormState>();

  String? _confirmPassword;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.personalInformation),
              const Tab(text: 'Access'),
              Tab(text: AppLocalizations.of(context)!.familyControl),
              const Tab(text: 'Password'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                SizedBox(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: InputFormField(
                              labelText: AppLocalizations.of(
                                context,
                              )!.currentPassword,
                              validator: (val) => Validate.password(val),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: InputFormField(
                              labelText: AppLocalizations.of(
                                context,
                              )!.newPassword,
                              validator: (val) => Validate.password(val),
                              onChanged: (val) => _confirmPassword = val,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: InputFormField(
                              labelText: AppLocalizations.of(
                                context,
                              )!.newPasswordConfirm,
                              validator: (val) => val != _confirmPassword
                                  ? AppLocalizations.of(
                                      context,
                                    )!.differentPassword
                                  : null,
                            ),
                          ),
                          FormButton(
                            text: 'Save',
                            onPressed: () {
                              showUnderConstructionSnackBar(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
