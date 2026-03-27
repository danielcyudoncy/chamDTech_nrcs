// features/stories/views/widgets/top_stories_ticker.dart
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../services/channel_news_service.dart';
import 'nrcs_layout.dart';

class TopStoriesTicker extends StatefulWidget {
  const TopStoriesTicker({super.key});

  @override
  State<TopStoriesTicker> createState() => _TopStoriesTickerState();
}

class _TopStoriesTickerState extends State<TopStoriesTicker> {
  List<String> stories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStories();
  }

  Future<void> loadStories() async {
    try {
      final fetchedStories = await ChannelNewsService.fetchTopStories();
      if (mounted) {
        setState(() {
          stories = fetchedStories;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 30,
        child: Center(
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(NRCSColors.topNavBlue),
            ),
          ),
        ),
      );
    }

    if (stories.isEmpty) return const SizedBox();

    return Row(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: IconButton(
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              loadStories();
            },
            icon: const Icon(Icons.refresh, size: 14, color: NRCSColors.topNavBlue),
            padding: EdgeInsets.zero,
            tooltip: 'Refresh Stories',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 30,
            child: Marquee(
              text: stories.map((s) => s.replaceAll(RegExp(r'[\n\r]+'), ' ').trim()).join("   🔴   "),
              style: const TextStyle(
                color: NRCSColors.topNavBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              velocity: 40,
              blankSpace: 100,
              pauseAfterRound: const Duration(seconds: 1),
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),
        ),
      ],
    );
  }
}
