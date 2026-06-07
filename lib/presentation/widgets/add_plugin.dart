import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddPluginComponent extends StatefulWidget {
  const AddPluginComponent({super.key});
  @override
  State<StatefulWidget> createState() => _AddPluginComponentState();
}

class _AddPluginComponentState extends State<AddPluginComponent> {
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuEntry> dropdownMenuEntries = const [
      DropdownMenuEntry(value: 0, label: "jar"),
      DropdownMenuEntry(value: 1, label: "yaml"),
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListBody(
          children: [
            const Text(""),
            DropdownMenu(
              initialSelection: dropdownMenuEntries[0],
              dropdownMenuEntries: dropdownMenuEntries,
              onSelected: (index) {},
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(onPressed: null, child: const Text("Save")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
