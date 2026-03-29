// features/newsroom/models/newsroom_state.dart

enum TimerState {
  stopped,
  running,
  paused,
}

enum SegmentTimerColor {
  green,
  yellow,
  red,
}

class NewsroomState {
  final int activeStoryIndex;
  final int globalCountdownSeconds;
  final int segmentCountdownSeconds;
  final int segmentElapsedSeconds;
  final TimerState globalTimerState;
  final TimerState segmentTimerState;
  final bool autoProgressionEnabled;

  NewsroomState({
    this.activeStoryIndex = 0,
    this.globalCountdownSeconds = 10,
    this.segmentCountdownSeconds = 0,
    this.segmentElapsedSeconds = 0,
    this.globalTimerState = TimerState.stopped,
    this.segmentTimerState = TimerState.stopped,
    this.autoProgressionEnabled = true,
  });

  NewsroomState copyWith({
    int? activeStoryIndex,
    int? globalCountdownSeconds,
    int? segmentCountdownSeconds,
    int? segmentElapsedSeconds,
    TimerState? globalTimerState,
    TimerState? segmentTimerState,
    bool? autoProgressionEnabled,
  }) {
    return NewsroomState(
      activeStoryIndex: activeStoryIndex ?? this.activeStoryIndex,
      globalCountdownSeconds: globalCountdownSeconds ?? this.globalCountdownSeconds,
      segmentCountdownSeconds: segmentCountdownSeconds ?? this.segmentCountdownSeconds,
      segmentElapsedSeconds: segmentElapsedSeconds ?? this.segmentElapsedSeconds,
      globalTimerState: globalTimerState ?? this.globalTimerState,
      segmentTimerState: segmentTimerState ?? this.segmentTimerState,
      autoProgressionEnabled: autoProgressionEnabled ?? this.autoProgressionEnabled,
    );
  }

  SegmentTimerColor get segmentTimerColor {
    if (segmentTimerState == TimerState.stopped) return SegmentTimerColor.green;
    
    // Logic for color states based on remaining time
    if (segmentCountdownSeconds > 10) {
      return SegmentTimerColor.green;
    } else if (segmentCountdownSeconds > 0) {
      return SegmentTimerColor.yellow;
    } else {
      return SegmentTimerColor.red;
    }
  }

  bool get isGlobalCountdownUrgent => globalCountdownSeconds <= 3 && globalTimerState == TimerState.running;
}
