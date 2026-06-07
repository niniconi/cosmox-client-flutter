import 'package:cosmox_client/presentation/widgets/container_info.dart';
import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:cosmox_client/presentation/widgets/path_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});
  @override
  State<StatefulWidget> createState() => _RouterPageSate();
}

class _RouterPageSate extends State<DebugPage> {
  final _formKey = GlobalKey<FormState>();
  String goUri = "/debug";
  bool _usePush = false;

  void _handleGo() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _navigateToRoute(goUri);
    }
  }

  void _navigateToRoute(String route) {
    if (_usePush) {
      context.push(route);
    } else {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Debug page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Custom Route"),
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: InputFormField(
                        labelText: "Route to",
                        onSaved: (val) {
                          if (val != null) goUri = val;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _handleGo,
                      child: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Routing section with go/push toggle
              Row(
                children: [
                  Expanded(
                    child: _buildSectionTitle(
                      "App Routing (${_usePush ? 'push' : 'go'})",
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'go',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Switch(
                        value: _usePush,
                        onChanged: (val) => setState(() => _usePush = val),
                      ),
                      Text(
                        'push',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),
              _buildButtonGroup([
                _buildNavButton(
                  "Library View",
                  () => _navigateToRoute("/library/view/123456"),
                ),
                _buildNavButton(
                  "Video Player",
                  () => _navigateToRoute("/player/video/123456"),
                ),
                _buildNavButton("Search", () => _navigateToRoute("/search")),
                _buildNavButton("Login Page", () => _navigateToRoute("/login")),
                _buildNavButton(
                  "User Profile",
                  () => _navigateToRoute("/user/123"),
                ),
                _buildNavButton(
                  "Resource",
                  () => _navigateToRoute("/resource/123456"),
                ),
                _buildNavButton("Guide", () => _navigateToRoute("/guide/1")),
                _buildNavButton(
                  "Music Player",
                  () => _navigateToRoute("/player/music/123456"),
                ),
                _buildNavButton(
                  "Markdown",
                  () => _navigateToRoute("/player/markdown/0"),
                ),
                _buildNavButton(
                  "Novel Reader",
                  () => _navigateToRoute("/player/novel/0"),
                ),
                _buildNavButton(
                  "Comics",
                  () => _navigateToRoute("/reader/comics/123456"),
                ),
              ]),

              const SizedBox(height: 30),

              // Error Pages
              _buildSectionTitle("Error Pages"),
              _buildButtonGroup([
                _buildNavButton(
                  "Not Found (404)",
                  () => _navigateToRoute("/error/404"),
                ),
                _buildNavButton(
                  "Error Page",
                  () => _navigateToRoute(
                    "/error?title=Connection%20Lost&message=Failed%20to%20reach%20the%20server.%20Please%20check%20your%20connection.&details=SocketException:%20Connection%20refused%20(127.0.0.1:%3Cport%3E)",
                  ),
                ),
                _buildNavButton(
                  "Under Construction",
                  () => _navigateToRoute("/under-construction"),
                ),
              ]),

              const SizedBox(height: 30),

              _buildSectionTitle("Components & Dialogs"),
              _buildButtonGroup([
                _buildNavButton("Path Selector", () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        Dialog(child: PathSelectorComponent(then: (path) {})),
                  );
                }),
                _buildNavButton("Container Info", () {
                  showDialog(
                    context: context,
                    builder: (context) => const Dialog(
                      child: ContainerInfoComponent(
                        data: {"name": "Demo MKV", "size": "551 MB"},
                      ),
                    ),
                  );
                }),
                _buildNavButton("PDF Reader", () {
                  context.push('/player/pdf');
                }),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildButtonGroup(List<Widget> buttons) {
    return Wrap(spacing: 10, runSpacing: 10, children: buttons);
  }

  Widget _buildNavButton(String label, VoidCallback onPressed) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
