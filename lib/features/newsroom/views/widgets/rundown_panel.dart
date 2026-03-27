import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/newsroom/controllers/newsroom_controller.dart';
import 'package:chamdtech_nrcs/features/newsroom/models/newsroom_state.dart';

class RundownPanel extends StatelessWidget {
  final NewsroomController controller;

  const RundownPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'RUNDOWN',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.stories.isEmpty) {
                return const Center(child: Text('No stories found', style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.stories.length,
                itemBuilder: (context, index) {
                  final story = controller.stories[index];
                  final isActive = controller.state.value.activeStoryIndex == index;
                  final isDone = controller.state.value.activeStoryIndex > index;
                  final isNext = controller.state.value.activeStoryIndex == index - 1;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? Colors.blue.withOpacity(0.15) 
                          : (isDone ? Colors.white.withOpacity(0.02) : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () => controller.selectStory(index),
                      leading: _buildStatusIcon(isActive, isDone, isNext),
                      title: Text(
                        story.title,
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          color: isActive ? Colors.white : (isDone ? Colors.white38 : Colors.white70),
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                story.format.toUpperCase(),
                                style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.timer_outlined, size: 14, color: isActive ? Colors.blueAccent : Colors.white38),
                            const SizedBox(width: 4),
                            Text(
                              controller.formatDuration(story.duration),
                              style: TextStyle(
                                color: isActive ? Colors.blueAccent : Colors.white38, 
                                fontSize: 13, 
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isActive, bool isDone, bool isNext) {
    if (isActive) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 32),
        ],
      );
    }
    if (isDone) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.white24, size: 32),
        ],
      );
    }
    if (isNext) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_circle_right, color: Colors.orangeAccent, size: 32),
        ],
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.circle_outlined, color: Colors.white12, size: 32),
      ],
    );
  }
}
