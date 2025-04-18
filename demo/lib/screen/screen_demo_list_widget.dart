import 'package:demo/screen/screen_advance_player_widget.dart';
import 'package:demo/screen/screen_basic_player_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;

import '../model/youtube_model.dart';
import '../model/youtube_videoList_model.dart';
import '../ui_utils.dart';

class DemoListScreen extends StatefulWidget {
  const DemoListScreen({super.key});

  @override
  _DemoScreenState createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  YoutubeModel? basicModel;
  YoutubeVideoListModel? advanceVideo;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    loadBasicJson();
    loadAdvanceJson();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileWidth = screenWidth < 600;

    Widget content = Column(
      children: [
        buildCustomAppBar(),
        Expanded(child: listWidget()),
      ],
    );

    // 웹에서만 라운딩 및 마진 적용
    if (kIsWeb) {
      content = Container(
        width: isMobileWidth ? double.infinity : 445,
        //margin: const EdgeInsets.symmetric(vertical: 72.0),
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
      backgroundColor: kIsWeb ? Colors.grey[200] : Colors.black, // 웹에서만 회색 배경
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF228B22),
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Center(
            child: content,
          ),
        ),
      ),
    );
  }

  Widget listWidget(){
    return  Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(color: Color(0x33000000)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // <-- 추가!
                  children: [
                    PreferredSize(
                      preferredSize: const Size.fromHeight(40),
                      child: Align(
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          padding: EdgeInsets.zero,
                          // 전체 패딩 제거
                          indicatorPadding: EdgeInsets.zero,
                          // 인디케이터 패딩 제거
                          labelPadding: EdgeInsets.zero,
                          // 각 탭 좌우 여백 제거
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicatorColor: Color(0xFFABFF43),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white.withOpacity(0.7),
                          tabs: const [
                            Tab(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text("YouTube",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)))),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          basicModel == null
                              ? const CircularProgressIndicator():_sampleRow(context, basicModel),
                          const SizedBox(height: 30,),
                          advanceVideo == null
                              ? const CircularProgressIndicator():_sampleRow(context, advanceVideo),
                        ],
                      )
                    ),
                  ]),
         ),
        );
  }

  Future<void> loadBasicJson() async {
    final String jsonString = await rootBundle.loadString('assets/json/youtube_basic_sample.json');
    final jsonMap = json.decode(jsonString);
    setState(() {
    basicModel = YoutubeModel.fromJson(jsonMap);

    print('이름: ${basicModel?.exampleTitle}');

    });
  }


  Future<void> loadAdvanceJson() async {
    final String jsonString = await rootBundle.loadString('assets/json/youtube_advance_sample.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
    advanceVideo = YoutubeVideoListModel.fromJson(jsonMap);

    print('이름: ${advanceVideo?.exampleTitle}');
    print('목록: ${advanceVideo?.videoList}');
    });
  }
}

Widget _showButton(BuildContext context,dynamic model) {
  print("dynamic :  $dynamic");

  return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        child: ElevatedButton(
          onPressed: () => _goEnd(context, model),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(
              color: Color(0xFFABFF43), // 원하는 테두리 색상
              width: 1.0, // 두께
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              "재생",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ));
}

Widget _sampleRow(BuildContext context,
    final dynamic model) {

  final screenWidth = MediaQuery.of(context).size.width;
  final isMobileWidth = screenWidth < 600; // 모바일 기준 (웹/앱 공통)
  var isBasic  =  model is YoutubeModel;
  String? label = "";
  String? rowTitle = "";

  print("isBasic : $isBasic");

   if(isBasic){
     label = model.exampleTitle;
     rowTitle = model.videoModel.title??"";
   }else{
     label = (model as YoutubeVideoListModel).exampleTitle;
     rowTitle =  model.videoList[0].videoModel.title??"";
   }

  return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 15, bottom: 10),
              child: Container(
                  alignment: Alignment.centerLeft,
                  width: isMobileWidth ? double.infinity : 445,
                  // 모바일: full / PC: 고정
                  decoration: BoxDecoration(color: Colors.blueGrey),
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, top: 5, bottom: 5),
                    child: Text(
                      label,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ))),
          Container(
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                color: Colors.black12,
                border: const Border(
                  top: BorderSide(color: Colors.grey, width: 1),
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      constraints: const BoxConstraints(maxWidth: 360),
                      color: Colors.black,
                      child:  Text(
                        rowTitle,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  model == null
                      ? const CircularProgressIndicator():
                  (model is YoutubeModel)?_showButton(context, model):_showButton(context, model),

                ],
              ))
        ],
      ));
}

_goEnd(BuildContext context,dynamic model){

   var isBasic  =  model is YoutubeModel;
  String? videoId = "";
  List<String>? videoList;

  print("isBasic : $isBasic");

  if(isBasic){
    videoId = model.videoModel.videoId;
  }else{
    videoList =  (model as YoutubeVideoListModel)
        .videoList
        .map((video) => video.videoModel.videoId)
        .toList();
  }
   Navigator.of(context).push(fadeRoute(isBasic? YouTubeBasicPlayerScreen(videoId:videoId):YouTubeAdvancePlayerScreen(videoIdList:videoList)));

}
PageRouteBuilder fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 500), //애니메이션 속도 조절
  );
}
