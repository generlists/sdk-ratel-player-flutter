
import 'package:demo/model/youtube_channel_model.dart';
import 'package:demo/model/youtube_video_model.dart';

class YoutubeModel {
  final String exampleTitle;
  final YoutubeChanelModel channelModel;
  final YoutubeVideoModel videoModel;

  YoutubeModel({required this.exampleTitle, required this.channelModel, required this.videoModel});

  factory YoutubeModel.fromJson(Map<String, dynamic> json) {
    return YoutubeModel(
      exampleTitle: json['exampleTitle']?? '',
      channelModel: YoutubeChanelModel.fromJson(json['channelModel'] ?? {}),
      videoModel: YoutubeVideoModel.fromJson(json['videoModel'] ?? {}),
    );
  }
}