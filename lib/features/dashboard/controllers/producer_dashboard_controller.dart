import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/features/stories/services/story_service.dart';
import 'package:chamDTech_nrcs/features/rundowns/services/rundown_service.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/rundowns/models/rundown_model.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';

class ProducerDashboardController extends GetxController {
  final RundownService _rundownService = Get.put(RundownService());
  final StoryService _storyService = Get.find<StoryService>();
  final AuthService _authService = Get.find<AuthService>();

  final activeRundowns = <RundownModel>[].obs;
  final readyToAirStories = <StoryModel>[].obs;
  
  final isLoading = true.obs;
  final totalAirTimeSeconds = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    // Listen to active rundowns
    _rundownService.getActiveRundowns().listen((rundowns) {
      activeRundowns.value = rundowns;
      _calculateTotalAirTime(rundowns);
      
      // Stop loading after first rundown fetch
      if (isLoading.value) {
        isLoading.value = false;
      }
    }, onError: (err) {
      Get.log('Error fetching active rundowns: $err');
      isLoading.value = false;
    });

    // Listen to all stories, filter for ready-to-air locally to avoid complex index requirements initially
    _storyService.getStories().listen((stories) {
      readyToAirStories.value = stories.where((s) => 
        s.status == AppConstants.statusApproved || 
        s.stage == AppConstants.stageVerified
      ).toList();
    });
  }

  void _calculateTotalAirTime(List<RundownModel> rundowns) {
    int total = 0;
    for (var r in rundowns) {
      // Accumulate target durations (could also accumulate actual if we had it)
      total += r.targetDuration;
    }
    totalAirTimeSeconds.value = total;
  }

  String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void createNewRundown(BuildContext context) {
    final nameController = TextEditingController();
    int targetDurationMinutes = 60; // Default 1 hour

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Rundown'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Show Name (e.g. Prime Time)'),
              ),
              const SizedBox(height: 16),
              // Simpler numeric input for this rapid iteration
              DropdownButtonFormField<int>(
                value: targetDurationMinutes,
                decoration: const InputDecoration(labelText: 'Target Duration'),
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 Minutes')),
                  DropdownMenuItem(value: 30, child: Text('30 Minutes')),
                  DropdownMenuItem(value: 60, child: Text('1 Hour')),
                  DropdownMenuItem(value: 120, child: Text('2 Hours')),
                ],
                onChanged: (val) {
                  if (val != null) targetDurationMinutes = val;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                
                final producerId = _authService.currentUser.value?.id ?? '';
                final newRundown = RundownModel(
                  id: '',
                  name: nameController.text,
                  scheduledTime: DateTime.now().add(const Duration(hours: 1)), // Mocking schedule time for now
                  targetDuration: targetDurationMinutes * 60,
                  status: 'draft',
                  producerId: producerId,
                  storyIds: [],
                );

                Navigator.pop(context);
                final id = await _rundownService.createRundown(newRundown);
                
                if (id != null) {
                  Get.snackbar('Success', 'Rundown created!');
                  // Optionally navigate directly to the builder
                  // openRundownBuilder(id); 
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void openRundownBuilder(RundownModel rundown) {
    Get.toNamed(AppRoutes.rundownBuilder, arguments: rundown.id);
  }
}
