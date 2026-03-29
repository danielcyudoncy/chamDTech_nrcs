// features/newsroom/views/widgets/active_story_panel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/newsroom/controllers/newsroom_controller.dart';

class ActiveStoryPanel extends StatelessWidget {
  final NewsroomController controller;

  const ActiveStoryPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() {
          final story = controller.activeStory;
          if (story == null) {
            return const Center(child: Text('No active story selected', style: TextStyle(color: Colors.grey)));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Badge(label: story.format, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  _Badge(label: 'SLUG: ${story.slug}', color: Colors.white10),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _parseQuillContent(story.content),
                      style: const TextStyle(
                        fontSize: 48,
                        height: 1.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PLANNED DURATION', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        controller.formatDuration(story.duration),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('ELAPSED TIME', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        controller.formatDuration(controller.state.value.segmentElapsedSeconds),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }
}

String _parseQuillContent(String rawContent) {
  try {
    final List<dynamic> jsonList = jsonDecode(rawContent);
    final buffer = StringBuffer();
    for (var op in jsonList) {
      if (op['insert'] != null && op['insert'] is String) {
        buffer.write(op['insert']);
      }
    }
    return buffer.toString().trim().isEmpty ? 'No Script Content' : buffer.toString();
  } catch (e) {
    return rawContent.trim().isEmpty ? 'No Script Content' : rawContent;
  }
}
