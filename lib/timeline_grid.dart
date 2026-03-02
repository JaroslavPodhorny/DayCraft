import 'package:flutter/material.dart';

class TimelineGrid extends StatelessWidget {
  final double hourHeight;
  const TimelineGrid({super.key, required this.hourHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(24, (index) {
        return Container(
          height: hourHeight,
          decoration: const BoxDecoration(),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Center(
                  child: Text(
                    "$index:00",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Theme.of(context).dividerColor,
                  height: 1,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
