import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sdk_ratel_player_flutter/youtube/src/youtube_player_style.dart';
import 'src/youtube_stream_player_app.dart';
import 'src/youtube_stream_player_web.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_playback_state.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_player_options.dart';

abstract class YouTubeStreamPlayer {
  factory YouTubeStreamPlayer(YoutubePlayerOptions option) {
    return kIsWeb
        ? YouTubeStreamPlayerWeb(options: option)
        : YouTubeStreamPlayerApp(options: option);
  }

  Widget buildPlayerWidget(String videoId, double aspectRatio,
      {PlayerStyleBuilder? configureStyle});

  /// 동영상 로드 및 재생
  Future<void> loadVideo(String videoId,
      {bool autoPlay = false, double startSeconds = 0});

  Future<void> loadCue(String videoId, {double startSeconds = 0});

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  /// 리소스 정리
  Future<void> dispose();

  /// 재생 목록 관리
  Future<void> loadPlaylist({
    required List<String> videoIds,
    required bool autoPlay,
    int startIndex = 0,
    double startSeconds = 0,
  });

  Future<void> nextVideo();

  Future<void> previousVideo();

  Future<void> playVideoAt(int index);

  /// 재생 상태 및 정보
  Future<bool> isPlaying();

  Future<double> getCurrentPosition();

  Future<double> getDuration();

  Future<String?> getCurrentVideoId();

  Future<int> getCurrentPlaylistIndex();

  /// 컨트롤
  Future<void> seekTo(double seconds);

  Future<void> setVolume(int volume); // 0-100
  Future<void> mute();

  Future<void> unMute();

  Future<void> setPlaybackRate(double rate); // 예: 0.5, 1.0, 2.0

  /// 전체 화면 및 UI 설정
  Future<void> enterFullScreen({bool lock = true}); // lock 옵션 추가
  Future<void> exitFullScreen({bool lock = true});

  Future<void> toggleFullScreen();

  Future<void> setShowControls(bool show);

  Future<void> setShowSubtitles(bool show);

  /// 플레이어 상태 이벤트 리스너
  Stream<YoutubeStreamPlaybackState> getPlayerStateStream();

  Stream<double> getPositionStream();

  Future<bool> isFullScreen();

  ValueNotifier<bool>? getFullScreenNotifier();
}
