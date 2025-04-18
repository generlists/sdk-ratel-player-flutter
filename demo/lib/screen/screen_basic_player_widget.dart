import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_player_options.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_playback_state.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_player.dart';

import '../ui_utils.dart';

class YouTubeBasicPlayerScreen extends StatefulWidget {
  const YouTubeBasicPlayerScreen({super.key, required this.videoId});

  final String videoId;

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubeBasicPlayerScreen> {
  late YouTubeStreamPlayer _player;
  late final String videoId;
  bool? isFullScreen = false;

  @override
  void initState() {
    super.initState();
    videoId = widget.videoId; // 위젯에서 videoId 받기

    var option = const YoutubePlayerOptions(
      autoPlay: false,
      mute: true,
      enableCaption: true,
      captionLanguage: 'ko',
      loop: false,
      showControls: true,
      showFullscreenButton: false,
      hideControls: false,
      forceHD: true,
    );

    _player = YouTubeStreamPlayer(option);


    if (kIsWeb) {
      _player.loadCue(videoId);
    }

    _player.getFullScreenNotifier()?.addListener(() {
      print(" fullscreen changed: ${_player.getFullScreenNotifier()?.value}");
      isFullScreen = _player.getFullScreenNotifier()?.value;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    Widget content = Column(
      children: [
        isFullScreen == false ? buildCustomAppBar() : Container(),
        kIsWeb == false? Container(child: _buildPlayer()):

        Expanded( // 세로 방향 확장
          child: Center( // 정중앙 정렬
            child: AspectRatio(
              aspectRatio: 9 / 16, // 또는 16 / 9, 원하는 비율로
              child: _buildPlayer(),
            ),
          ),
        ),
      ],
    );

    // 웹에서만 라운딩 및 마진 적용
    if (kIsWeb) {
      content = Container(
        alignment: Alignment.center,
        width: 445,
        margin: const EdgeInsets.symmetric(vertical: 72.0),
        // 상하단 마진
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.0), // 테두리 라운딩
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: kIsWeb ? Colors.grey[200] : Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF228B22),
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          top: true,
          bottom: true,
          child: Align(
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
  Widget _buildPlayer() {
    return _player
        .buildPlayerWidget(
        videoId,
        9 / 16,
    );

    // _player.buildPlayerWidget(
    //   videoId,
    //   16 / 9,
    //   true,
    //   uiWhenNormal: MyCustomUI(), // 전체화면 아닐 때
    //   uiWhenFullScreen: Container(), // 전체화면일 때
    // );
  }

}
