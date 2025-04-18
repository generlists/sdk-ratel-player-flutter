import 'package:flutter/foundation.dart';

class YoutubePlayerOptions {
  // 공통
  final bool autoPlay;
  final bool mute;
  final bool loop;
  final bool enableCaption;
  final String captionLanguage;

  // 컨트롤 관련
  final bool showControls;
  final bool showFullscreenButton;

  // 앱 전용
  final bool hideControls;
  final bool controlsVisibleAtStart;
  final bool isLive;
  final bool hideThumbnail;
  final bool disableDragSeek;
  final bool forceHD;
  final int startAt;
  final int? endAt;
  final bool useHybridComposition;

  // 웹 전용
  final String color; // 'red' or 'white'
  final bool enableKeyboard;
  final bool enableJavaScript;
  final String interfaceLanguage;
  final bool showVideoAnnotations;
  final String origin;
  final bool playsInline;
  final bool strictRelatedVideos;
  final String? userAgent;

  const YoutubePlayerOptions({
    this.autoPlay = true,
    this.mute = false,
    this.loop = false,
    this.enableCaption = true,
    this.captionLanguage = 'en',
    this.showControls = true,
    this.showFullscreenButton = true,

    // 앱 전용
    this.hideControls = false,
    this.controlsVisibleAtStart = false,
    this.isLive = false,
    this.hideThumbnail = false,
    this.disableDragSeek = false,
    this.forceHD = false,
    this.startAt = 0,
    this.endAt,
    this.useHybridComposition = true,

    // 웹 전용
    this.color = 'white',
    this.enableKeyboard = kIsWeb,
    this.enableJavaScript = true,
    this.interfaceLanguage = 'en',
    this.showVideoAnnotations = true,
    this.origin = 'https://www.youtube.com',
    this.playsInline = true,
    this.strictRelatedVideos = false,
    this.userAgent,
  });
}
