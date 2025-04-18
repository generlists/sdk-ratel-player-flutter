
import 'package:demo/screen/screen_demo_list_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DemoPlayer());
}

class DemoPlayer extends StatelessWidget {
  const DemoPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratel Player Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(fontSize:24,color:Colors.white,fontWeight: FontWeight.bold,)
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const CenteredMobileApp(child: DemoListScreen()),
    );
  }


}
///웹에서도 모바일 사이즈처럼 보이게 감싸주는 위젯
class CenteredMobileApp extends StatelessWidget {
  final Widget child;

  const CenteredMobileApp({super.key, required this.child});


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileWidth = screenWidth < 600; // 모바일 기준 (웹/앱 공통)
    return Center(
      child: Container(
        width: isMobileWidth ? double.infinity : 445, // 모바일: full / PC: 고정
        height: isMobileWidth ? double.infinity : 844,
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }


}


