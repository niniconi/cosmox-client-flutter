import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:cosmox_client_flutter/presentation/widgets/add_user.dart';
import 'package:cosmox_client_flutter/presentation/widgets/dialog.dart';
import 'package:cosmox_client_flutter/presentation/pages/edit_user.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';
import 'package:responsive_framework/responsive_framework.dart';

class UserManagerPage extends StatefulWidget {
  const UserManagerPage({super.key});

  @override
  State<UserManagerPage> createState() => _UserManagerPageState();
}

class _UserManagerPageState extends State<UserManagerPage> {
  bool loaded = false;
  double minCardWidth = 300;
  List<User> users = [];

  void _fetchUsers() async {
    try {
      final result = await SdkProxy.instance.userQuery();
      setState(() {
        users = result;
        loaded = true;
      });
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to fetch users: $error")),
      );
    }
  }

  Future<void> deleteUser(BuildContext context, int index) async {
    final user = users[index];
    try {
      await SdkProxy.instance.userDelete(uid: user.uid);
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to delete user: $error")),
      );
      return;
    }

    setState(() => users.removeAt(index));

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text("Deleted user ${user.username}")),
    );
  }

  Widget userCard(int index) {
    User user = users[index];
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              const SizedBox(height: 200 + 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(AppLocalizations.of(context)!.otherInfo),
                    ],
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.edit),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const Dialog(child: EditUserPage()),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.delete),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return DialogProvider.alert(
                                  context,
                                  title: "Delete this",
                                  content: [
                                    AppLocalizations.of(
                                      context,
                                    )!.deleteUserConfirm,
                                  ],
                                  confirmAction: () {
                                    deleteUser(context, index);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            image: const DecorationImage(
              image: AssetImage('assets/images/placeholder.jpg'),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget main = const Center(child: CircularProgressIndicator());
    if (loaded) {
      if (users.isEmpty) {
        main = const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Empty", style: TextStyle(fontSize: 48)),
              Icon(Icons.add_box, size: 48),
            ],
          ),
        );
      } else {
        main = SingleChildScrollView(
          child: Container(
            width: ResponsiveBreakpoints.of(context).screenWidth,
            alignment: Alignment.center,
            child: Wrap(
              children: List.generate(users.length, (index) {
                return SizedBox(
                  height: 300,
                  width: 400,
                  child: userCard(index),
                );
              }),
            ),
          ),
        );
      }
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.addUser,
        onPressed: () => {
          showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: AddUserComponent(
                then: () {
                  _fetchUsers();
                },
              ),
            ),
          ),
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        child: main,
        onRefresh: () async {
          _fetchUsers();
        },
      ),
    );
  }
}
