

import 'package:demo/model/youtube_model.dart';

class YoutubeVideoListModel {
  final String exampleTitle;
  final List<YoutubeModel> videoList;

  YoutubeVideoListModel({required this.exampleTitle,required this.videoList});

  factory YoutubeVideoListModel.fromJson(Map<String, dynamic> json) {
    return YoutubeVideoListModel(
      exampleTitle: json['exampleTitle'] ?? '',
      videoList: (json['videoList'] as List<dynamic>)
          .map((item) => YoutubeModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}