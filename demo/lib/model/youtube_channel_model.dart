

class YoutubeChanelModel {
  final String title;
  final String channelId;
  YoutubeChanelModel({required this.title, required this.channelId});

  factory YoutubeChanelModel.fromJson(Map<String, dynamic> json) {
    return YoutubeChanelModel(
      title: json['title'],
      channelId: json['channelId']
    );
  }
}