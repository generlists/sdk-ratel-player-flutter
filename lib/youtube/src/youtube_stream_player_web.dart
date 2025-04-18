import 'package:flutter/material.dart';
import 'package:sdk_ratel_player_flutter/youtube/src/youtube_player_style.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_playback_state.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as iframe;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../youtube_player_options.dart';
import '../youtube_stream_player.dart';
import 'dart:async';

class YouTubeStreamPlayerWeb implements YouTubeStreamPlayer {
  late iframe.YoutubePlayerController _controller;
  final YoutubePlayerOptions options;
  final StreamController<YoutubeStreamPlaybackState> _stateStreamController =
      StreamController.broadcast();
  final StreamController<double> _positionStreamController =
      StreamController.broadcast();
  Timer? _positionTimer;
  List<String> _playlist = [];
  int _currentIndex = 0;
  bool _isFullScreen = false;
  bool _showControls = true; // 컨트롤 상태 캐싱
  bool _showSubtitles = true; // 자막 상태 캐싱

  YouTubeStreamPlayerWeb({this.options = const YoutubePlayerOptions()}) {
    final params = _toIframeParams(options);

    _controller = iframe.YoutubePlayerController.fromVideoId(
      videoId: '',
      params: params,
      autoPlay: options.autoPlay,
    );

    _controller.listen((event) {
      _stateStreamController.add(_mapToPlayerState(event.playerState));
      _updateCurrentIndex();
    });

    _startPositionUpdates();
  }

  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!_positionStreamController.isClosed) {
        final currentTime = await _controller.currentTime;
        if (currentTime != null) {
          _positionStreamController.add(currentTime);
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _updateCurrentIndex() async {
    final currentVideoId = await _controller.metadata.videoId;
    if (currentVideoId != null && _playlist.isNotEmpty) {
      final index = _playlist.indexOf(currentVideoId);
      if (index != -1) {
        _currentIndex = index;
      }
    }
  }

  @override
  Widget buildPlayerWidget(
    String videoId,
    double aspectRatio, {
    PlayerStyleBuilder? configureStyle,
  }) {
    return iframe.YoutubePlayer(
      controller: _controller,
      aspectRatio: aspectRatio,
    );
  }

  @override
  Future<void> loadVideo(String videoId,
      {bool autoPlay = false, double startSeconds = 0}) async {
    _playlist = [videoId];
    _currentIndex = 0;
    if (autoPlay) {
      await _controller.loadVideoById(
          videoId: videoId, startSeconds: startSeconds);
    } else {
      await _controller.cueVideoById(
          videoId: videoId, startSeconds: startSeconds);
    }
  }

  @override
  Future<void> loadCue(String videoId, {double startSeconds = 0}) async {
    _playlist = [videoId];
    _currentIndex = 0;
    await _controller.cueVideoById(
        videoId: videoId, startSeconds: startSeconds);
  }

  @override
  Future<void> loadPlaylist({
    required List<String> videoIds,
    required bool autoPlay,
    int startIndex = 0,
    double startSeconds = 0,
  }) async {
    _playlist = videoIds.toSet().toList();
    _currentIndex = startIndex.clamp(0, videoIds.length - 1);
    await _controller.loadPlaylist(
      list: videoIds,
      listType: iframe.ListType.playlist,
      startSeconds: startSeconds,
      index: startIndex,
    );
  }

  @override
  Future<void> play() async => await _controller.playVideo();

  @override
  Future<void> pause() async => await _controller.pauseVideo();

  @override
  Future<void> stop() async => await _controller.stopVideo();

  @override
  Future<void> nextVideo() async {
    await _controller.nextVideo();
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
    }
  }

  @override
  Future<void> previousVideo() async {
    await _controller.previousVideo();
    if (_currentIndex > 0) {
      _currentIndex--;
    }
  }

  @override
  Future<void> playVideoAt(int index) async {
    await _controller.playVideoAt(index);
    _currentIndex = index.clamp(0, _playlist.length - 1);
  }

  @override
  Future<bool> isPlaying() async =>
      (await _controller.playerState) == iframe.PlayerState.playing;

  @override
  Future<double> getCurrentPosition() async =>
      await _controller.currentTime ?? 0.0;

  @override
  Future<double> getDuration() async => await _controller.duration ?? 0.0;

  @override
  Future<String?> getCurrentVideoId() async =>
      await _controller.metadata.videoId;

  @override
  Future<int> getCurrentPlaylistIndex() async {
    await _updateCurrentIndex();
    return _currentIndex;
  }

  @override
  Future<void> seekTo(double seconds) async =>
      await _controller.seekTo(seconds: seconds);

  @override
  Future<void> setVolume(int volume) async =>
      await _controller.setVolume(volume);

  @override
  Future<void> mute() async => await _controller.mute();

  @override
  Future<void> unMute() async => await _controller.unMute();

  @override
  Future<void> setPlaybackRate(double rate) async =>
      await _controller.setPlaybackRate(rate);

  @override
  Future<void> enterFullScreen({bool lock = true}) async {
    _controller.enterFullScreen(); // ✅ void 반환이므로 await 없음
    _isFullScreen = true;
  }

  @override
  Future<void> exitFullScreen({bool lock = true}) async {
    _controller.exitFullScreen();
    _isFullScreen = false;
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
    if (_showControls != show) {
      _showControls = show;

      // 기존 컨트롤러 dispose
      await _controller.close();

      // 새 컨트롤러 생성
      _controller = iframe.YoutubePlayerController.fromVideoId(
        videoId: await getCurrentVideoId() ?? '',
        params: iframe.YoutubePlayerParams(
          showControls: show,
          showFullscreenButton: true,
          mute: false,
          enableCaption: _showSubtitles,
          showVideoAnnotations: false,
        ),
      );

      // 다시 listen 등록
      _controller.listen((event) {
        _stateStreamController.add(_mapToPlayerState(event.playerState));
        _updateCurrentIndex();
      });
    }
  }

  @override
  Future<void> setShowSubtitles(bool show) async {
    //존재안함.
    // if (_showSubtitles != show) {
    //   _showSubtitles = show;
    //   if (show) {
    //     await _controller.enableCaptions();
    //   } else {
    //     await _controller.disableCaptions();
    //   }
    // }
  }

  @override
  Stream<YoutubeStreamPlaybackState> getPlayerStateStream() =>
      _stateStreamController.stream;

  @override
  Stream<double> getPositionStream() => _positionStreamController.stream;

  @override
  Future<void> dispose() async {
    _positionTimer?.cancel();
    await _controller.close();
    await _stateStreamController.close();
    await _positionStreamController.close();
  }

  YoutubeStreamPlaybackState _mapToPlayerState(iframe.PlayerState state) {
    switch (state) {
      case iframe.PlayerState.unStarted:
        return YoutubeStreamPlaybackState.UNSTARTED;
      case iframe.PlayerState.ended:
        return YoutubeStreamPlaybackState.ENDED;
      case iframe.PlayerState.playing:
        return YoutubeStreamPlaybackState.PLAYING;
      case iframe.PlayerState.paused:
        return YoutubeStreamPlaybackState.PAUSE;
      case iframe.PlayerState.buffering:
        return YoutubeStreamPlaybackState.BUFFERING;
      case iframe.PlayerState.cued:
        return YoutubeStreamPlaybackState.CUED;
      default:
        return YoutubeStreamPlaybackState.UNKNOWN;
    }
  }

  @override
  Future<bool> isFullScreen() async {
    return false;
  }

  @override
  ValueNotifier<bool>? getFullScreenNotifier() => null;
}

YoutubePlayerParams _toIframeParams(YoutubePlayerOptions opt) {
  return YoutubePlayerParams(
    mute: opt.mute,
    enableCaption: opt.enableCaption,
    captionLanguage: opt.captionLanguage,
    loop: opt.loop,
    showControls: opt.showControls,
    showFullscreenButton: opt.showFullscreenButton,
    color: opt.color,
    enableKeyboard: opt.enableKeyboard,
    enableJavaScript: opt.enableJavaScript,
    interfaceLanguage: opt.interfaceLanguage,
    showVideoAnnotations: opt.showVideoAnnotations,
    origin: opt.origin,
    playsInline: opt.playsInline,
    strictRelatedVideos: opt.strictRelatedVideos,
    userAgent: opt.userAgent,
  );
}
