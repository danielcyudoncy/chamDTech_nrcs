import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/newsroom/controllers/newsroom_controller.dart';
import 'package:chamdtech_nrcs/features/newsroom/views/widgets/rundown_panel.dart';
import 'package:chamdtech_nrcs/features/newsroom/views/widgets/active_story_panel.dart';
import 'package:chamdtech_nrcs/features/newsroom/views/widgets/control_panel.dart';

class NewsroomDirectorScreen extends StatefulWidget {
  const NewsroomDirectorScreen({super.key});

  @override
  State<NewsroomDirectorScreen> createState() => _NewsroomDirectorScreenState();
}

class _NewsroomDirectorScreenState extends State<NewsroomDirectorScreen> {
  late final NewsroomController controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final String rundownId = Get.arguments ?? '';
    if (rundownId.isNotEmpty) {
      controller = Get.put(NewsroomController(rundownId: rundownId));
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: Text('Error: No Rundown ID provided')));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.rundown.value?.name.toUpperCase() ?? 'DIRECTOR CONTROL',
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16),
            )),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          _buildLiveStatus(),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RundownPanel(controller: controller),
          ActiveStoryPanel(controller: controller),
          ControlPanel(controller: controller),
        ],
      ),
    );
  }

  Widget _buildLiveStatus() {
// ... same as before
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 8),
          SizedBox(width: 8),
          Text(
            'LIVE BROADCAST',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
