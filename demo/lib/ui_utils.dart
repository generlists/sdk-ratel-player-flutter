import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🔸 커스텀 앱바 위젯
Widget buildCustomAppBar() {
  return Material(
    elevation: 4, // 앱바 기본 elevation 효과 적용 (그림자)
    child: Container(
      height: kToolbarHeight,
      color: const Color(0xFF228B22),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Ratel Player Demo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // 기본 AppBar의 타이틀 폰트 사이즈와 동일
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}