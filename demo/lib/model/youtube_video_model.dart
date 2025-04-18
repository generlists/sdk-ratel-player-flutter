

class YoutubeVideoModel {
  final String title;
  final String videoId;
  YoutubeVideoModel({required this.title, required this.videoId});

  factory YoutubeVideoModel.fromJson(Map<String, dynamic> json) {
    return YoutubeVideoModel(
        title: json['title'],
        videoId: json['videoId']
    );
  }
}