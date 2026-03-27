import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/newsroom/controllers/newsroom_controller.dart';
import 'package:chamdtech_nrcs/features/newsroom/models/newsroom_state.dart';

class ControlPanel extends StatefulWidget {
  final NewsroomController controller;

  const ControlPanel({super.key, required this.controller});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _flashAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(_flashController);
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(left: BorderSide(color: Colors.white10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildGlobalTimer(context),
          const Divider(height: 1, color: Colors.white10),
          _buildSegmentTimer(context),
          const Divider(height: 1, color: Colors.white10),
          _buildControls(context),
          const Spacer(),
          _buildStatusFooter(context),
        ],
      ),
    );
  }

  Widget _buildGlobalTimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Obx(() {
        final isUrgent = widget.controller.state.value.isGlobalCountdownUrgent;
        final isRunning = widget.controller.state.value.globalTimerState == TimerState.running;
        Widget timerText = Text(
          '${widget.controller.state.value.globalCountdownSeconds}',
          style: TextStyle(
            fontSize: 90,
            fontWeight: FontWeight.w900,
            color: isUrgent ? Colors.white : (isRunning ? Colors.redAccent : Colors.white54),
            fontFamily: 'monospace',
            letterSpacing: -2,
          ),
        );

        if (isUrgent) {
          timerText = FadeTransition(
            opacity: _flashAnimation,
            child: timerText,
          );
        }

        return Column(
          children: [
            const Text('ON-AIR COUNTDOWN', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red[900] : Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isUrgent ? Colors.redAccent : Colors.white10, width: 2),
                boxShadow: isUrgent ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)] : [],
              ),
              child: timerText,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSegmentTimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Obx(() {
        final color = _getTimerColor(widget.controller.state.value.segmentTimerColor);
        return Column(
          children: [
            const Text('SEGMENT TIMER', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            Text(
              widget.controller.formatDuration(widget.controller.state.value.segmentCountdownSeconds),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'monospace',
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: color, size: 10),
                  const SizedBox(width: 8),
                  Text(
                    _getTimerStatusText(widget.controller.state.value.segmentTimerColor),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final isRunning = widget.controller.state.value.globalTimerState == TimerState.running || 
                                    widget.controller.state.value.segmentTimerState == TimerState.running;
                  return ElevatedButton(
                    onPressed: () => widget.controller.togglePlayPause(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? Colors.orange[800] : Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 32),
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.controller.resetTimers(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.refresh, size: 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.controller.nextStory(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5), // Bright blue for next story
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.skip_next, size: 28),
                SizedBox(width: 12),
                Text('NEXT STORY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black26,
      child: Obx(() => SwitchListTile(
        title: const Text('AUTO-PROGRESS', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        value: widget.controller.state.value.autoProgressionEnabled,
        onChanged: (val) => widget.controller.toggleAutoProgression(val),
        dense: true,
        contentPadding: EdgeInsets.zero,
        activeColor: Colors.greenAccent,
      )),
    );
  }

  Color _getTimerColor(SegmentTimerColor state) {
    switch (state) {
      case SegmentTimerColor.green: return Colors.greenAccent;
      case SegmentTimerColor.yellow: return Colors.amber;
      case SegmentTimerColor.red: return Colors.redAccent;
    }
  }

  String _getTimerStatusText(SegmentTimerColor state) {
    switch (state) {
      case SegmentTimerColor.green: return 'ON TIME';
      case SegmentTimerColor.yellow: return 'WARNING';
      case SegmentTimerColor.red: return 'OVERTIME';
    }
  }
}
