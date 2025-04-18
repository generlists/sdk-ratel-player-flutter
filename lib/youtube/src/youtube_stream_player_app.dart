import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdk_ratel_player_flutter/youtube/src/youtube_player_style.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_playback_state.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_player.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_player_options.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as flutter;
import 'dart:async';

class YouTubeStreamPlayerApp implements YouTubeStreamPlayer {
  flutter.YoutubePlayerController? _controller;
  final YoutubePlayerOptions options;
  final StreamController<YoutubeStreamPlaybackState> _stateStreamController =
      StreamController.broadcast();
  final StreamController<double> _positionStreamController =
      StreamController.broadcast();
  List<String> _playlist = [];
  int _currentIndex = 0;
  bool _isFullScreen = false;

  final ValueNotifier<bool> isFullScreenNotifier = ValueNotifier(false);

  YouTubeStreamPlayerApp({this.options = const YoutubePlayerOptions()});

  YoutubeStreamPlaybackState _mapToPlayerState(flutter.PlayerState state) {
    switch (state) {
      case flutter.PlayerState.unStarted:
        return YoutubeStreamPlaybackState.UNSTARTED;
      case flutter.PlayerState.ended:
        return YoutubeStreamPlaybackState.ENDED;
      case flutter.PlayerState.playing:
        return YoutubeStreamPlaybackState.PLAYING;
      case flutter.PlayerState.paused:
        return YoutubeStreamPlaybackState.PAUSE;
      case flutter.PlayerState.buffering:
        return YoutubeStreamPlaybackState.BUFFERING;
      case flutter.PlayerState.cued:
        return YoutubeStreamPlaybackState.CUED;
      default:
        return YoutubeStreamPlaybackState.UNKNOWN;
    }
  }

  @override
  Widget buildPlayerWidget(
    String videoId,
    double aspectRatio, {
    PlayerStyleBuilder? configureStyle,
    Widget? uiWhenNormal,
    Widget? uiWhenFullScreen,
  }) {
    if (_controller == null) {
      final flags = _toFlutterFlags(options);

      _controller = flutter.YoutubePlayerController(
        initialVideoId: '',
        flags: flags,
      );

      _isFullScreen = _controller!.value.isFullScreen;
    }

    final baseStyle = const PlayerStyle();
    final style = configureStyle?.call(baseStyle) ?? baseStyle;

    //FullScreen UI 대응
    return flutter.YoutubePlayerBuilder(
      player: flutter.YoutubePlayer(
        controller: _controller!,
        aspectRatio: aspectRatio,
        showVideoProgressIndicator: style.showVideoProgressIndicator,
        progressIndicatorColor: style.progressIndicatorColor,
        progressColors: flutter.ProgressBarColors(
          playedColor: style.playedColor,
          handleColor: style.handledColor,
        ),
        onReady: () {
          if (_controller!.metadata.videoId != videoId) {
            _controller?.load(videoId);

            _controller?.addListener(() {
              final state = _mapToPlayerState(_controller!.value.playerState);
              _stateStreamController.add(state);

              _positionStreamController
                  .add(_controller!.value.position.inSeconds.toDouble());

              final current = _controller!.value.isFullScreen;
              if (isFullScreenNotifier.value != current) {
                isFullScreenNotifier.value = current;
              }
            });
          }
        },
      ),
      builder: (context, player) {
        final isFullScreen = _controller!.value.isFullScreen;

        return Column(
          children: [
            player,
            const SizedBox(height: 12),
            if (isFullScreen)
              if (uiWhenFullScreen != null)
                uiWhenFullScreen
              else if (uiWhenNormal != null)
                uiWhenNormal,
          ],
        );
      },
    );
  }

  @override
  Future<void> loadVideo(String videoId,
      {bool autoPlay = true, double startSeconds = 0}) async {
    if (_playlist.isEmpty || _playlist.length == 1) {
      _playlist = [videoId]; // 단일 영상 모드일 때만 덮어씀
      _currentIndex = 0;
    } else {
      _currentIndex = _playlist.indexOf(videoId);
    }
    if (!autoPlay) {
      _controller?.pause();
    }
    _controller?.load(videoId, startAt: startSeconds.toInt());
  }

  @override
  Future<void> loadCue(String videoId, {double startSeconds = 0}) async {
    if (_playlist.isEmpty || _playlist.length == 1) {
      _playlist = [videoId];
      _currentIndex = 0;
    } else {
      _currentIndex = _playlist.indexOf(videoId);
    }
    _controller?.cue(videoId, startAt: startSeconds.toInt());
  }

  @override
  Future<void> loadPlaylist({
    required List<String> videoIds,
    required bool autoPlay,
    int startIndex = 0,
    double startSeconds = 0,
  }) async {
    _playlist = videoIds.toSet().toList();
    print("length :  ${_playlist.length}");
    _currentIndex = startIndex.clamp(0, videoIds.length - 1);

    await loadVideo(videoIds[_currentIndex],
        autoPlay: autoPlay, startSeconds: startSeconds);
  }

  @override
  Future<void> play() async => _controller?.play();

  @override
  Future<void> pause() async => _controller?.pause();

  @override
  Future<void> stop() async => _controller?.pause();

  @override
  Future<void> nextVideo() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await loadVideo(_playlist[_currentIndex]);
    }
  }

  @override
  Future<void> previousVideo() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await loadVideo(_playlist[_currentIndex]);
    }
  }

  @override
  Future<void> playVideoAt(int index) async {
    print("indexindexindexindexindex $index ${_playlist.length}");
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;

      await loadVideo(_playlist[_currentIndex]);
    }
  }

  @override
  Future<bool> isPlaying() async => _controller?.value.isPlaying ?? false;

  @override
  Future<double> getCurrentPosition() async =>
      _controller?.value.position.inSeconds.toDouble() ?? 0.0;

  @override
  Future<double> getDuration() async =>
      _controller?.value.metaData.duration.inSeconds.toDouble() ?? 0.0;

  @override
  Future<String?> getCurrentVideoId() async => _controller?.metadata.videoId;

  @override
  Future<int> getCurrentPlaylistIndex() async => _currentIndex;

  @override
  Future<void> seekTo(double seconds) async =>
      _controller?.seekTo(Duration(seconds: seconds.toInt()));

  @override
  Future<void> setVolume(int volume) async => _controller?.setVolume(volume);

  @override
  Future<void> mute() async => _controller?.mute();

  @override
  Future<void> unMute() async => _controller?.unMute();

  @override
  Future<void> setPlaybackRate(double rate) async =>
      _controller?.setPlaybackRate(rate);

  @override
  Future<void> enterFullScreen({bool lock = true}) async {
    _controller?.toggleFullScreenMode();
    if (lock && !kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  Future<void> exitFullScreen({bool lock = true}) async {
    _controller?.toggleFullScreenMode();
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  Future<void> toggleFullScreen() async {
    if (_isFullScreen) {
      await exitFullScreen();
    } else {
      await enterFullScreen();
    }
  }

  @override
  Future<void> setShowControls(bool show) async {
    // youtube_player_flutter는 동적 컨트롤 표시/숨김 미지원
    print(
        'Warning: setShowControls is not supported in youtube_player_flutter');
  }

  @override
  Future<void> setShowSubtitles(bool show) async {
    // youtube_player_flutter는 런타임 자막 제어 미지원, 초기 설정에 의존
    print(
        'Warning: setShowSubtitles is not supported in youtube_player_flutter');
  }

  @override
  Stream<YoutubeStreamPlaybackState> getPlayerStateStream() =>
      _stateStreamController.stream;

  @override
  Stream<double> getPositionStream() => _positionStreamController.stream;

  @override
  Future<void> dispose() async {
    _controller?.removeListener(_fullScreenListener);
    _controller?.dispose();
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    await _stateStreamController.close();
    await _positionStreamController.close();
  }

  @override
  Future<bool> isFullScreen() async {
    return _controller?.value.isFullScreen ?? false;
  }

  void _fullScreenListener() {
    if (_controller?.value.isFullScreen == true) {
      print('KKKKKKKKKKK Entered fullscreen mode');
    } else {
      print('KKKKKKKKKKK Exited fullscreen mode');
    }
  }

  @override
  ValueNotifier<bool>? getFullScreenNotifier() => isFullScreenNotifier;

  flutter.YoutubePlayerFlags _toFlutterFlags(YoutubePlayerOptions opt) {
    return flutter.YoutubePlayerFlags(
      autoPlay: opt.autoPlay,
      mute: opt.mute,
      enableCaption: opt.enableCaption,
      captionLanguage: opt.captionLanguage,
      loop: opt.loop,
      hideControls: opt.hideControls,
      controlsVisibleAtStart: opt.controlsVisibleAtStart,
      isLive: opt.isLive,
      hideThumbnail: opt.hideThumbnail,
      disableDragSeek: opt.disableDragSeek,
      forceHD: opt.forceHD,
      startAt: opt.startAt,
      endAt: opt.endAt,
      useHybridComposition: opt.useHybridComposition,
      showLiveFullscreenButton: opt.showFullscreenButton,
    );
  }
}
