import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key, required this.musicUrl});
  final String musicUrl;
  @override
  State<StatefulWidget> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  bool isPlay = false;
  final AudioPlayer player = AudioPlayer();
  late AnimationController _controller;

  ImageProvider coverImage() {
    return NetworkImage(
      "https://ia800609.us.archive.org/8/items/tribute-to-lain-pdlr9y/cover_itemimage.png",
    );
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    super.initState();
    player.setSource(
      UrlSource('https://archive.org/download/gs_boa-duvet/01%20Duvet.flac'),
    );
  }

  void _togglePlay() {
    setState(() {
      if (isPlay) {
        isPlay = false;
        _controller.stop();
        player.pause();
      } else {
        isPlay = true;
        _controller.repeat();
        player.resume();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Music'),
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * .06),
          RotationTransition(
            turns: Tween(begin: 0.0, end: 2.0).animate(_controller),
            child: Container(
              width: screenWidth * .7,
              height: screenWidth * .7,
              decoration: BoxDecoration(
                image: DecorationImage(image: coverImage(), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(screenWidth / 2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: _togglePlay,
                icon: Icon(
                  isPlay ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: screenWidth * .12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(onPressed: null, icon: const Icon(Icons.skip_next)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: screenWidth * 0.8,
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(2),
              value: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
