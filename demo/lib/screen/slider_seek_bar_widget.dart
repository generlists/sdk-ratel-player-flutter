import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//Slider는 Stateless 위젯이라 직접 상태를 안 가지므로 상태가지게 커스텀으로 구현
class PlayerSeekSlider extends StatefulWidget {
  final double currentPosition; // 재생 위치 (stream 기반)
  final double duration;        // 총 길이
  final Future<void> Function(double value) onSeekEnd;
  final void Function()? onSeekStart;
  final void Function(double value)? onSeeking;

  const PlayerSeekSlider({
    super.key,
    required this.currentPosition,
    required this.duration,
    required this.onSeekEnd,
    this.onSeekStart,
    this.onSeeking,
  });

  @override
  State<PlayerSeekSlider> createState() => _PlayerSeekSliderState();
}

class _PlayerSeekSliderState extends State<PlayerSeekSlider> {
  double? _sliderValue;
  bool _isDragging = false;
  bool _isSeeking = false;

  @override
  void didUpdateWidget(covariant PlayerSeekSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 영상이 바뀐 경우 이전 상태 초기화
    if (widget.key != oldWidget.key) {
      _sliderValue = null;
      _isDragging = false;
      _isSeeking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double valueToShow = (_isDragging || _isSeeking)
        ? (_sliderValue ?? widget.currentPosition)
        : widget.currentPosition;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: const Color(0xFFABFF43),
        inactiveTrackColor: Colors.grey[800],
        thumbColor: const Color(0xFFABFF43),
        overlayColor: const Color(0x30ABFF43),
        trackHeight: 4.0,
      ),
      child: Slider(
        value: valueToShow.clamp(0.0, widget.duration),
        max: widget.duration,
        onChangeStart: (_) {
          setState(() {
            _isDragging = true;
            _sliderValue = widget.currentPosition;
          });
          widget.onSeekStart?.call();
        },
        onChanged: (value) {
          setState(() {
            _sliderValue = value;
          });
          widget.onSeeking?.call(value);
        },
        onChangeEnd: (value) async {
          setState(() {
            _isDragging = false;
            _isSeeking = true;
          });

          await widget.onSeekEnd(value);

          // 🔐 안정성 확보: 잠깐 기다렸다가 해제하면 stream 충돌 방지
          await Future.delayed(const Duration(milliseconds: 100));

          if (mounted) {
            setState(() {
              _isSeeking = false;
              _sliderValue = null;
            });
          }
        },
      ),
    );
  }
}