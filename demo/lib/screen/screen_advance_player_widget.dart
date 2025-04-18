import 'package:demo/screen/slider_seek_bar_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdk_ratel_player_flutter/youtube/src/youtube_player_style.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_player_options.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_playback_state.dart';
import 'package:sdk_ratel_player_flutter/youtube/youtube_stream_player.dart';
import '../ui_utils.dart';

class YouTubeAdvancePlayerScreen extends StatefulWidget {
  const YouTubeAdvancePlayerScreen({super.key, required this.videoIdList});

  final List<String>? videoIdList;

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubeAdvancePlayerScreen> {
  late YouTubeStreamPlayer _player;
  double _duration = 0.0;
  int _currentIndex = -1;
  bool _showControls = true;
  bool _showSubtitles = true;
  String initialVideoId = 'Tz1PahQ4LiU';
  String playState = YoutubeStreamPlaybackState.UNKNOWN.name;
  late final List<String>? videoIdList;
  bool? isFullScreen = false;
  bool isPlaying = false;
  bool _playlistClick = false;
  bool isMute = false;

  double? _sliderValue;
  bool _isDragging = false;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    videoIdList = widget.videoIdList;

    initialVideoId = videoIdList?.elementAtOrNull(0) ?? "";

    var option = YoutubePlayerOptions(
        autoPlay: false,
        mute: isMute,
        enableCaption: true,
        captionLanguage: 'ko',
        loop: false,
        showControls: true,
        showFullscreenButton: true,
        hideControls: false,
        forceHD: true,
        useHybridComposition: true);

    _player = YouTubeStreamPlayer(option);

    print("player  :  ${_player}");

    if (kIsWeb) {
      _player.loadCue(initialVideoId);
    }

    _player.getPlayerStateStream().listen((state) async {
      _updateCurrentIndex();

      final playing = state == YoutubeStreamPlaybackState.PLAYING;
      final duration = await _player.getDuration();

      setState(() {
        isPlaying = playing;
        playState = state.name;
        if (state == YoutubeStreamPlaybackState.PLAYING) {
          _duration = duration > 0 ? duration : 0.0;
        }
      });
    });

    _player.getFullScreenNotifier()?.addListener(() {
      isFullScreen = _player.getFullScreenNotifier()?.value;
    });
  }

  Future<void> _updateCurrentIndex() async {
    final index = await _player.getCurrentPlaylistIndex();
    setState(() {
      if (_playlistClick == true) {
        _currentIndex = index;
        _initSeek();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _playlistClick = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int size = videoIdList?.length ?? 0;

    Widget content = Column(
      children: [
        isFullScreen == false ? buildCustomAppBar() : Container(),
        kIsWeb == false
            ? Container(child: _buildPlayer())
            : Align(
                alignment: Alignment.topCenter,
                child: AspectRatio(
                  aspectRatio: 16 / 9, // 또는 16 / 9, 원하는 비율로
                  child: _buildPlayer(),
                ),
              ),
        _playerState(),
        _buildCustomControls(),
        if (videoIdList?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Current Video: ${_currentIndex + 1}/${size}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // 텍스트 색상 흰색 (배경 대비)
              ),
            ),
          ),
        _buildPlaylistControls()
      ],
    );

    // 웹에서만 라운딩 및 마진 적용
    if (kIsWeb) {
      content = Container(
        alignment: Alignment.topCenter,
        width: 445,
        margin: const EdgeInsets.symmetric(vertical: 72.0),
        // 상하단 마진
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.0), // 테두리 라운딩
          boxShadow: const [
            BoxShadow(
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
            child: Align(alignment: Alignment.topCenter, child: content)),
      ),
    );
  }

  Widget _buildPlayer() {
    return _player.buildPlayerWidget(
      initialVideoId,
      16 / 9,
      configureStyle: (defaultvalue) => const PlayerStyle(
        progressIndicatorColor: Color(0xFFABFF43),
        playedColor: Color(0xFFABFF43),
        handledColor: Color(0xFF8DD631),
      ),
    );
  }

  Widget _playerState() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // 가로 최대 확장
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 10),
                      child: const Text(
                        textAlign: TextAlign.left,
                        'Play State',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SizedBox(
                        height: 50,
                        child: Text(
                          playState,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFFABFF43),
                          ),
                        ),
                      ))
                ])));
  }

  Widget _buildCustomControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                onPressed: () => _playAction(isPlaying),
                tooltip: 'Play & Pause',
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: _player.stop,
                tooltip: 'Stop',
              ),
              IconButton(
                icon: isMute ? Icon(Icons.volume_off) : Icon(Icons.volume_up),
                onPressed: () async {
                  setState(() {
                    isMute = !isMute;
                  });

                  if (isMute) {
                    await _player.mute();
                  } else {
                    await _player.unMute();
                  }
                },
                tooltip: 'Mute & UnMute',
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: _player.toggleFullScreen,
                tooltip: 'Toggle Fullscreen',
              ),
              IconButton(
                icon: Icon(
                    _showControls ? Icons.visibility : Icons.visibility_off),
                onPressed: kIsWeb
                    ? () async {
                        setState(() {
                          _showControls = !_showControls;
                        });
                        await _player.setShowControls(_showControls);
                      }
                    : null,
                disabledColor: Colors.grey,
                tooltip: 'Toggle Controls',
              ),
              IconButton(
                icon: Icon(
                    _showSubtitles ? Icons.subtitles : Icons.subtitles_off),
                onPressed: kIsWeb
                    ? () async {
                        setState(() {
                          _showSubtitles = !_showSubtitles;
                        });
                        await _player.setShowSubtitles(_showSubtitles);
                      }
                    : null,
                disabledColor: Colors.grey,
                tooltip: 'Toggle Subtitles',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _player.loadCue(initialVideoId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(
                    color: Color(0xFFABFF43), // 원하는 테두리 색상
                    width: 1.0, // 두께
                  ),
                ),
                child: const Text(
                  'Cue Video',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {
                  _player.loadVideo(initialVideoId, autoPlay: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(
                    color: Color(0xFFABFF43), // 원하는 테두리 색상
                    width: 1.0, // 두께
                  ),
                ),
                child: const Text(
                  'Load & Play',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          StreamBuilder<double>(
            stream: _player.getPositionStream(),
            builder: (context, snapshot) {
              final currentStreamPosition = snapshot.data ?? 0;
              final currentSliderPosition = _isDragging || _isSeeking
                  ? _sliderValue ?? currentStreamPosition
                  : currentStreamPosition;

              return PlayerSeekSlider(
                key: ValueKey(videoIdList?[_currentIndex < 0 ? 0 : 0]),
                // videoId 바뀌면 슬라이더 새로 생성
                currentPosition: _isDragging || _isSeeking
                    ? _sliderValue ?? snapshot.data ?? 0
                    : snapshot.data ?? 0,
                duration: _duration,
                onSeekStart: () {
                  setState(() => _isDragging = true);
                },
                onSeeking: (value) {
                  setState(() => _sliderValue = value);
                },
                onSeekEnd: (value) async {
                  setState(() {
                    _isDragging = false;
                    _isSeeking = true;
                  });
                  await _player.seekTo(value);
                  await _player.play();
                  setState(() {
                    _isSeeking = false;
                    _sliderValue = null;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistControls() {
    int size = videoIdList?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Playlist Controls',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (videoIdList != null) {
                _player.loadPlaylist(videoIds: videoIdList!, autoPlay: true);
                _playlistClick = true;
              }
            },
            child: Text(
              _playlistClick ? 'Load Playlist (Loading) ' : 'Load Playlist',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _playlistClick ? Color(0xFFABFF43) : Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: _prevNextAction(Icons.skip_previous, size),
              disabledColor: Colors.grey,
              tooltip: 'Previous Video',
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: _prevNextAction(Icons.skip_next, size),
              disabledColor: Colors.grey,
              tooltip: 'Next Video',
            )
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(size, (index) {
              return Builder(
                builder: (context) {
                  final isSelected = _currentIndex == index;
                  return ChoiceChip(
                    showCheckmark: false,
                    avatar: Icon(
                      Icons.check,
                      size: 18,
                      color: isSelected ? Color(0xFFABFF43) : Colors.grey,
                    ),
                    label: Text(
                      'Video ${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Color(0xFFABFF43) : Colors.white,
                      ),
                    ),
                    selectedColor: Colors.transparent,
                    backgroundColor: Colors.black,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: isSelected ? Color(0xFFABFF43) : Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _isSelectAction(context, index); //context 전달!
                        _initSeek();
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  _playAction(bool isPlaying) {
    isPlaying ? _player.pause() : _player.play();
  }

  _isSelectAction(context, index) {
    if (!_playlistClick || _currentIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text(
            'Play list not loaded',
            style: const TextStyle(color: Color(0xFFABFF43)), //글자색 파란색
          ),
          backgroundColor: Colors.black, //배경색 검정
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
    _player.playVideoAt(index);
  }

  _initSeek() {
    setState(() {
      _sliderValue = null;
      _isDragging = false;
      _isSeeking = false;
    });
  }

  _prevNextAction(IconData icon, int size) {
    if (icon == Icons.skip_previous) {
      _currentIndex > 0 ? _player.previousVideo : null;
    } else if (icon == Icons.skip_next) {
      _currentIndex < size - 1 ? _player.nextVideo : null;
    }
    _initSeek();
  }
}
