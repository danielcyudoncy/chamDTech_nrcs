import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/newsroom/models/newsroom_state.dart';
import 'package:chamdtech_nrcs/features/rundowns/models/rundown_model.dart';
import 'package:chamdtech_nrcs/features/rundowns/services/rundown_service.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';

class NewsroomController extends GetxController {
  final RundownService _rundownService = Get.find<RundownService>();
  final StoryService _storyService = Get.find<StoryService>();

  final String rundownId;
  NewsroomController({required this.rundownId});

  final state = NewsroomState().obs;
  final rundown = Rx<RundownModel?>(null);
  final stories = <StoryModel>[].obs;
  final isLoading = true.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadRundown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _loadRundown() {
    _rundownService.streamRundown(rundownId).listen((data) {
      if (data != null) {
        rundown.value = data;
        _loadStories(data.storyIds);
      } else {
        Get.back();
        Get.snackbar('Error', 'Rundown not found');
      }
    }, onError: (error) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load rundown. Permissions issue?');
    });
  }

  void _loadStories(List<String> storyIds) {
    if (storyIds.isEmpty) {
      stories.clear();
      isLoading.value = false;
      return;
    }

    _storyService.getStories().listen((allStories) {
      final rundownStories = <StoryModel>[];
      for (final id in storyIds) {
        final story = allStories.firstWhereOrNull((s) => s.id == id);
        if (story != null) {
          rundownStories.add(story);
        }
      }
      stories.value = rundownStories;
      
      // Initialize segment countdown if a story is active
      if (rundownStories.isNotEmpty) {
        _updateSegmentTimer();
      }
      
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load stories.');
    });
  }

  void _updateSegmentTimer() {
    if (state.value.activeStoryIndex < stories.length) {
      final activeStory = stories[state.value.activeStoryIndex];
      state.value = state.value.copyWith(
        segmentCountdownSeconds: activeStory.duration,
        segmentElapsedSeconds: 0,
      );
    }
  }

  void startGlobalCountdown() {
    state.value = state.value.copyWith(
      globalTimerState: TimerState.running,
      segmentTimerState: TimerState.stopped,
      globalCountdownSeconds: 10,
    );
    _startTimer();
  }

  void togglePlayPause() {
    if (state.value.globalTimerState == TimerState.running || state.value.segmentTimerState == TimerState.running) {
      // Pause
      state.value = state.value.copyWith(
        globalTimerState: state.value.globalTimerState == TimerState.running ? TimerState.paused : state.value.globalTimerState,
        segmentTimerState: state.value.segmentTimerState == TimerState.running ? TimerState.paused : state.value.segmentTimerState,
      );
      _timer?.cancel();
    } else if (state.value.globalTimerState == TimerState.paused || (state.value.globalCountdownSeconds > 0 && state.value.segmentElapsedSeconds == 0)) {
       // Start or Resume global
       startGlobalCountdown();
    } else {
       // Start or Resume segment
       state.value = state.value.copyWith(
         globalTimerState: TimerState.stopped,
         segmentTimerState: TimerState.running,
       );
       _startTimer();
    }
  }

  void resetTimers() {
    _timer?.cancel();
    state.value = state.value.copyWith(
      globalTimerState: TimerState.stopped,
      segmentTimerState: TimerState.stopped,
      globalCountdownSeconds: 10,
    );
    _updateSegmentTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (state.value.globalTimerState == TimerState.running) {
      if (state.value.globalCountdownSeconds > 0) {
        state.value = state.value.copyWith(
          globalCountdownSeconds: state.value.globalCountdownSeconds - 1,
        );
      } else {
        // Global countdown finished, start segment timer
        state.value = state.value.copyWith(
          globalTimerState: TimerState.stopped,
          segmentTimerState: TimerState.running,
        );
        _updateSegmentTimer();
      }
    } else if (state.value.segmentTimerState == TimerState.running) {
      if (state.value.segmentCountdownSeconds > 0) {
        state.value = state.value.copyWith(
          segmentCountdownSeconds: state.value.segmentCountdownSeconds - 1,
          segmentElapsedSeconds: state.value.segmentElapsedSeconds + 1,
        );
      } else {
        // Segment finished
        if (state.value.autoProgressionEnabled) {
          nextStory();
        } else {
          state.value = state.value.copyWith(
            segmentTimerState: TimerState.stopped,
            segmentElapsedSeconds: state.value.segmentElapsedSeconds + 1, // Keep tracking overtime
          );
        }
      }
    }
  }

  void nextStory() {
    if (state.value.activeStoryIndex < stories.length - 1) {
      Get.snackbar(
        'Auto-Progression', 
        'Moving to Next Story', 
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      state.value = state.value.copyWith(
        activeStoryIndex: state.value.activeStoryIndex + 1,
      );
      _updateSegmentTimer();
      if (state.value.segmentTimerState == TimerState.running) {
        // Timer was running, just keep it running for the next story
      } else if (state.value.globalTimerState == TimerState.stopped) {
         // If no timer was running, maybe we want to start it? 
         // For now, let's keep it in the current state but reset timers
      }
    } else {
      // Last story finished
      state.value = state.value.copyWith(
        segmentTimerState: TimerState.stopped,
      );
      _timer?.cancel();
      Get.snackbar('Completed', 'End of rundown reached.');
    }
  }

  void selectStory(int index) {
    state.value = state.value.copyWith(
      activeStoryIndex: index,
      segmentTimerState: TimerState.stopped, // Pause timer on manual selection?
    );
    _updateSegmentTimer();
  }

  void toggleAutoProgression(bool? value) {
    if (value != null) {
      state.value = state.value.copyWith(autoProgressionEnabled: value);
    }
  }

  String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  StoryModel? get activeStory {
    if (state.value.activeStoryIndex < stories.length) {
      return stories[state.value.activeStoryIndex];
    }
    return null;
  }
}
