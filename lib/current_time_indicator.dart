import 'dart:async';
import 'package:flutter/material.dart';

class CurrentTimeIndicator extends StatefulWidget {
  final double hourHeight;
  const CurrentTimeIndicator({super.key, required this.hourHeight});

  @override
  State<CurrentTimeIndicator> createState() => _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends State<CurrentTimeIndicator> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final top = (now.hour + now.minute / 60.0) * widget.hourHeight;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          const SizedBox(width: 50),
          const CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
          Expanded(
            child: Container(
              height: 2,
              color: Colors.redAccent.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
