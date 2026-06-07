import 'package:flutter/material.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';

class DialogProvider {
  static AlertDialog alert(
    BuildContext context, {
    String? title,
    List<String>? content,
    required Function() confirmAction,
    Function()? cancelAction,
  }) {
    return AlertDialog(
      title: Text((title != null) ? title : AppLocalizations.of(context)!.tip),
      content: (content != null)
          ? SingleChildScrollView(
              child: ListBody(
                children: List.generate(content.length, (index) {
                  return Text(content[index]);
                }),
              ),
            )
          : SingleChildScrollView(
              child: ListBody(
                children: [Text(AppLocalizations.of(context)!.confirmAction)],
              ),
            ),
      actions: [
        TextButton(
          onPressed: confirmAction,
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
        TextButton(
          onPressed: (cancelAction != null)
              ? cancelAction
              : () {
                  Navigator.pop(context);
                },
          child: Text(AppLocalizations.of(context)!.dismiss),
        ),
      ],
    );
  }
}
