import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

enum PlayState { play, pause, caching, stoped }

enum MuteState { mute, unmute }

enum WindowState { fullscreen, window }

class Episode {
  final int id;
  final String title;
  final Duration duration;
  final bool isWatched;

  Episode({
    required this.id,
    required this.title,
    required this.duration,
    this.isWatched = false,
  });
}

class VideoPlayerPage extends StatefulWidget {
  final String url;
  const VideoPlayerPage({super.key, required this.url});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final Logger _logger = Logger('VideoPlayerPage');
  final VideoPlayerController controller = VideoPlayerController();
  final FocusNode _focusNode = FocusNode();

  PlayState playState = PlayState.stoped;
  MuteState muteState = MuteState.unmute;
  WindowState windowState = WindowState.window;
  bool _showControlPanelState = true;
  bool _showPlaybackInfo = false;
  bool _showEpisodePicker = false;
  bool _showSeekFeedback = false;
  String _seekFeedbackText = "";
  bool _locked = false;
  bool _isLooping = false;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  int _currentEpisodeIndex = 0;
  Timer? _hideControlPanelTimer;
  Timer? _seekFeedbackTimer;
  OverlayEntry? _volumeOverlay;

  late List<Episode> _episodes;
  late List<String> _videoUrls;

  static const List<double> _playbackSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  @override
  void initState() {
    super.initState();
    _initEpisodes();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _startHideControlPanelTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.open([
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-01-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-02-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-03-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-04-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-05-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-06-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-07-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-08-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-09-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-10-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-11-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-12-Serial-Experiments-Lain.mp4",
        "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-13-Serial-Experiments-Lain.mp4",
      ]);
    });
  }

  void _startHideControlPanelTimer() {
    _hideControlPanelTimer?.cancel();
    _hideControlPanelTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _showControlPanelState = false);
    });
  }

  void _showControlPanel() {
    if (!_showControlPanelState) {
      setState(() => _showControlPanelState = true);
    }
    _startHideControlPanelTimer();
  }

  void fullscreen() {
    setState(() => windowState = WindowState.fullscreen);

    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      windowManager.setFullScreen(true);
    } else if (kIsWeb) {
      // web.document.documentElement?.requestFullscreen();
    } else if (Platform.isIOS || Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      _logger.severe("Fullscreen not implemented for this platform.");
    }
  }

  void _initEpisodes() {
    _episodes = [
      Episode(
        id: 1,
        title: "Layer 01: Weird",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: true,
      ),
      Episode(
        id: 2,
        title: "Layer 02: Girls",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: true,
      ),
      Episode(
        id: 3,
        title: "Layer 03: Psyche",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 4,
        title: "Layer 04: Religion",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 5,
        title: "Layer 05: Distortion",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 6,
        title: "Layer 06: Kids",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 7,
        title: "Layer 07: Society",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 8,
        title: "Layer 08: Rumors",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 9,
        title: "Layer 09: Protocol",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 10,
        title: "Layer 10: Love",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 11,
        title: "Layer 11: Infornography",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 12,
        title: "Layer 12: Landscape",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
      Episode(
        id: 13,
        title: "Layer 13: Ego",
        duration: const Duration(minutes: 24, seconds: 30),
        isWatched: false,
      ),
    ];
    _videoUrls = [
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-01-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-02-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-03-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-04-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-05-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-06-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-07-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-08-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-09-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-10-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-11-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-12-Serial-Experiments-Lain.mp4",
      "https://archive.org/download/serial-experiments-lain-english/MP4%20%28Lowest%20Quality%29/Layer-13-Serial-Experiments-Lain.mp4",
    ];
  }

  void _setVolume(double value) {
    setState(() {
      _volume = value;
      if (value == 0) {
        muteState = MuteState.mute;
      } else {
        muteState = MuteState.unmute;
      }
    });
    controller.setVolume(value * 100);
    _showControlPanel();
  }

  void _showVolumePopup() {
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) return;

    final Offset position = button.localToGlobal(Offset.zero);
    final colorScheme = Theme.of(context).colorScheme;

    _volumeOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideVolumePopup,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: position.dx - 75,
            top: position.dy - 160,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surface,
              child: Container(
                width: 180,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _volume == 0 ? Icons.volume_off : Icons.volume_up,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _volume,
                      onChanged: _setVolume,
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.surfaceContainerHighest,
                    ),
                    Text(
                      '${(_volume * 100).toInt()}%',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_volumeOverlay!);
  }

  void _hideVolumePopup() {
    _volumeOverlay?.remove();
    _volumeOverlay = null;
  }

  void _toggleEpisodePicker() {
    setState(() => _showEpisodePicker = !_showEpisodePicker);
    _showControlPanel();
  }

  void _playEpisode(int index) {
    setState(() {
      _currentEpisodeIndex = index;
      _showEpisodePicker = false;
    });
    controller.open(_videoUrls, startIndex: index);
    _logger.fine('Playing episode: ${_episodes[index].title}');
    _showControlPanel();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void exitFullscreen() {
    setState(() => windowState = WindowState.window);
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      windowManager.setFullScreen(false);
    } else if (kIsWeb) {
      // web.document.exitFullscreen();
    } else if (Platform.isIOS || Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    } else {
      _logger.severe("ExitFullscreen not implemented for this platform.");
    }
  }

  void videoPlay() {
    setState(() {
      playState = PlayState.play;
      controller.play();
    });
  }

  void videoPause() {
    setState(() {
      playState = PlayState.pause;
      controller.pause();
    });
  }

  void _togglePlayState() {
    if (playState == PlayState.play) {
      videoPause();
    } else {
      videoPlay();
    }
  }

  void toggleMute() {
    if (muteState == MuteState.unmute) {
      setState(() {
        muteState = MuteState.mute;
      });
      controller.mute();
    } else {
      setState(() {
        muteState = MuteState.unmute;
      });
      controller.unmute();
    }
  }

  void _seekForward() {
    controller.seekRelative(const Duration(seconds: 10));
    _seekFeedbackTimer?.cancel();
    setState(() {
      _showSeekFeedback = true;
      _seekFeedbackText = "+10s";
    });
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showSeekFeedback = false);
    });
    _showControlPanel();
  }

  void _seekBackward() {
    controller.seekRelative(const Duration(seconds: -10));
    _seekFeedbackTimer?.cancel();
    setState(() {
      _showSeekFeedback = true;
      _seekFeedbackText = "-10s";
    });
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showSeekFeedback = false);
    });
    _showControlPanel();
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
    controller.toggleLoop();
    _showControlPanel();
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    controller.setRate(speed);
    _showControlPanel();
  }

  void _toggleCast() {
    controller.cast();
    _showControlPanel();
  }

  void _setSubtitle(String trackId) {
    controller.setSubtitle(trackId);
    _showControlPanel();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.space:
          _togglePlayState();
          break;
        case LogicalKeyboardKey.keyM:
          toggleMute();
          break;
        case LogicalKeyboardKey.keyF:
          break;
        default:
      }
    } else {}
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildSeekBar() {
    return ValueListenableBuilder<PlayerProgress>(
      valueListenable: controller.progress,
      builder: (context, data, child) {
        double position = data.position.inSeconds.toDouble();
        double duration = data.duration.inSeconds.toDouble();
        String secondsText = (data.position.inSeconds % 60).toString().padLeft(
          2,
          '0',
        );
        String minutesText = (data.position.inMinutes % 60).toString().padLeft(
          2,
          '0',
        );
        String timeLabel = '$minutesText:$secondsText';

        if (data.duration.inHours != 0) {
          String hoursText = (data.position.inHours % 60).toString().padLeft(
            2,
            '0',
          );
          timeLabel = '$hoursText:$timeLabel';
          if (data.duration.inDays != 0) {
            String daysText = (data.position.inDays % 60).toString().padLeft(
              2,
              '0',
            );
            timeLabel = '$daysText:$timeLabel';
          }
        }

        _logger.fine("playing at $duration\\$position");
        final colorScheme = Theme.of(context).colorScheme;
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            showValueIndicator: ShowValueIndicator.onDrag,
            valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
          ),
          child: Slider(
            value: position,
            max: duration,
            label: timeLabel,
            onChanged: (double value) {
              setState(() {
                controller.seek(Duration(seconds: value.toInt()));
              });
            },
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.surfaceContainerHighest,
          ),
        );
      },
    );
  }

  Widget _buildBottomControlPanel() {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedPositioned(
      duration: const Duration(seconds: 1),
      bottom: _showControlPanelState ? 0 : -90,
      curve: Curves.elasticInOut,
      left: 0,
      right: 0,
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 20,
            child: Stack(children: [_buildSeekBar()]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Control
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () => controller.prev(),
                  ),
                  IconButton(
                    onPressed: _seekBackward,
                    icon: Icon(Icons.fast_rewind, color: colorScheme.onSurface),
                  ),
                  playState == PlayState.pause
                      ? IconButton(
                          icon: Icon(
                            Icons.play_arrow,
                            color: colorScheme.onSurface,
                          ),
                          iconSize: 48.0,
                          onPressed: _togglePlayState,
                        )
                      : IconButton(
                          icon: Icon(Icons.pause, color: colorScheme.onSurface),
                          iconSize: 48.0,
                          onPressed: _togglePlayState,
                        ),
                  IconButton(
                    onPressed: _seekForward,
                    icon: Icon(
                      Icons.fast_forward,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, color: colorScheme.onSurface),
                    onPressed: () => controller.next(),
                  ),
                ],
              ),
              Row(
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                  //   iconSize: 64.0,
                  //   onPressed: () {},
                  // ),
                  // IconButton(
                  //   icon: const Icon(Icons.stop, color: Colors.white),
                  //   iconSize: 48.0,
                  //   onPressed: () {/},
                  // ),
                  IconButton(
                    icon: Icon(
                      Icons.format_list_bulleted,
                      color: _showEpisodePicker
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    onPressed: _toggleEpisodePicker,
                  ),

                  windowState == WindowState.fullscreen
                      ? IconButton(
                          icon: Icon(
                            Icons.fullscreen_exit,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: exitFullscreen,
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.fullscreen,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: fullscreen,
                        ),

                  IconButton(
                    icon: Icon(
                      _volume == 0 ? Icons.volume_off : Icons.volume_up,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: _showVolumePopup,
                  ),
                  MenuAnchor(
                    builder: (context, controller, child) => IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: Icon(Icons.settings, color: colorScheme.onSurface),
                    ),
                    menuChildren: [
                      SubmenuButton(
                        leadingIcon: const Icon(Icons.speed),
                        menuChildren: _playbackSpeeds
                            .map(
                              (speed) => MenuItemButton(
                                onPressed: () => _setPlaybackSpeed(speed),
                                child: Text(
                                  "${speed}x${speed == 1.0 ? ' (Normal)' : ''}",
                                ),
                              ),
                            )
                            .toList(),
                        child: Text("Playback speed: ${_playbackSpeed}x"),
                      ),
                      const MenuItemButton(child: Text("Quality")),
                      MenuItemButton(
                        child: const Text("Playback info"),
                        onPressed: () => setState(() {
                          _showPlaybackInfo = !_showPlaybackInfo;
                        }),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.cast, color: colorScheme.onSurface),
                    onPressed: _toggleCast,
                  ),
                  MenuAnchor(
                    builder: (context, controller, child) => IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: Icon(Icons.subtitles, color: colorScheme.onSurface),
                    ),
                    menuChildren: [
                      MenuItemButton(
                        child: const Text("Off"),
                        onPressed: () => _setSubtitle("off"),
                      ),
                      MenuItemButton(
                        child: const Text("Track 1"),
                        onPressed: () => _setSubtitle("1"),
                      ),
                      MenuItemButton(
                        child: const Text("Track 2"),
                        onPressed: () => _setSubtitle("2"),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.loop,
                      color: _isLooping
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    onPressed: _toggleLoop,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeekFeedback() {
    return Center(
      child: AnimatedOpacity(
        opacity: _showSeekFeedback ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 179),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _seekFeedbackText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackInfo() {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 40,
      left: 20,
      child: Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 1,
              right: 1,
              child: IconButton(
                onPressed: () => setState(() {
                  _showPlaybackInfo = !_showPlaybackInfo;
                }),
                icon: Icon(Icons.close, color: colorScheme.onSurface),
              ),
            ),
            Column(
              children: [
                Text(
                  "Conatiner info",
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                Text(
                  "Rate: 53.3Mbps",
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                Text(
                  "Transcode",
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                Text("mkv", style: TextStyle(color: colorScheme.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 243),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 77),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.playlist_play,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  "选集",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () => setState(() => _showEpisodePicker = false),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _episodes.length,
              itemBuilder: (context, index) {
                final episode = _episodes[index];
                final isSelected = index == _currentEpisodeIndex;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: colorScheme.primaryContainer.withValues(
                    alpha: 77,
                  ),
                  leading: Icon(
                    episode.isWatched
                        ? Icons.check_circle
                        : Icons.play_circle_outline,
                    color: episode.isWatched
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    episode.title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    _formatDuration(episode.duration),
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.play_arrow, color: colorScheme.primary)
                      : null,
                  onTap: () => _playEpisode(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bindListener({required Widget child}) {
    bool isPointerDown = false;
    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        _handleKeyEvent(event);
        return KeyEventResult.ignored; // Continue event propagation
      },
      child: MouseRegion(
        onHover: (_) {
          if (!_locked) _showControlPanel();
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) => isPointerDown = true,
          onPointerMove: (event) {
            if (isPointerDown && !_locked) _showControlPanel();
          },
          onPointerUp: (event) => isPointerDown = false,
          child: GestureDetector(
            onTap: () {
              if (!_locked) {
                _togglePlayState();
                _showControlPanel();
              }
            },
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget player = MediaKitPlayerImpl(controller: controller);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _bindListener(
        child: Stack(
          children: [
            Center(child: player),

            _buildBottomControlPanel(),

            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.elasticInOut,
              top: _showControlPanelState ? 0 : -40,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                  ),
                  Text(
                    "Video title",
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
            ),

            if (playState == PlayState.caching)
              Center(
                child: SizedBox(
                  width: 67,
                  height: 67,
                  child: CircularProgressIndicator(
                    strokeWidth: 8.0,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            if (_showPlaybackInfo) _buildPlaybackInfo(),

            _buildSeekFeedback(),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: _showEpisodePicker ? 0 : -300,
              child: _buildEpisodePicker(),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 16,
              right: _showEpisodePicker ? 300 : 10,
              child: IconButton(
                onPressed: () => setState(() {
                  _locked = !_locked;
                }),
                icon: _locked
                    ? Icon(Icons.lock, color: colorScheme.onSurface, size: 32)
                    : Icon(
                        Icons.lock_open,
                        color: colorScheme.onSurface,
                        size: 32,
                      ),
              ),
            ),

            // _buildEpisodeSeleterPanel(),
          ],
        ),
      ),
    );
  }
}

class PlayerProgress {
  final Duration position;
  final Duration duration;
  PlayerProgress({required this.position, required this.duration});
}

class VideoPlayerController {
  late VoidCallback _pause;
  late VoidCallback _stop;
  late VoidCallback _play;
  late VoidCallback _next;
  late VoidCallback _prev;
  late ValueSetter<Duration> _seek;
  late ValueSetter<double> _setVolume;
  late ValueSetter<Duration> _seekRelative;
  late void Function(double) _setRate;
  late VoidCallback _toggleLoop;
  late VoidCallback _mute;
  late VoidCallback _unmute;
  late void Function() _cast;
  late void Function(String) _setSubtitle;
  late void Function(List<String>, int) _open;

  final progress = ValueNotifier<PlayerProgress>(
    PlayerProgress(position: Duration.zero, duration: Duration.zero),
  );

  final rate = ValueNotifier<double>(1.0);
  final isLooping = ValueNotifier<bool>(false);

  void pause() => _pause();
  void stop() => _stop();
  void play() => _play();
  void next() => _next();
  void prev() => _prev();
  void seek(Duration duration) => _seek(duration);
  void setVolume(double volume) => _setVolume(volume);
  void seekRelative(Duration duration) => _seekRelative(duration);
  void setRate(double rate) => _setRate(rate);
  void toggleLoop() => _toggleLoop();
  void mute() => _mute();
  void unmute() => _unmute();
  void cast() => _cast();
  void setSubtitle(String trackId) => _setSubtitle(trackId);
  void open(List<String> list, {int startIndex = 0}) => _open(list, startIndex);
}

class MediaKitPlayerImpl extends StatefulWidget {
  final VideoPlayerController controller;
  const MediaKitPlayerImpl({super.key, required this.controller});

  @override
  State<MediaKitPlayerImpl> createState() => _MediaKitPlayerImplState();
}

class _MediaKitPlayerImplState extends State<MediaKitPlayerImpl> {
  final Logger _logger = Logger('MediaKitPlayerImpl');
  late final _player = Player();
  late final _controller = VideoController(_player);
  @override
  void initState() {
    super.initState();
    widget.controller._open = open;
    widget.controller._pause = pause;
    widget.controller._stop = stop;
    widget.controller._play = play;
    widget.controller._seek = seek;
    widget.controller._next = next;
    widget.controller._prev = prev;
    widget.controller._setVolume = setVolume;
    widget.controller._seekRelative = seekRelative;
    widget.controller._setRate = setRate;
    widget.controller._toggleLoop = toggleLoop;
    widget.controller._mute = mute;
    widget.controller._unmute = unmute;
    widget.controller._cast = cast;
    widget.controller._setSubtitle = setSubtitle;
  }

  void open(List<String> list, int startIndex) {
    _player.open(
      Playlist(list.map((x) => Media(x)).toList(), index: startIndex),
    );

    _player.stream.duration.listen((Duration d) {
      if (d != Duration.zero) {
        widget.controller.progress.value = PlayerProgress(
          position: widget.controller.progress.value.position,
          duration: d,
        );
      }
    });
    _player.stream.position.listen((Duration d) {
      if (d != Duration.zero) {
        widget.controller.progress.value = PlayerProgress(
          position: d,
          duration: widget.controller.progress.value.duration,
        );
      }
    });
  }

  void pause() => _player.pause();
  void stop() => _player.stop();
  void seek(Duration duration) => _player.seek(duration);
  void play() => _player.play();
  void next() => _player.next();
  void previous() => _player.previous();
  void prev() => previous();
  void seekRelative(Duration duration) {
    final currentPosition = _player.state.position;
    final newPosition = currentPosition + duration;
    _player.seek(newPosition);
  }

  void setRate(double rate) => _player.setRate(rate);
  void toggleLoop() {
    final currentLoop = widget.controller.isLooping.value;
    widget.controller.isLooping.value = !currentLoop;
    if (!currentLoop) {
      _player.setPlaylistMode(PlaylistMode.loop);
    } else {
      _player.setPlaylistMode(PlaylistMode.none);
    }
  }

  void mute() => _player.setVolume(0);
  void unmute() => _player.setVolume(100);
  void setVolume(double volume) => _player.setVolume(volume);
  void cast() {
    _logger.info('Cast functionality not implemented in this platform');
  }

  void setSubtitle(String trackId) {
    _logger.info('Subtitle track: $trackId');
  }

  @override
  Widget build(BuildContext context) {
    return Video(controller: _controller, controls: NoVideoControls);
  }
}
