import 'package:cosmox_client/core/global_keys.dart';
import 'package:cosmox_client/presentation/widgets/dialog.dart';
import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:cosmox_client/core/common.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';

class AddUserComponent extends StatefulWidget {
  final Function() then;
  const AddUserComponent({super.key, required this.then});

  @override
  State<AddUserComponent> createState() => _AddUserComponentState();
}

class _AddUserComponentState extends State<AddUserComponent> {
  double padding = 20;
  Map<String, dynamic> payload = {};

  Map<String, bool> permissions = {"del": false, "add": false, "____": true};
  final _formKey = GlobalKey<FormState>();

  void _submitAddUser() async {
    try {
      SdkProxy.instance.userRegister(
        username: payload["username"] ?? "",
        password: payload["password"] ?? "",
        confirmPassword: payload["confirm_password"] ?? "",
      );
      widget.then();
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to add user: $error")),
      );
    }
  }

  Future<XFile> _chooseImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return Future<XFile>.value(image);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(AppLocalizations.of(context)!.addNewUser),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                    width: 100,
                    child: Icon(Icons.account_circle_outlined, size: 64),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _chooseImage();
                    },
                    label: Text(AppLocalizations.of(context)!.addAvatar),
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: InputFormField(
                  labelText: AppLocalizations.of(context)!.username,
                  validator: (val) => Validate.username(val),
                  onChanged: (val) {
                    payload["username"] = val;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: InputFormField(
                  labelText: AppLocalizations.of(context)!.nickname,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: InputFormField(
                  labelText: AppLocalizations.of(context)!.password,
                  validator: (val) => Validate.password(val),
                  onChanged: (val) {
                    payload["password"] = val;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: InputFormField(
                  labelText: AppLocalizations.of(context)!.confirmPassword,
                  validator: (val) {
                    return null;
                  },
                ),
              ),
              Column(
                children: List.generate(
                  permissions.length,
                  (index) => CheckboxListTile(
                    value: permissions.values.elementAt(index),
                    title: Text(permissions.keys.elementAt(index)),
                    subtitle: const Text("this is subtitle"),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) {
                          var entries = {
                            permissions.keys.elementAt(index): val,
                          }.entries;
                          permissions.addEntries(entries);
                        }
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context)!.dismiss),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              DialogProvider.alert(
                                context,
                                title: AppLocalizations.of(
                                  context,
                                )!.confirmSave,
                                content: ["save this apply", "...."],
                                confirmAction: () {
                                  if (_formKey.currentState!.validate()) {
                                    _submitAddUser();
                                    widget.then();
                                    Navigator.pop(context);
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
