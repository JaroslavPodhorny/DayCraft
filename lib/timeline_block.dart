import 'package:flutter/material.dart';
import 'package:day_craft/models.dart';

class DraggableTimelineBlock extends StatefulWidget {
  final TimeBlock block;
  final double hourHeight;
  final Function(TimeBlock) onUpdate;
  final VoidCallback onTap;

  const DraggableTimelineBlock({
    super.key,
    required this.block,
    required this.hourHeight,
    required this.onUpdate,
    required this.onTap,
  });

  @override
  State<DraggableTimelineBlock> createState() => _DraggableTimelineBlockState();
}

class _DraggableTimelineBlockState extends State<DraggableTimelineBlock> {
  double? _dragDy;
  double? _resizeDy;

  @override
  Widget build(BuildContext context) {
    double top = _calculateTopOffset(widget.block.start);
    double height = _calculateHeight(widget.block.start, widget.block.end);

    if (_dragDy != null) {
      top += _dragDy!;
    }
    if (_resizeDy != null) {
      height += _resizeDy!;
    }

    return Positioned(
      top: top,
      left: 60, // Space for time labels
      right: 20,
      height: height,
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            onVerticalDragStart: (_) => setState(() => _dragDy = 0),
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragDy = (_dragDy ?? 0) + details.delta.dy;
              });
            },
            onVerticalDragEnd: (_) => _finalizeDrag(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.block.color.withOpacity(0.9),
                    widget.block.color.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  if (_dragDy != null || _resizeDy != null)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.block.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${widget.block.start.format(context)} - ${widget.block.end.format(context)}",
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 15,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (_) => setState(() => _resizeDy = 0),
              onVerticalDragUpdate: (details) {
                setState(() {
                  _resizeDy = (_resizeDy ?? 0) + details.delta.dy;
                });
              },
              onVerticalDragEnd: (_) => _finalizeResize(),
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTopOffset(TimeOfDay time) {
    return (time.hour * widget.hourHeight) +
        (time.minute * widget.hourHeight / 60);
  }

  double _calculateHeight(TimeOfDay start, TimeOfDay end) {
    double startMin = (start.hour * 60) + start.minute.toDouble();
    double endMin = (end.hour * 60) + end.minute.toDouble();
    return (endMin - startMin) * (widget.hourHeight / 60);
  }

  void _finalizeDrag() {
    if (_dragDy == null) return;

    double minutesMoved = _dragDy! / (widget.hourHeight / 60);

    int snapInterval = 15;
    int snappedMinutes = (minutesMoved / snapInterval).round() * snapInterval;

    if (snappedMinutes == 0) {
      setState(() => _dragDy = null);
      return;
    }

    int startTotal =
        (widget.block.start.hour * 60) +
        widget.block.start.minute +
        snappedMinutes;
    int endTotal =
        (widget.block.end.hour * 60) + widget.block.end.minute + snappedMinutes;

    if (startTotal < 0) {
      int diff = 0 - startTotal;
      startTotal += diff;
      endTotal += diff;
    }
    if (endTotal > 24 * 60) {
      endTotal = 24 * 60;
    }

    TimeOfDay newStart = TimeOfDay(
      hour: startTotal ~/ 60,
      minute: startTotal % 60,
    );
    TimeOfDay newEnd = TimeOfDay(hour: endTotal ~/ 60, minute: endTotal % 60);

    widget.onUpdate(widget.block.copyWith(start: newStart, end: newEnd));

    setState(() {
      _dragDy = null;
    });
  }

  void _finalizeResize() {
    if (_resizeDy == null) return;

    double minutesMoved = _resizeDy! / (widget.hourHeight / 60);
    int snapInterval = 15;
    int snappedMinutes = (minutesMoved / snapInterval).round() * snapInterval;

    if (snappedMinutes == 0) {
      setState(() => _resizeDy = null);
      return;
    }

    int endTotal =
        (widget.block.end.hour * 60) + widget.block.end.minute + snappedMinutes;

    int startTotal = (widget.block.start.hour * 60) + widget.block.start.minute;
    if (endTotal <= startTotal) {
      endTotal = startTotal + 15;
    }
    if (endTotal > 24 * 60) endTotal = 24 * 60;

    TimeOfDay newEnd = TimeOfDay(hour: endTotal ~/ 60, minute: endTotal % 60);
    widget.onUpdate(widget.block.copyWith(end: newEnd));

    setState(() {
      _resizeDy = null;
    });
  }
}
